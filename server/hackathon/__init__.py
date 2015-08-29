from werkzeug.exceptions import default_exceptions, HTTPException
from flask import Flask, g, request, jsonify, abort
from flask.ext.sqlalchemy import SQLAlchemy

# Basic configuration
app = Flask(__name__)
db = SQLAlchemy(app)

app.config.from_object('hackathon.config')

from hackathon.models import AccessToken

# Authentication
def authenticate_user():
    if request.path == '/account/':
        return

    token_header = request.headers.get('Authorization')
    if not token_header:
        abort(400)

    access_token = AccessToken.query.filter_by(access_token=token_header).first()
    if not access_token:
        abort(403)

    g.name = access_token.account.name
    g.github_token = access_token.github_token

app.before_request(authenticate_user)


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