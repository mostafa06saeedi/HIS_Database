from flask_wtf import FlaskForm
from wtforms import SelectField, DateField, StringField, SubmitField
from wtforms.validators import DataRequired, Optional, Length


class AdmissionForm(FlaskForm):
    patientID = SelectField("Patient", validators=[DataRequired()])
    bedID = SelectField("Bed", coerce=int, validators=[DataRequired()])
    employeeID = SelectField(
        "Responsible physician", coerce=int, validators=[Optional()]
    )
    entrydate = DateField("Entry date", validators=[DataRequired()])
    reason = StringField("Reason for admission", validators=[Optional(), Length(max=255)])
    submit = SubmitField("Admit patient")


class DischargeForm(FlaskForm):
    exitdate = DateField("Exit date", validators=[DataRequired()])
    submit = SubmitField("Discharge patient")
