from datetime import datetime

from flask import render_template, redirect, url_for, flash, request

from app.blueprints.appointments import bp
from app.extensions import db
from app.models import Appointment


@bp.route("/")
def index():
    status_filter = request.args.get("status", "all")
    query = Appointment.query
    if status_filter != "all":
        query = query.filter(Appointment.status == status_filter)
    appointments = query.order_by(
        Appointment.date.desc(), Appointment.time.desc()
    ).all()
    return render_template(
        "appointments/list.html",
        appointments=appointments,
        status_filter=status_filter,
    )


@bp.route("/<int:appointment_id>/check-in", methods=["POST"])
def check_in(appointment_id):
    """Phase 2 §3 — mirrors sp_CheckInAppointment: records the patient's
    actual arrival time, the start of the wait-time clock."""
    appt = Appointment.query.get_or_404(appointment_id)
    appt.checkInTime = datetime.now()
    db.session.commit()
    flash(f"Appointment #{appt.id} checked in.", "success")
    return redirect(url_for("appointments.index", status=request.args.get("status", "all")))


@bp.route("/<int:appointment_id>/start-service", methods=["POST"])
def start_service(appointment_id):
    """Phase 2 §3 — mirrors sp_StartAppointmentService: the moment the
    doctor actually starts seeing the patient (closes the wait-time clock)."""
    appt = Appointment.query.get_or_404(appointment_id)
    appt.serviceStartTime = datetime.now()
    db.session.commit()
    flash(f"Appointment #{appt.id} — visit started.", "success")
    return redirect(url_for("appointments.index", status=request.args.get("status", "all")))


@bp.route("/<int:appointment_id>/check-out", methods=["POST"])
def check_out(appointment_id):
    """Phase 2 §3 — mirrors sp_CheckOutAppointment: ends the visit and
    completes the appointment."""
    appt = Appointment.query.get_or_404(appointment_id)
    appt.checkOutTime = datetime.now()
    appt.status = "Completed"
    db.session.commit()
    flash(f"Appointment #{appt.id} completed.", "success")
    return redirect(url_for("appointments.index", status=request.args.get("status", "all")))
