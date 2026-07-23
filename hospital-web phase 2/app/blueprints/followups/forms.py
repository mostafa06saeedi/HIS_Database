from flask_wtf import FlaskForm
from wtforms import SelectField, DateField, StringField, BooleanField, SubmitField
from wtforms.validators import DataRequired, Optional, Length


class FollowUpCreateForm(FlaskForm):
    """Same shape as patients/forms.py:FollowUpForm, plus a patient picker
    — used on the hospital-wide Follow-Ups queue where the patient isn't
    already implied by the page. Mirrors sp_AddFollowUp."""
    patientID = SelectField("Patient", validators=[DataRequired()])
    employeeID = SelectField("Doctor conducting follow-up", coerce=int, validators=[DataRequired()])
    doctordiagnosisID = SelectField(
        "Condition being tracked (optional)", coerce=int, validators=[Optional()]
    )
    followUpDate = DateField("Follow-up date", validators=[DataRequired()])
    newSymptoms = StringField("New symptoms", validators=[Optional(), Length(max=255)])
    progressStatus = SelectField(
        "Progress",
        choices=[("", "—"), ("Improving", "Improving"), ("Stable", "Stable"), ("Worsening", "Worsening")],
        validators=[Optional()],
    )
    treatmentChanged = BooleanField("Treatment plan changed")
    changeDescription = StringField(
        "Description of change (required if treatment changed)",
        validators=[Optional(), Length(max=255)],
    )
    nextFollowUpDate = DateField("Next follow-up date", validators=[Optional()])
    submit = SubmitField("Save follow-up")
