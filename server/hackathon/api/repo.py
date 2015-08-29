from flask import Blueprint, jsonify, g, current_app, abort, request
from github import Github

from hackathon.objects import Repo, Organization, Milestone, Label, User

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


@repo_bp.route('/milestones', methods=['POST'])
def get_milestones():
    repo = request.json.get('repo')
    if not repo:
        abort(400)

    gh = Github(login_or_token=g.github_token, per_page=100)
    gh_repo = gh.get_repo(repo)

    user_milestones = Milestone(many=True)
    milestones_result = user_milestones.dump([r for r in gh_repo.get_milestones()])

    return jsonify(milestones=milestones_result.data)


@repo_bp.route('/labels', methods=['POST'])
def get_labels():
    repo = request.json.get('repo')
    if not repo:
        abort(400)

    gh = Github(login_or_token=g.github_token, per_page=100)
    gh_repo = gh.get_repo(repo)

    user_labels = Label(many=True)
    labels_result = user_labels.dump([r for r in gh_repo.get_labels()])

    return jsonify(labels=labels_result.data)


@repo_bp.route('/collaborators', methods=['POST'])
def get_collaborators():
    repo = request.json.get('repo')
    if not repo:
        abort(400)

    gh = Github(login_or_token=g.github_token, per_page=100)
    gh_repo = gh.get_repo(repo)

    repo_collaborators = User(many=True)
    collab_result = repo_collaborators.dump([r for r in gh_repo.get_collaborators()])

    return jsonify(collaborators=collab_result.data)