from datetime import datetime

from flask import render_template, redirect, url_for, flash, request

from app.blueprints.safety import bp
from app.extensions import db
from app.models import PrescriptionSafetyAlert, Employee


@bp.route("/")
def index():
    """Mirrors vw_PendingSafetyAlerts (Phase 2 §5) — interaction/allergy
    warnings auto-logged by trg_prescriptionitem_safety_check, surfaced
    here as a review queue for pharmacists/doctors."""
    status_filter = request.args.get("status", "open")
    query = PrescriptionSafetyAlert.query
    if status_filter == "open":
        query = query.filter(PrescriptionSafetyAlert.acknowledgedAt.is_(None))
    alerts = query.order_by(PrescriptionSafetyAlert.createdAt.desc()).all()
    employees = Employee.query.order_by(Employee.name).all()
    return render_template(
        "safety/index.html", alerts=alerts, status_filter=status_filter, employees=employees
    )


@bp.route("/<int:alert_id>/acknowledge", methods=["POST"])
def acknowledge(alert_id):
    alert = PrescriptionSafetyAlert.query.get_or_404(alert_id)
    employee_id = request.form.get("employeeID", type=int)
    alert.acknowledgedbyemployeeID = employee_id or None
    alert.acknowledgedAt = datetime.now()
    db.session.commit()
    flash(f"Safety alert #{alert.id} acknowledged.", "success")
    return redirect(url_for("safety.index", status=request.args.get("status", "open")))
