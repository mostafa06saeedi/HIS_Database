from flask import render_template, redirect, url_for, flash, request

from app.blueprints.patients import bp
from app.blueprints.patients.forms import PatientForm, MedicalRecordForm
from app.extensions import db
from app.models import (
    Patient,
    Insurance,
    MedicalRecord,
    DoctorDiagnosis,
    Appointment,
    Admission,
    Prescription,
)


def _insurance_choices():
    return [(0, "— none —")] + [
        (i.id, i.name or f"Insurance #{i.id}") for i in Insurance.query.all()
    ]


@bp.route("/")
def index():
    q = request.args.get("q", "").strip()
    query = Patient.query
    if q:
        query = query.filter(
            db.or_(Patient.name.ilike(f"%{q}%"), Patient.nationalID.ilike(f"%{q}%"))
        )
    patients = query.order_by(Patient.name).all()
    return render_template("patients/list.html", patients=patients, q=q)


@bp.route("/new", methods=["GET", "POST"])
def create():
    form = PatientForm()
    form.insuranceID.choices = _insurance_choices()

    if form.validate_on_submit():
        existing = Patient.query.get(form.nationalID.data)
        if existing:
            flash(
                f"A patient with national ID {form.nationalID.data} already exists.",
                "error",
            )
            return render_template("patients/form.html", form=form, patient=None)

        patient = Patient(
            nationalID=form.nationalID.data,
            name=form.name.data,
            datebirth=form.datebirth.data,
            gender=form.gender.data or None,
            phone=form.phone.data,
            address=form.address.data,
            insuranceID=form.insuranceID.data or None,
        )
        db.session.add(patient)
        db.session.commit()
        flash(f"Patient {patient.name} registered.", "success")
        return redirect(url_for("patients.detail", national_id=patient.nationalID))

    return render_template("patients/form.html", form=form, patient=None)


@bp.route("/<national_id>")
def detail(national_id):
    patient = Patient.query.get_or_404(national_id)
    record_form = MedicalRecordForm(obj=patient.medical_record)

    # ICD-coded diagnoses reach the patient through either an appointment
    # or an admission (project spec §2.2 — "diagnoses use standard ICD
    # coding"). Pull both paths together into one chronological list.
    diagnoses = (
        DoctorDiagnosis.query.outerjoin(
            Appointment, DoctorDiagnosis.appointmentID == Appointment.id
        )
        .outerjoin(Admission, DoctorDiagnosis.admissionID == Admission.id)
        .filter(
            db.or_(
                Appointment.patientID == patient.nationalID,
                Admission.patientID == patient.nationalID,
            )
        )
        .all()
    )

    # Drug history (project spec §6 — "the pharmacy can view a patient's
    # drug history").
    prescriptions = (
        Prescription.query.filter_by(patientID=patient.nationalID)
        .order_by(Prescription.date.desc())
        .all()
    )

    return render_template(
        "patients/detail.html",
        patient=patient,
        record_form=record_form,
        diagnoses=diagnoses,
        prescriptions=prescriptions,
    )


@bp.route("/<national_id>/edit", methods=["GET", "POST"])
def edit(national_id):
    patient = Patient.query.get_or_404(national_id)
    form = PatientForm(obj=patient)
    form.insuranceID.choices = _insurance_choices()

    if form.validate_on_submit():
        patient.name = form.name.data
        patient.datebirth = form.datebirth.data
        patient.gender = form.gender.data or None
        patient.phone = form.phone.data
        patient.address = form.address.data
        patient.insuranceID = form.insuranceID.data or None
        db.session.commit()
        flash(f"Patient {patient.name} updated.", "success")
        return redirect(url_for("patients.detail", national_id=patient.nationalID))

    # national ID isn't editable once created (it's the PK)
    form.nationalID.data = patient.nationalID
    return render_template("patients/form.html", form=form, patient=patient)


@bp.route("/<national_id>/medical-record", methods=["POST"])
def save_medical_record(national_id):
    patient = Patient.query.get_or_404(national_id)
    form = MedicalRecordForm()

    if form.validate_on_submit():
        record = patient.medical_record
        if record is None:
            record = MedicalRecord(patientID=patient.nationalID)
            db.session.add(record)
        record.preMedicalRecord = form.preMedicalRecord.data
        record.predrugconsumption = form.predrugconsumption.data
        record.smokingHistory = form.smokingHistory.data or None
        record.weight = form.weight.data
        record.height = form.height.data
        record.bloodpressure = form.bloodpressure.data
        db.session.commit()
        flash("Medical record saved.", "success")
    else:
        flash("Couldn't save medical record — check the values.", "error")

    return redirect(url_for("patients.detail", national_id=national_id))
