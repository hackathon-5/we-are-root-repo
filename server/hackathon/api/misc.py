from flask import Blueprint, jsonify

misc_bp = Blueprint('misc', __name__, url_prefix='/misc')


@misc_bp.route('/')
def testing_root():
    return jsonify({'hello': 'okay'})
