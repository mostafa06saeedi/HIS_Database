from flask_wtf import FlaskForm
from wtforms import (
    StringField,
    DateField,
    SelectField,
    FloatField,
    TextAreaField,
    BooleanField,
    SubmitField,
)
from wtforms.validators import DataRequired, Optional, Length


class PatientForm(FlaskForm):
    nationalID = StringField(
        "National ID", validators=[DataRequired(), Length(max=255)]
    )
    name = StringField("Full name", validators=[DataRequired(), Length(max=255)])
    datebirth = DateField("Date of birth", validators=[Optional()])
    gender = SelectField(
        "Gender",
        choices=[("", "—"), ("Male", "مرد (Male)"), ("زن", "زن (Female)")],
        validators=[Optional()],
    )
    phone = StringField("Phone", validators=[Optional(), Length(max=255)])
    address = StringField("Address", validators=[Optional(), Length(max=255)])
    insuranceID = SelectField("Insurance plan", coerce=int, validators=[Optional()])
    submit = SubmitField("Save patient")


class MedicalRecordForm(FlaskForm):
    preMedicalRecord = TextAreaField("Prior conditions", validators=[Optional()])
    predrugconsumption = TextAreaField(
        "Prior drug consumption", validators=[Optional()]
    )
    smokingHistory = SelectField(
        "Smoking history",
        choices=[("", "—"), ("never", "Never"), ("former", "Former"), ("current", "Current")],
        validators=[Optional()],
    )
    weight = FloatField("Weight (kg)", validators=[Optional()])
    height = FloatField("Height (cm)", validators=[Optional()])
    bloodpressure = StringField(
        "Blood pressure", validators=[Optional(), Length(max=255)]
    )
    submit_record = SubmitField("Save medical record")


# ---------------------------------------------------------------------------
# Phase 2 forms
# ---------------------------------------------------------------------------

class PatientAllergyForm(FlaskForm):
    """§5 — clinical decision support. Either drugID or substanceName must
    be given (mirrors CK_patientallergy_source / sp_RecordPatientAllergy)."""
    drugID = SelectField("Catalogued drug", coerce=int, validators=[Optional()])
    substanceName = StringField(
        "Substance (if not a catalogued drug)", validators=[Optional(), Length(max=255)]
    )
    severity = SelectField(
        "Severity",
        choices=[("Mild", "Mild"), ("Moderate", "Moderate"), ("Severe", "Severe")],
        validators=[DataRequired()],
    )
    reaction = StringField("Reaction", validators=[Optional(), Length(max=255)])
    submit_allergy = SubmitField("Record allergy")


class FollowUpForm(FlaskForm):
    """§2 — patient follow-up / treatment tracking."""
    employeeID = SelectField("Doctor conducting follow-up", coerce=int, validators=[DataRequired()])
    doctordiagnosisID = SelectField(
        "Condition being tracked (optional)", coerce=int, validators=[Optional()]
    )
    followUpDate = DateField("Follow-up date", validators=[DataRequired()])
    newSymptoms = StringField("New symptoms", validators=[Optional(), Length(max=255)])
    progressStatus = SelectField(
        "Progress",
        choices=[("Improving", "Improving"), ("Stable", "Stable"), ("Worsening", "Worsening")],
        validators=[Optional()],
    )
    treatmentChanged = BooleanField("Treatment plan changed")
    changeDescription = StringField(
        "Description of change (required if treatment changed)",
        validators=[Optional(), Length(max=255)],
    )
    nextFollowUpDate = DateField("Next follow-up date", validators=[Optional()])
    submit_followup = SubmitField("Save follow-up")


class TreatmentOutcomeForm(FlaskForm):
    """§1 — treatment outcome, recorded per diagnosed condition."""
    outcomeStatus = SelectField(
        "Outcome",
        choices=[
            ("Recovered", "Recovered"),
            ("Improved", "Improved"),
            ("Unchanged", "Unchanged"),
            ("Worsened", "Worsened"),
            ("Relapsed", "Relapsed"),
            ("Deceased", "Deceased"),
            ("ReferredOut", "Referred out"),
        ],
        validators=[DataRequired()],
    )
    complicationICD_ID = SelectField(
        "Complication (ICD, optional)", coerce=int, validators=[Optional()]
    )
    complicationNote = StringField(
        "Complication note (free text)", validators=[Optional(), Length(max=255)]
    )
    evaluatedbyemployeeID = SelectField(
        "Evaluated by", coerce=int, validators=[Optional()]
    )
    submit_outcome = SubmitField("Record outcome")
