from flask_wtf import FlaskForm
from wtforms import (
    StringField,
    DateField,
    SelectField,
    FloatField,
    TextAreaField,
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
