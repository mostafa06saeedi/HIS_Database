from flask import Blueprint

bp = Blueprint("lab", __name__, template_folder="../../templates/shared")

from app.blueprints.lab import routes  # noqa: E402,F401
