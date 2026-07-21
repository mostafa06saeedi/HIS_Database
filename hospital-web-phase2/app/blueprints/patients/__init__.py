from flask import Blueprint

bp = Blueprint("patients", __name__, template_folder="../../templates/patients")

from app.blueprints.patients import routes  # noqa: E402,F401
