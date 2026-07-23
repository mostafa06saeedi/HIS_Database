from datetime import datetime

from flask import render_template, redirect, url_for, flash, request

from app.blueprints.surgery import bp
from app.blueprints.surgery.forms import ScheduleSurgeryForm
from app.extensions import db
from app.models import OperatingRoom, SurgeryRecord, Patient, Admission, Surgeon, Employee


def _patient_choices():
    return [
        (p.nationalID, f"{p.name} ({p.nationalID})")
        for p in Patient.query.order_by(Patient.name).all()
    ]


def _admission_choices():
    return [(0, "— none —")] + [
        (a.id, f"#{a.id} · {a.patient.name if a.patient else '—'}")
        for a in Admission.query.filter(Admission.exitdate.is_(None)).all()
    ]


def _surgeon_choices():
    surgeons = (
        Employee.query.join(Surgeon, Surgeon.employeeID == Employee.id)
        .order_by(Employee.name)
        .all()
    )
    return [(0, "— unassigned —")] + [(e.id, e.name) for e in surgeons]


@bp.route("/")
def index():
    """Mirrors vw_OperatingRoomStatus + a chronological surgery list —
    Phase 2 §4 (resource optimization)."""
    rooms = OperatingRoom.query.order_by(OperatingRoom.id).all()
    in_progress_by_room = {
        s.operatingRoomID: s
        for s in SurgeryRecord.query.filter(SurgeryRecord.status == "InProgress").all()
    }
    board = [
        {"room": r, "surgery": in_progress_by_room.get(r.id)}
        for r in rooms
    ]

    status_filter = request.args.get("status", "upcoming")
    query = SurgeryRecord.query
    if status_filter == "upcoming":
        query = query.filter(SurgeryRecord.status.in_(["Scheduled", "InProgress"]))
    surgeries = query.order_by(SurgeryRecord.scheduledStart.desc()).all()

    return render_template(
        "surgery/index.html", board=board, surgeries=surgeries, status_filter=status_filter
    )


@bp.route("/new", methods=["GET", "POST"])
def schedule():
    form = ScheduleSurgeryForm()
    form.operatingRoomID.choices = [
        (r.id, f"{r.roomNumber or r.id} · {r.department.name if r.department else '—'} ({r.status})")
        for r in OperatingRoom.query.order_by(OperatingRoom.id).all()
    ]
    form.patientID.choices = _patient_choices()
    form.admissionID.choices = _admission_choices()
    form.surgeonID.choices = _surgeon_choices()

    if form.validate_on_submit():
        surgery = SurgeryRecord(
            operatingRoomID=form.operatingRoomID.data,
            patientID=form.patientID.data,
            admissionID=form.admissionID.data or None,
            surgeonID=form.surgeonID.data or None,
            procedureName=form.procedureName.data,
            scheduledStart=form.scheduledStart.data,
            status="Scheduled",
        )
        db.session.add(surgery)
        db.session.commit()
        flash("Surgery scheduled.", "success")
        return redirect(url_for("surgery.index"))

    return render_template("surgery/schedule.html", form=form)


@bp.route("/<int:surgery_id>/start", methods=["POST"])
def start(surgery_id):
    """Mirrors sp_StartSurgery — validates the OR is Free, then flips it
    to Occupied (trg_surgeryrecord_or_status mirrors this on real SQL
    Server; done explicitly here for the SQLite/offline fallback too)."""
    surgery = SurgeryRecord.query.get_or_404(surgery_id)
    room = surgery.operating_room
    if room and room.status != "Free":
        flash("Operating room is not currently free.", "error")
        return redirect(url_for("surgery.index"))

    surgery.actualStart = datetime.now()
    surgery.status = "InProgress"
    if room:
        room.status = "Occupied"
    db.session.commit()
    flash(f"Surgery #{surgery.id} started.", "success")
    return redirect(url_for("surgery.index"))


@bp.route("/<int:surgery_id>/complete", methods=["POST"])
def complete(surgery_id):
    """Mirrors sp_CompleteSurgery — frees the OR again."""
    surgery = SurgeryRecord.query.get_or_404(surgery_id)
    surgery.actualEnd = datetime.now()
    surgery.status = "Completed"
    if surgery.operating_room:
        surgery.operating_room.status = "Free"
    db.session.commit()
    flash(f"Surgery #{surgery.id} completed.", "success")
    return redirect(url_for("surgery.index"))


@bp.route("/<int:surgery_id>/cancel", methods=["POST"])
def cancel(surgery_id):
    surgery = SurgeryRecord.query.get_or_404(surgery_id)
    surgery.status = "Cancelled"
    if surgery.operating_room and surgery.operating_room.status == "Occupied":
        surgery.operating_room.status = "Free"
    db.session.commit()
    flash(f"Surgery #{surgery.id} cancelled.", "success")
    return redirect(url_for("surgery.index"))
