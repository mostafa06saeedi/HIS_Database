"""
Module 1 — Patient Management
Mirrors: patient, medicalrecord, insurance, icddisease, doctordiagnosis
"""
from app.extensions import db


class Insurance(db.Model):
    __tablename__ = "insurance"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255))
    type = db.Column(db.String(255))
    coveragepercent = db.Column(db.Float)
    isActive = db.Column(db.Boolean)

    patients = db.relationship("Patient", back_populates="insurance")


class Patient(db.Model):
    __tablename__ = "patient"

    nationalID = db.Column(db.String(255), primary_key=True)
    insuranceID = db.Column(db.Integer, db.ForeignKey("insurance.id"))
    name = db.Column(db.String(255))
    datebirth = db.Column(db.Date)
    gender = db.Column(db.String(255))
    phone = db.Column(db.String(255))
    address = db.Column(db.String(255))

    insurance = db.relationship("Insurance", back_populates="patients")
    medical_record = db.relationship(
        "MedicalRecord", back_populates="patient", uselist=False
    )
    appointments = db.relationship("Appointment", back_populates="patient")
    admissions = db.relationship("Admission", back_populates="patient")

    @property
    def age(self):
        if not self.datebirth:
            return None
        from datetime import date
        today = date.today()
        return today.year - self.datebirth.year - (
            (today.month, today.day) < (self.datebirth.month, self.datebirth.day)
        )


class MedicalRecord(db.Model):
    __tablename__ = "medicalrecord"

    id = db.Column(db.Integer, primary_key=True)
    patientID = db.Column(
        db.String(255), db.ForeignKey("patient.nationalID"), unique=True
    )
    preMedicalRecord = db.Column(db.String(255))
    predrugconsumption = db.Column(db.String(255))
    smokingHistory = db.Column(db.String(255))  # never | former | current — §2.2
    weight = db.Column(db.Float)
    height = db.Column(db.Float)
    bloodpressure = db.Column(db.String(255))

    patient = db.relationship("Patient", back_populates="medical_record")


class ICDDisease(db.Model):
    __tablename__ = "icddisease"

    id = db.Column(db.Integer, primary_key=True)
    code = db.Column(db.String(255))
    name = db.Column(db.String(255))


class DoctorDiagnosis(db.Model):
    __tablename__ = "doctordiagnosis"

    id = db.Column(db.Integer, primary_key=True)
    appointmentID = db.Column(db.Integer, db.ForeignKey("appointment.id"))
    admissionID = db.Column(db.Integer, db.ForeignKey("admission.id"))
    icdID = db.Column(db.Integer, db.ForeignKey("icddisease.id"))
    description = db.Column(db.String(255))

    icd = db.relationship("ICDDisease")
    appointment = db.relationship("Appointment", back_populates="diagnoses")
    admission = db.relationship("Admission", back_populates="diagnoses")
