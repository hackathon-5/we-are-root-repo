from flask import Blueprint, jsonify, g

from hackathon.models import db

misc_bp = Blueprint('misc', __name__, url_prefix='/misc')


@misc_bp.route('/')
def testing_root():
    return jsonify({'hello': g.name})
