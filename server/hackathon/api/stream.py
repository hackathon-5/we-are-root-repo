import arrow

from flask import Blueprint, jsonify, g, current_app, abort, request
from github import Github

from hackathon.objects import Repo, Organization, Issue, Comment

stream_bp = Blueprint('stream', __name__, url_prefix='/stream')


@stream_bp.route('/', methods=['POST'])
def list_repos():
    repos_watched = request.json.get('repos')

    gh = Github(login_or_token=g.github_token, per_page=100)

    all_issues = []
    all_comments = []
    for repo_id in repos_watched:
        repo = gh.get_repo(repo_id)
        for issue in repo.get_issues():
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

    issues = Issue(many=True)
    issues_result = issues.dump([r for r in all_issues])

    comments = Comment(many=True)
    comments_results = comments.dump([c for c in all_comments])

    return jsonify(issues=issues_result.data,
                   comments=comments_results.data)

