from flask import Blueprint

bp = Blueprint("safety", __name__, template_folder="../../templates/safety")

from app.blueprints.safety import routes  # noqa: E402,F401
