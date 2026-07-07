from flask import Blueprint

bp = Blueprint("appointments", __name__, template_folder="../../templates/shared")

from app.blueprints.appointments import routes  # noqa: E402,F401
