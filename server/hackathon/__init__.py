import logging
import sys
import threading
import time
import arrow
import mandrill

from werkzeug.exceptions import default_exceptions, HTTPException
from flask import Flask, g, request, jsonify, abort
from flask.ext.sqlalchemy import SQLAlchemy
from github import Github

from hackathon.utils import send_message
from hackathon.objects import Issue, Comment

# Basic configuration
app = Flask(__name__)
db = SQLAlchemy(app)

app.config.from_object('hackathon.config')

from hackathon.models import AccessToken, Account


# Authentication
def authenticate_user():
    if request.path == '/account/':
        return

    token_header = request.headers.get('Authorization')
    if not token_header:
        abort(401)

    access_token = AccessToken.query.filter_by(access_token=token_header).first()
    if not access_token:
        abort(403)

    g.name = access_token.account.name
    g.access_token = access_token.access_token
    g.account_id = access_token.account_id
    g.github_token = access_token.github_token

app.before_request(authenticate_user)


# Logging
handler = logging.StreamHandler(sys.stdout)
app.logger.handlers = []
app.logger.addHandler(handler)
app.logger.setLevel(logging.DEBUG)


# Error handling
def handle_error(error):
    if isinstance(error, HTTPException):
        code = error.code
        error_type = error.name
    else:
        code = 500
        error_type = error.__class__.__name__

    rv = {
        'status': code,
        'error': error_type,
    }

    response = jsonify(rv)
    response.status_code = code

    return response

for code in default_exceptions.keys():
    app.error_handler_spec[None][code] = handle_error

from hackathon.api import blueprints

for bp in blueprints:
    app.register_blueprint(bp)

db.create_all()


def send_mandrill_email(recipient, template_name, global_merge_vars):
    """Send email using Mandrill template"""

    mandrill_client = mandrill.Mandrill(app.config['MANDRILL_KEY'])
    template_content = []
    message = {
        'from_email': 'noreply@repositron.52inc.com',
        'from_name': 'Repositron',
        'global_merge_vars': [],
        'to': [{
            'email': recipient
        }]
    }

    for k, v in global_merge_vars.items():
        message['global_merge_vars'].append({'name': k, 'content': v})

    mandrill_client.messages.send_template(template_name=template_name,
                                           template_content=template_content,
                                           message=message)


def send_notification(account_id, message):
    with app.app_context():
        api_key = app.config['GCM_API_KEY']
        tokens = AccessToken.query.filter_by(account_id=account_id).distinct(AccessToken.push_token).all()

    notification = {
        'title': 'GitHub Activity',
        'body': message
    }

    for token in tokens:
        if token.push_token:
            send_message(api_key, token.push_token, notification=notification)

# Recurring task -- it's going in here because we don't have a better place without Celery
# Should run on server start and every five minutes
def process_notifications():
    app.logger.info('Running notification thread.')

    for account in Account.query.all():
        if not account.last_email:
            account.last_email = arrow.now().datetime

        if not account.last_push:
            account.last_push = arrow.now().datetime

        # Band-aid for being outside of request context
        token = AccessToken.query.filter_by(account_id=account.id).first()
        github_token = token.github_token

        timestamp_window = arrow.get(arrow.now().timestamp - 30).datetime
        gh = Github(login_or_token=github_token, per_page=100)

        all_issues = []
        all_comments = []
        for repo_id in account.watchlist:
            repo = gh.get_repo(repo_id)
            for issue in repo.get_issues(since=timestamp_window):
                issue.repo = repo.full_name
                issue.unix_updated_at = arrow.get(issue.updated_at).timestamp
                issue.unix_created_at = arrow.get(issue.created_at).timestamp
                all_issues.append(issue)

                for comment in issue.get_comments():
                    comment.repo = repo.full_name
                    comment.issue_number = issue.number
                    comment.unix_updated_at = arrow.get(comment.updated_at).timestamp
                    comment.unix_created_at = arrow.get(comment.created_at).timestamp
                    all_comments.append(comment)

        all_issues.sort(key=lambda i: i.unix_updated_at, reverse=True)
        all_comments.sort(key=lambda c: c.unix_updated_at, reverse=True)

        all_comments = [a for a in all_comments if a.unix_updated_at > arrow.get(account.last_push).timestamp]

        issues = Issue(many=True)
        issues_result = issues.dump([r for r in all_issues])

        comments = Comment(many=True)
        comments_results = comments.dump([c for c in all_comments])

        message = 'There were {} updated issues and {} updated comments.'.format(len(issues_result.data),
                                                                                 len(comments_results.data))
        if len(comments_results.data) + len(issues_result.data) >= 1:
            send_notification(account.id, message)
            app.logger.info(message)

        account.last_push = arrow.now().datetime


def process_emails():
    app.logger.info('Running email thread.')

    for account in Account.query.all():
        # Band-aid for being outside of request context
        token = AccessToken.query.filter_by(account_id=account.id).first()
        github_token = token.github_token

        timestamp_window = arrow.get(arrow.now().timestamp - 3600).datetime
        gh = Github(login_or_token=github_token, per_page=100)

        all_issues = []
        all_comments = []
        for repo_id in account.watchlist:
            repo = gh.get_repo(repo_id)
            for issue in repo.get_issues(since=timestamp_window):
                issue.repo = repo.full_name
                issue.unix_updated_at = arrow.get(issue.updated_at).timestamp
                issue.unix_created_at = arrow.get(issue.created_at).timestamp
                all_issues.append(issue)

                for comment in issue.get_comments():
                    comment.repo = repo.full_name
                    comment.issue_number = issue.number
                    comment.unix_updated_at = arrow.get(comment.updated_at).timestamp
                    comment.unix_created_at = arrow.get(comment.created_at).timestamp
                    all_comments.append(comment)

            all_issues.sort(key=lambda i: i.unix_updated_at, reverse=True)
            all_comments.sort(key=lambda c: c.unix_updated_at, reverse=True)

            all_comments = [a for a in all_comments if a.unix_updated_at < arrow.get(account.last_email).timestamp]

            issues = Issue(many=True)
            issues_result = issues.dump([r for r in all_issues])

            comments = Comment(many=True)
            comments_results = comments.dump([c for c in all_comments])

            num_comments = len(comments_results.data)
            num_issues = len(issues_result.data)

            if num_issues + num_comments >= 1:
                issues_format = '<li>Issue #{}: {} ({})</li>\n'
                issues_block = ''
                for i in all_issues:
                    issues_block += issues_format.format(i.number, i.title, arrow.get(i.updated_at).humanize())

                send_mandrill_email('kelly@52inc.com', 'email-digest', {
                    'num_comments': num_comments,
                    'num_issues': num_issues,
                    'issues_block': issues_block
                })

                app.logger.info('sent an email.')

            account.last_email = arrow.now().datetime
            db.session.flush()
            db.session.commit()
