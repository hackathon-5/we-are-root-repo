from flask import Blueprint, jsonify, g, current_app, abort, request
from github import Github

from hackathon.models import Account, WatchedRepo, db
from hackathon.objects import Repo, Organization

repo_bp = Blueprint('repo', __name__, url_prefix='/repo')


@repo_bp.route('/list_all')
def list_repos():
    gh = Github(login_or_token=g.github_token, per_page=100)
    gh_user = gh.get_user()

    user_repos = Repo(many=True)
    repo_result = user_repos.dump([r for r in gh_user.get_repos()])

    user_orgs = Organization(many=True)
    orgs_result = user_orgs.dump([r for r in gh_user.get_orgs()])

    return jsonify(repos=repo_result.data,
                   organizations=orgs_result.data)


@repo_bp.route('/watch', methods=['POST'])
def watch_repos():
    if not request.json.get('repos'):
        abort(400)

    currently_watched = WatchedRepo.query.filter_by(account_id=g.account_id).all()
    for c in currently_watched:
        if c.repo_id not in request.json.get('repos'):
            db.session.delete(c)

    for repo_id in request.json.get('repos'):
        watch = WatchedRepo(repo_id=repo_id,
                            account_id=g.account_id)

        db.session.add(watch)

    db.session.commit()

