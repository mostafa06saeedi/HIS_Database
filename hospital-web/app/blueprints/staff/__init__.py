from flask import Blueprint

bp = Blueprint("staff", __name__, template_folder="../../templates/shared")

from app.blueprints.staff import routes  # noqa: E402,F401
