import logging
import sys
import threading
import arrow

from werkzeug.exceptions import default_exceptions, HTTPException
from flask import Flask, g, request, jsonify, abort
from flask.ext.sqlalchemy import SQLAlchemy
from github import Github

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

# Recurring task -- it's going in here because we don't have a better place without Celery
# Should run on server start and every five minutes
def process_notifications():
    threading.Timer(60.0, process_notifications).start()
    app.logger.info('Running thread.')

    for account in Account.query.all():
        if not account.last_email:
            account.last_email = arrow.now().datetime

        if not account.last_push:
            account.last_push = arrow.now().datetime

        last_push_unix = arrow.get(account.last_push).timestamp
        last_email_unix = arrow.get(account.last_email).timestamp

        # Band-aid for being outside of request context
        token = AccessToken.query.filter_by(account_id=account.id).first()
        github_token = token.github_token

        if last_push_unix < arrow.now().timestamp - 90:
            gh = Github(login_or_token=github_token, per_page=100)

            all_issues = []
            all_comments = []
            for repo_id in account.watchlist:
                repo = gh.get_repo(repo_id)
                for issue in repo.get_issues(since=account.last_push):
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

            app.logger.info('There were {} updated issues and {} updated comments.'.format(len(issues_result.data),
                                                                                           len(comments_results.data)))
            account.last_push = arrow.now().datetime

        if last_email_unix < arrow.now().timestamp - 3600:
            gh = Github(login_or_token=github_token, per_page=100)

            all_issues = []
            all_comments = []
            for repo_id in account.watchlist:
                repo = gh.get_repo(repo_id)
                for issue in repo.get_issues(since=account.last_email):
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
            account.last_email = arrow.now().datetime

        with app.app_context():
            db.session.commit()

# Run the recurring task
process_notifications()
