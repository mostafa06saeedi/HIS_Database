from datetime import date

from flask import render_template, redirect, url_for, flash, request

from app.blueprints.followups import bp
from app.blueprints.followups.forms import FollowUpCreateForm
from app.extensions import db
from app.models import FollowUp, Patient, Employee, Doctor, DoctorDiagnosis, Appointment, Admission


def _patient_choices():
    return [
        (p.nationalID, f"{p.name} ({p.nationalID})")
        for p in Patient.query.order_by(Patient.name).all()
    ]


def _doctor_choices():
    doctors = (
        Employee.query.join(Doctor, Doctor.employeeID == Employee.id)
        .order_by(Employee.name)
        .all()
    )
    return [(e.id, e.name) for e in doctors]


@bp.route("/")
def index():
    """Mirrors vw_DoctorFollowUpQueue but hospital-wide (not filtered to
    the current session's doctor, since there's no login system wired up
    yet — see app/models/auth.py)."""
    scope = request.args.get("scope", "upcoming")
    query = FollowUp.query
    if scope == "upcoming":
        query = query.filter(
            FollowUp.nextFollowUpDate.isnot(None),
            FollowUp.nextFollowUpDate >= date.today(),
        )
    followups = query.order_by(FollowUp.followUpDate.desc()).all()
    return render_template("followups/index.html", followups=followups, scope=scope)


@bp.route("/new", methods=["GET", "POST"])
def create():
    form = FollowUpCreateForm()
    form.patientID.choices = _patient_choices()
    form.employeeID.choices = _doctor_choices()

    patient_id_prefill = request.args.get("patientID")
    all_diagnoses = DoctorDiagnosis.query.all()
    form.doctordiagnosisID.choices = [(0, "— not tied to a specific diagnosis —")] + [
        (d.id, f"{d.icd.code} · {d.icd.name}" if d.icd else f"Diagnosis #{d.id}")
        for d in all_diagnoses
    ]

    if request.method == "GET" and patient_id_prefill:
        form.patientID.data = patient_id_prefill

    if form.validate_on_submit():
        if form.treatmentChanged.data and not form.changeDescription.data:
            flash("changeDescription is required when treatment plan changed.", "error")
            return render_template("followups/form.html", form=form)

        followup = FollowUp(
            patientID=form.patientID.data,
            doctordiagnosisID=form.doctordiagnosisID.data or None,
            employeeID=form.employeeID.data,
            followUpDate=form.followUpDate.data,
            newSymptoms=form.newSymptoms.data,
            progressStatus=form.progressStatus.data or None,
            treatmentChanged=form.treatmentChanged.data,
            changeDescription=form.changeDescription.data,
            nextFollowUpDate=form.nextFollowUpDate.data,
        )
        db.session.add(followup)
        db.session.commit()
        flash("Follow-up recorded.", "success")
        return redirect(url_for("followups.index"))

    return render_template("followups/form.html", form=form)
