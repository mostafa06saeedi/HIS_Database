from flask import Blueprint

bp = Blueprint("followups", __name__, template_folder="../../templates/followups")

from app.blueprints.followups import routes  # noqa: E402,F401
