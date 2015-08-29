import arrow
import base64
import hashlib

from flask import Blueprint, jsonify, g, current_app, abort, request
from github import Github

from hackathon.objects import Issue, Comment

issue_bp = Blueprint('issue', __name__, url_prefix='/issue')


@issue_bp.route('/', methods=['POST'])
def create_issue():
    repo = request.json.get('repo')
    title = request.json.get('title')
    body = request.json.get('body')
    if not repo or not title:
        abort(400)

    if request.json.get('images'):
        body += '\n\n'
        for image in request.json.get('images'):
            image_bytes = base64.b64decode(image)
            filename = '{}.jpg'.format(hashlib.md5(image_bytes).hexdigest())
            with open('scratch/{}'.format(filename), 'wb') as output:
                output.write(image_bytes)

            body += '{}/{}\n'.format(current_app.config.get('STATIC_ASSET_URL'), filename)

    gh = Github(login_or_token=g.github_token, per_page=100)
    gh_repo = gh.get_repo(repo)

    r = gh_repo.create_issue(title=title, body=body)
    r.repo = repo

    r.unix_created_at = arrow.get(r.created_at).timestamp
    r.unix_updated_at = arrow.get(r.updated_at).timestamp

    issue_schema = Issue()
    issue_result = issue_schema.dump(r)

    return jsonify(created_issue=issue_result.data)


@issue_bp.route('/comment', methods=['POST'])
def create_comment():
    repo = request.json.get('repo')
    issue_number = request.json.get('issue_number')
    body = request.json.get('body')
    if not repo:
        abort(400)

    gh = Github(login_or_token=g.github_token, per_page=100)
    gh_repo = gh.get_repo(repo)

    r = gh_repo.get_issue(issue_number)
    comment = r.create_comment(body)
    comment.repo = repo

    comment.unix_created_at = arrow.get(comment.created_at).timestamp
    comment.unix_updated_at = arrow.get(comment.updated_at).timestamp

    comment_schema = Comment()
    comment_result = comment_schema.dump(comment)

    return jsonify(created_comment=comment_result.data)