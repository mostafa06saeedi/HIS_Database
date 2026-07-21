from flask import Blueprint

bp = Blueprint("surgery", __name__, template_folder="../../templates/surgery")

from app.blueprints.surgery import routes  # noqa: E402,F401
