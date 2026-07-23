from datetime import date

from sqlalchemy.exc import DBAPIError
from flask import render_template, redirect, url_for, flash, request

from app.blueprints.admissions import bp
from app.blueprints.admissions.forms import AdmissionForm, DischargeForm
from app.extensions import db
from app.models import Admission, Patient, Bed, Employee, Doctor, PatientTransfer


def _patient_choices():
    return [
        (p.nationalID, f"{p.name} ({p.nationalID})")
        for p in Patient.query.order_by(Patient.name).all()
    ]


def _free_bed_choices(include_bed=None):
    query = Bed.query.filter(Bed.status == "Free")
    beds = query.all()
    if include_bed and include_bed not in beds:
        beds.append(include_bed)
    return [
        (b.id, f"{b.department.name if b.department else '—'} · Room {b.room} · Bed {b.id}")
        for b in beds
    ]


def _doctor_choices():
    doctors = (
        Employee.query.join(Doctor, Doctor.employeeID == Employee.id)
        .order_by(Employee.name)
        .all()
    )
    return [(0, "— unassigned —")] + [(e.id, e.name) for e in doctors]


@bp.route("/")
def index():
    show_all = request.args.get("all") == "1"
    query = Admission.query
    if not show_all:
        query = query.filter(Admission.exitdate.is_(None))
    admissions = query.order_by(Admission.entrydate.desc()).all()
    return render_template(
        "admissions/list.html", admissions=admissions, show_all=show_all
    )


@bp.route("/new", methods=["GET", "POST"])
def create():
    form = AdmissionForm()
    form.patientID.choices = _patient_choices()
    form.bedID.choices = _free_bed_choices()
    form.employeeID.choices = _doctor_choices()

    if not form.bedID.choices:
        flash("No free beds are available right now.", "error")

    if form.validate_on_submit():
        bed = Bed.query.get(form.bedID.data)
        admission = Admission(
            patientID=form.patientID.data,
            bedID=bed.id,
            employeeID=form.employeeID.data or None,
            entrydate=form.entrydate.data,
            reason=form.reason.data,
        )
        bed.status = "Occupied"
        db.session.add(admission)
        try:
            db.session.commit()
        except DBAPIError:
            db.session.rollback()
            flash(
                "The database rejected this admission — the bed may no "
                "longer be free. Please try again.",
                "error",
            )
            return render_template("admissions/form.html", form=form)
        flash("Patient admitted.", "success")
        return redirect(url_for("admissions.detail", admission_id=admission.id))

    return render_template("admissions/form.html", form=form)


@bp.route("/<int:admission_id>")
def detail(admission_id):
    admission = Admission.query.get_or_404(admission_id)
    discharge_form = DischargeForm()
    transfers = (
        PatientTransfer.query.filter_by(admissionID=admission.id)
        .order_by(PatientTransfer.date.desc())
        .all()
    )
    free_beds = _free_bed_choices()
    return render_template(
        "admissions/detail.html",
        admission=admission,
        discharge_form=discharge_form,
        transfers=transfers,
        free_beds=free_beds,
    )


@bp.route("/<int:admission_id>/discharge", methods=["POST"])
def discharge(admission_id):
    admission = Admission.query.get_or_404(admission_id)
    form = DischargeForm()

    if form.validate_on_submit():
        admission.exitdate = form.exitdate.data
        if admission.bed:
            admission.bed.status = "Free"
        db.session.commit()
        flash("Patient discharged.", "success")
    else:
        flash("Couldn't discharge — check the exit date.", "error")

    return redirect(url_for("admissions.detail", admission_id=admission_id))


@bp.route("/<int:admission_id>/transfer", methods=["POST"])
def transfer(admission_id):
    admission = Admission.query.get_or_404(admission_id)
    new_bed_id = request.form.get("toBedID", type=int)
    reason = request.form.get("reason", "")

    new_bed = Bed.query.get(new_bed_id) if new_bed_id else None
    if not new_bed or new_bed.status != "Free":
        flash("Pick a valid, free destination bed.", "error")
        return redirect(url_for("admissions.detail", admission_id=admission_id))

    old_bed = admission.bed
    transfer_record = PatientTransfer(
        date=date.today(),
        reason=reason,
        admissionID=admission.id,
        fromBedID=old_bed.id if old_bed else None,
        toBedID=new_bed.id,
    )
    if old_bed:
        old_bed.status = "Free"
    new_bed.status = "Occupied"
    admission.bedID = new_bed.id

    db.session.add(transfer_record)
    try:
        db.session.commit()
    except DBAPIError:
        db.session.rollback()
        flash("The database rejected this transfer — the destination bed may no longer be free.", "error")
        return redirect(url_for("admissions.detail", admission_id=admission_id))

    flash(f"Patient transferred to bed {new_bed.id}.", "success")
    return redirect(url_for("admissions.detail", admission_id=admission_id))
