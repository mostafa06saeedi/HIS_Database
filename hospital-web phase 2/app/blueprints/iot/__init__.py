from flask import Blueprint

bp = Blueprint("iot", __name__, template_folder="../../templates/iot")

from app.blueprints.iot import routes  # noqa: E402,F401
