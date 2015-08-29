from marshmallow import Schema, fields


class Owner(Schema):
    id = fields.Integer()
    login = fields.Str()
    type = fields.Str()


class Repo(Schema):
    id = fields.Integer()
    name = fields.Str()
    owner = fields.Nested(Owner)


class Organization(Schema):
    id = fields.Integer()
    login = fields.Str()
    avatar_url = fields.Str()


class Watched(Schema):
    repo_id = fields.Integer()