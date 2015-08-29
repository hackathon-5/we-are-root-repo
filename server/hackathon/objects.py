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
    assignee = fields.Nested(User)
    created_at = fields.Integer(attribute='unix_created_at')
    updated_at = fields.Integer(attribute='unix_updated_at')


class Comment(Schema):
    id = fields.Integer()
    repo = fields.Str()
    issue_number = fields.Integer()
    body = fields.Str()
    user = fields.Nested(User)
    created_at = fields.Integer(attribute='unix_created_at')
    updated_at = fields.Integer(attribute='unix_updated_at')