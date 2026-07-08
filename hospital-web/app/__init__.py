from flask import Flask

from app.config import Config
from app.extensions import db


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    db.init_app(app)

    with app.app_context():
        from app import models  # noqa: F401  (registers all mappers)

    register_blueprints(app)

    @app.context_processor
    def inject_now():
        from datetime import datetime
        return {"now": datetime.now()}

    return app


def register_blueprints(app):
    from app.blueprints.dashboard import bp as dashboard_bp
    from app.blueprints.patients import bp as patients_bp
    from app.blueprints.admissions import bp as admissions_bp
    from app.blueprints.iot import bp as iot_bp
    from app.blueprints.staff import bp as staff_bp
    from app.blueprints.appointments import bp as appointments_bp
    from app.blueprints.lab import bp as lab_bp
    from app.blueprints.pharmacy import bp as pharmacy_bp
    from app.blueprints.inventory import bp as inventory_bp
    from app.blueprints.financial import bp as financial_bp

    app.register_blueprint(dashboard_bp)
    app.register_blueprint(patients_bp, url_prefix="/patients")
    app.register_blueprint(admissions_bp, url_prefix="/admissions")
    app.register_blueprint(iot_bp, url_prefix="/iot")
    app.register_blueprint(staff_bp, url_prefix="/staff")
    app.register_blueprint(appointments_bp, url_prefix="/appointments")
    app.register_blueprint(lab_bp, url_prefix="/lab")
    app.register_blueprint(pharmacy_bp, url_prefix="/pharmacy")
    app.register_blueprint(inventory_bp, url_prefix="/inventory")
    app.register_blueprint(financial_bp, url_prefix="/financial")
