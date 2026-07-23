from flask import Blueprint

bp = Blueprint("pharmacy", __name__, template_folder="../../templates/shared")

from app.blueprints.pharmacy import routes  # noqa: E402,F401
