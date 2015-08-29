import os
import hashlib
from flask import Blueprint, jsonify, request, g, abort
from github import Github

from hackathon.models import Account, AccessToken, db

account_bp = Blueprint('account', __name__, url_prefix='/account')


@account_bp.route('/', methods=['POST'])
def create_account():
    user_token = request.json.get('token')

    if not user_token:
        abort(400)

    gh = Github(login_or_token=user_token)
    gh_user = gh.get_user()

    # If we've got a user, log in!
    account = Account.query.filter_by(github_user=gh_user.login).first()

    if not account:
        account = Account(name=gh_user.name,
                          email=gh_user.email,
                          github_user=gh_user.login)

        db.session.add(account)
        db.session.flush()

    access_token = AccessToken(access_token=hashlib.sha256(os.urandom(128)).hexdigest(),
                               github_token=user_token,
                               account_id=account.id)

    db.session.add(access_token)
    db.session.commit()

    rv = {
        'name': account.name,
        'access_token': access_token.access_token
    }

    return jsonify(rv)


@account_bp.route('/update_push', methods=['POST'])
def update_push():
    new_token = request.json.get('push_token')

    access_token = AccessToken.query.filter_by(access_token=g.access_token).first()
    access_token.push_token = new_token

    db.session.commit()

    rv = {
        'name': g.name,
        'access_token': access_token.access_token
    }

    return jsonify(rv)
