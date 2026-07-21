from datetime import date

from flask import render_template, redirect, url_for, flash, request

from app.blueprints.patients import bp
from app.blueprints.patients.forms import (
    PatientForm,
    MedicalRecordForm,
    PatientAllergyForm,
    FollowUpForm,
    TreatmentOutcomeForm,
)
from app.extensions import db
from app.models import (
    Patient,
    Insurance,
    MedicalRecord,
    DoctorDiagnosis,
    Appointment,
    Admission,
    Prescription,
    Drug,
    Employee,
    Doctor,
    ICDDisease,
    PatientAllergy,
    FollowUp,
    TreatmentOutcome,
)


def _insurance_choices():
    return [(0, "— none —")] + [
        (i.id, i.name or f"Insurance #{i.id}") for i in Insurance.query.all()
    ]


def _drug_choices():
    return [(0, "— not a catalogued drug —")] + [
        (d.id, d.name or f"Drug #{d.id}") for d in Drug.query.order_by(Drug.name).all()
    ]


def _doctor_choices(allow_blank=True):
    doctors = (
        Employee.query.join(Doctor, Doctor.employeeID == Employee.id)
        .order_by(Employee.name)
        .all()
    )
    choices = [(e.id, e.name) for e in doctors]
    if allow_blank:
        choices = [(0, "— unspecified —")] + choices
    return choices


def _icd_choices():
    return [(0, "— none —")] + [
        (d.id, f"{d.code} · {d.name}") for d in ICDDisease.query.order_by(ICDDisease.code).all()
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

    # ---- Phase 2 additions ----
    allergy_form = PatientAllergyForm()
    allergy_form.drugID.choices = _drug_choices()

    followup_form = FollowUpForm()
    followup_form.employeeID.choices = _doctor_choices(allow_blank=False)
    followup_form.doctordiagnosisID.choices = [(0, "— not tied to a specific diagnosis —")] + [
        (d.id, f"{d.icd.code} · {d.icd.name}" if d.icd else f"Diagnosis #{d.id}")
        for d in diagnoses
    ]

    outcome_form = TreatmentOutcomeForm()
    outcome_form.complicationICD_ID.choices = _icd_choices()
    outcome_form.evaluatedbyemployeeID.choices = _doctor_choices()

    allergies = (
        PatientAllergy.query.filter_by(patientID=patient.nationalID)
        .order_by(PatientAllergy.recordedDate.desc())
        .all()
    )
    followups = (
        FollowUp.query.filter_by(patientID=patient.nationalID)
        .order_by(FollowUp.followUpDate.desc())
        .all()
    )
    outcomes_by_diagnosis = {
        d.id: TreatmentOutcome.query.filter_by(doctordiagnosisID=d.id)
        .order_by(TreatmentOutcome.evaluatedDate.desc())
        .all()
        for d in diagnoses
    }

    return render_template(
        "patients/detail.html",
        patient=patient,
        record_form=record_form,
        diagnoses=diagnoses,
        prescriptions=prescriptions,
        allergy_form=allergy_form,
        followup_form=followup_form,
        outcome_form=outcome_form,
        allergies=allergies,
        followups=followups,
        outcomes_by_diagnosis=outcomes_by_diagnosis,
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


# ---------------------------------------------------------------------------
# Phase 2 routes
# ---------------------------------------------------------------------------

@bp.route("/<national_id>/allergies", methods=["POST"])
def add_allergy(national_id):
    """Mirrors sp_RecordPatientAllergy (§5 — clinical decision support).
    Every prescription item is later checked against this list live by
    trg_prescriptionitem_safety_check."""
    patient = Patient.query.get_or_404(national_id)
    form = PatientAllergyForm()
    form.drugID.choices = _drug_choices()

    if form.validate_on_submit():
        if not form.drugID.data and not form.substanceName.data:
            flash("Give either a catalogued drug or a substance name.", "error")
            return redirect(url_for("patients.detail", national_id=national_id))

        allergy = PatientAllergy(
            patientID=patient.nationalID,
            drugID=form.drugID.data or None,
            substanceName=form.substanceName.data or None,
            severity=form.severity.data,
            reaction=form.reaction.data,
            recordedDate=date.today(),
        )
        db.session.add(allergy)
        db.session.commit()
        flash("Allergy recorded.", "success")
    else:
        flash("Couldn't record allergy — check the values.", "error")

    return redirect(url_for("patients.detail", national_id=national_id))


@bp.route("/<national_id>/followups", methods=["POST"])
def add_followup(national_id):
    """Mirrors sp_AddFollowUp (§2 — patient follow-up tracking). Enforces
    the same rule as the stored procedure: a change description is
    required whenever the treatment plan was actually changed."""
    patient = Patient.query.get_or_404(national_id)
    form = FollowUpForm()
    form.employeeID.choices = _doctor_choices(allow_blank=False)
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
    form.doctordiagnosisID.choices = [(0, "— not tied to a specific diagnosis —")] + [
        (d.id, f"{d.icd.code} · {d.icd.name}" if d.icd else f"Diagnosis #{d.id}")
        for d in diagnoses
    ]

    if form.validate_on_submit():
        if form.treatmentChanged.data and not form.changeDescription.data:
            flash("changeDescription is required when treatment plan changed.", "error")
            return redirect(url_for("patients.detail", national_id=national_id))

        followup = FollowUp(
            patientID=patient.nationalID,
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
    else:
        flash("Couldn't record follow-up — check the values.", "error")

    return redirect(url_for("patients.detail", national_id=national_id))


@bp.route("/<national_id>/diagnoses/<int:diagnosis_id>/outcome", methods=["POST"])
def add_outcome(national_id, diagnosis_id):
    """Mirrors sp_RecordTreatmentOutcome (§1 — treatment/outcome analysis).
    Recorded per diagnosed condition so effectiveness/relapse can later
    be analyzed per disease (vw_TreatmentEffectiveness)."""
    diagnosis = DoctorDiagnosis.query.get_or_404(diagnosis_id)
    form = TreatmentOutcomeForm()
    form.complicationICD_ID.choices = _icd_choices()
    form.evaluatedbyemployeeID.choices = _doctor_choices()

    if form.validate_on_submit():
        outcome = TreatmentOutcome(
            doctordiagnosisID=diagnosis.id,
            outcomeStatus=form.outcomeStatus.data,
            complicationICD_ID=form.complicationICD_ID.data or None,
            complicationNote=form.complicationNote.data,
            evaluatedDate=date.today(),
            evaluatedbyemployeeID=form.evaluatedbyemployeeID.data or None,
        )
        db.session.add(outcome)
        db.session.commit()
        flash("Treatment outcome recorded.", "success")
    else:
        flash("Couldn't record outcome — check the values.", "error")

    return redirect(url_for("patients.detail", national_id=national_id))
