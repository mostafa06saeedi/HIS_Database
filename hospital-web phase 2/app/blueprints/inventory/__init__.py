from flask import Blueprint

bp = Blueprint("inventory", __name__, template_folder="../../templates/shared")

from app.blueprints.inventory import routes  # noqa: E402,F401
