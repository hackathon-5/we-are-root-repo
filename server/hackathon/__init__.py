from hackathon.api import blueprints
from flask import Flask


def create_app():
    app = Flask(__name__)

    for bp in blueprints:
        app.register_blueprint(bp)

    return app
