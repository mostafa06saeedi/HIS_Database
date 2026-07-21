from datetime import date

from flask import render_template

from app.blueprints.dashboard import bp
from app.extensions import db
from app.models import (
    Bed,
    Department,
    Admission,
    Alert,
    Appointment,
    Log,
    PrescriptionSafetyAlert,
)


@bp.route("/")
def index():
    today = date.today()

    all_beds = Bed.query.all()
    bed_total = len(all_beds)
    bed_free = sum(1 for b in all_beds if (b.status or "").lower() == "free")
    bed_occupied = sum(1 for b in all_beds if (b.status or "").lower() == "occupied")
    bed_reserved = sum(1 for b in all_beds if (b.status or "").lower() == "reserved")

    active_alerts = (
        Alert.query.filter(Alert.status != "Resolved")
        .order_by(Alert.createdtime.desc())
        .limit(8)
        .all()
    )
    critical_alert_count = Alert.query.filter(
        Alert.status != "Resolved", Alert.severity == "Critical"
    ).count()

    todays_admission_count = Admission.query.filter(
        Admission.entrydate == today
    ).count()
    todays_appointment_count = Appointment.query.filter(
        Appointment.date == today
    ).count()

    # Phase 2 (§5) — unacknowledged prescription safety alerts (drug
    # interactions / allergy warnings), surfaced here so it's visible
    # from the very first screen a manager or pharmacist sees.
    pending_safety_alert_count = PrescriptionSafetyAlert.query.filter(
        PrescriptionSafetyAlert.acknowledgedAt.is_(None)
    ).count()

    # Bed board: departments -> their beds -> current occupant (if any)
    active_admissions_by_bed = {
        a.bedID: a
        for a in Admission.query.filter(Admission.exitdate.is_(None)).all()
        if a.bedID is not None
    }
    departments = Department.query.order_by(Department.name).all()
    board = []
    for dept in departments:
        dept_beds = [b for b in all_beds if b.departmentID == dept.id]
        if not dept_beds:
            continue
        cells = []
        for b in sorted(dept_beds, key=lambda x: x.id):
            occupant = active_admissions_by_bed.get(b.id)
            cells.append(
                {
                    "bed": b,
                    "admission": occupant,
                    "patient_name": occupant.patient.name
                    if occupant and occupant.patient
                    else None,
                }
            )
        board.append({"department": dept, "cells": cells})

    latest_logs = Log.query.order_by(Log.timestamp.desc()).limit(6).all()

    return render_template(
        "dashboard/index.html",
        bed_total=bed_total,
        bed_free=bed_free,
        bed_occupied=bed_occupied,
        bed_reserved=bed_reserved,
        critical_alert_count=critical_alert_count,
        todays_admission_count=todays_admission_count,
        todays_appointment_count=todays_appointment_count,
        pending_safety_alert_count=pending_safety_alert_count,
        active_alerts=active_alerts,
        board=board,
        latest_logs=latest_logs,
    )
