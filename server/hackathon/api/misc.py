from flask import Blueprint, jsonify, g, current_app

from hackathon.models import db, AccessToken
from hackathon.utils import send_message

misc_bp = Blueprint('misc', __name__, url_prefix='/misc')


@misc_bp.route('/notify')
def send_notification():
    api_key = current_app.config['GCM_API_KEY']
    tokens = AccessToken.query.filter_by(accound_id=g.account_id).distinct(AccessToken.push_token).all()

    notification = {
        'title': 'hello',
        'body': 'wooooooo works'
    }

    for token in tokens:
        send_message(api_key, token.push_token, notification=notification)

    return jsonify({'hello': g.name})
