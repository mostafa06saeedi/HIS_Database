from datetime import date

from flask import render_template, redirect, url_for, flash, request

from app.blueprints.lab import bp
from app.extensions import db
from app.models import LabImagingRequest, LabAlert


def _patient_for_request(req):
    if req.appointment and req.appointment.patient:
        return req.appointment.patient.name
    if req.admission and req.admission.patient:
        return req.admission.patient.name
    return "—"


@bp.route("/")
def index():
    requests = LabImagingRequest.query.order_by(
        LabImagingRequest.date.desc()
    ).all()
    columns = [
        ("id", "ID"),
        ("type", "Type"),
        ("patient", "Patient"),
        ("employee", "Requested by"),
        ("date", "Date"),
        ("status", "Status"),
        ("alert_severity", "Alert severity"),
    ]
    rows = []
    for r in requests:
        latest_result = r.results[-1] if r.results else None
        latest_alert = None
        if latest_result and latest_result.alerts:
            latest_alert = latest_result.alerts[-1]
        rows.append(
            {
                "id": r.id,
                "_mono_id": True,
                "type": r.type or "—",
                "patient": _patient_for_request(r),
                "employee": r.employee.name if r.employee else "—",
                "date": r.date or "—",
                "status": r.status or "—",
                "alert_severity": latest_alert.severity if latest_alert else "—",
            }
        )
    open_alert_count = LabAlert.query.filter(LabAlert.status != "Resolved").count()

    return render_template(
        "lab/index.html",
        columns=columns,
        rows=rows,
        open_alert_count=open_alert_count,
    )


@bp.route("/alerts")
def alerts():
    status_filter = request.args.get("status", "open")
    query = LabAlert.query
    if status_filter == "open":
        query = query.filter(LabAlert.status != "Resolved")
    alert_rows = query.order_by(LabAlert.createdAt.desc()).all()
    return render_template(
        "lab/alerts.html", alerts=alert_rows, status_filter=status_filter
    )


@bp.route("/alerts/<int:alert_id>/resolve", methods=["POST"])
def resolve_alert(alert_id):
    alert = LabAlert.query.get_or_404(alert_id)
    alert.status = "Resolved"
    alert.resolvedAt = date.today()
    db.session.commit()
    flash(f"Lab alert #{alert.id} marked resolved.", "success")
    return redirect(url_for("lab.alerts", status=request.args.get("status", "open")))
