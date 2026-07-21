from flask import render_template

from app.blueprints.pharmacy import bp
from app.models import Prescription, DrugInteraction, PrescriptionSafetyAlert


@bp.route("/")
def index():
    prescriptions = Prescription.query.order_by(Prescription.date.desc()).all()
    columns = [
        ("id", "ID"),
        ("patient", "Patient"),
        ("employee", "Prescribed by"),
        ("date", "Date"),
        ("items", "Drugs"),
        ("status", "Status"),
    ]
    rows = [
        {
            "id": p.id,
            "_mono_id": True,
            "patient": p.patient.name if p.patient else "—",
            "employee": p.employee.name if p.employee else "—",
            "date": p.date or "—",
            "items": ", ".join(
                (item.drug.name if item.drug else "?") for item in p.items
            )
            or "—",
            "status": p.status or "—",
        }
        for p in prescriptions
    ]

    interactions = DrugInteraction.query.all()

    # Phase 2 (§5) — pending drug-interaction / allergy safety alerts,
    # auto-logged by trg_prescriptionitem_safety_check whenever a
    # prescription item is added. See /safety for the full triage queue.
    pending_safety_alert_count = PrescriptionSafetyAlert.query.filter(
        PrescriptionSafetyAlert.acknowledgedAt.is_(None)
    ).count()

    return render_template(
        "pharmacy/index.html",
        columns=columns,
        rows=rows,
        interactions=interactions,
        pending_safety_alert_count=pending_safety_alert_count,
    )
