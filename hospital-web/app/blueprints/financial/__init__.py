from flask import Blueprint

bp = Blueprint("financial", __name__, template_folder="../../templates/shared")

from app.blueprints.financial import routes  # noqa: E402,F401
