from flask import render_template

from app.blueprints.appointments import bp
from app.models import Appointment


@bp.route("/")
def index():
    appointments = Appointment.query.order_by(
        Appointment.date.desc(), Appointment.time.desc()
    ).all()
    columns = [
        ("id", "ID"),
        ("patient", "Patient"),
        ("department", "Department"),
        ("employee", "Physician"),
        ("when", "Date · Time"),
        ("type", "Type"),
        ("status", "Status"),
    ]
    rows = [
        {
            "id": a.id,
            "_mono_id": True,
            "patient": a.patient.name if a.patient else "—",
            "department": a.department.name if a.department else "—",
            "employee": a.employee.name if a.employee else "—",
            "when": f"{a.date or '—'} · {a.time or '—'}",
            "type": a.appointment_type or "—",
            "status": a.status or "—",
        }
        for a in appointments
    ]
    return render_template(
        "shared/simple_list.html",
        title="Appointments",
        eyebrow="Module 2 · Admissions & Appointments",
        subtitle="In-person and online bookings across every department.",
        columns=columns,
        rows=rows,
        extend_note=(
            "add a booking form here (patient, department, physician, date/time, type) "
            "using the same WTForms pattern as admissions/forms.py, plus cancel/reschedule actions."
        ),
    )
