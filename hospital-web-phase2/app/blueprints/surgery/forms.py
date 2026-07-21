from flask_wtf import FlaskForm
from wtforms import SelectField, StringField, DateTimeField, SubmitField
from wtforms.validators import DataRequired, Optional, Length


class ScheduleSurgeryForm(FlaskForm):
    """Mirrors sp_ScheduleSurgery (Phase 2 §4 — resource optimization)."""
    operatingRoomID = SelectField("Operating room", coerce=int, validators=[DataRequired()])
    patientID = SelectField("Patient", validators=[DataRequired()])
    admissionID = SelectField(
        "Linked admission (optional)", coerce=int, validators=[Optional()]
    )
    surgeonID = SelectField("Surgeon", coerce=int, validators=[Optional()])
    procedureName = StringField("Procedure", validators=[Optional(), Length(max=255)])
    scheduledStart = DateTimeField(
        "Scheduled start", format="%Y-%m-%dT%H:%M", validators=[DataRequired()]
    )
    submit = SubmitField("Schedule surgery")
