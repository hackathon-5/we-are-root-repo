from marshmallow import Schema, fields


class Owner(Schema):
    id = fields.Integer()
    login = fields.Str()
    type = fields.Str()


class Repo(Schema):
    id = fields.Integer()
    full_name = fields.Str()
    owner = fields.Nested(Owner)


class Organization(Schema):
    id = fields.Integer()
    login = fields.Str()
    avatar_url = fields.Str()


class Watched(Schema):
    repos = fields.List(fields.Str)


class User(Schema):
    id = fields.Integer()
    login = fields.Str()
    avatar_url = fields.Str()


class Issue(Schema):
    id = fields.Integer()
    number = fields.Integer()
    repo = fields.Str()
    state = fields.Str()
    title = fields.Str()
    body = fields.Str()
    user = fields.Nested(User)
    created_at = fields.DateTime()
    updated_at = fields.DateTime()


class Comment(Schema):
    id = fields.Integer()
    repo = fields.Str()
    body = fields.Str()
    created_at = fields.DateTime()
    updated_at = fields.DateTime()