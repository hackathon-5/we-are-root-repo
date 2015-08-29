from datetime import datetime
from hackathon import db

from sqlalchemy.ext.declarative import declared_attr


class Base(db.Model):
    __abstract__ = True

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    created_at = db.Column(db.DateTime, default=datetime.now())
    updated_at = db.Column(db.DateTime, onupdate=datetime.now())

    @declared_attr
    def __tablename__(cls):
        return cls.__name__.lower()


class Account(Base):
    name = db.Column(db.String)
    email = db.Column(db.String)
    github_user = db.Column(db.String, unique=True)
    last_push = db.Column(db.DateTime)
    last_email = db.Column(db.DateTime)


class AccessToken(Base):
    __tablename__ = 'access_token'

    access_token = db.Column(db.String, unique=True)
    github_token = db.Column(db.String)
    push_token = db.Column(db.String)
    account_id = db.Column(db.Integer, db.ForeignKey('account.id'))

    account = db.relationship('Account', backref=db.backref('access_tokens', lazy='dynamic'))
