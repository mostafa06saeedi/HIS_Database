"""
Module 2 — Admissions & Appointments
Module 3 — Hospital Resources
Mirrors: appointment, bed, admission, patienttransfer
"""
from app.extensions import db


class Bed(db.Model):
    __tablename__ = "bed"

    id = db.Column(db.Integer, primary_key=True)
    departmentID = db.Column(db.Integer, db.ForeignKey("department.id"))
    status = db.Column(db.String(255))  # free / reserved / occupied
    room = db.Column(db.String(255))

    department = db.relationship("Department", back_populates="beds")
    admissions = db.relationship(
        "Admission", back_populates="bed", foreign_keys="Admission.bedID"
    )


class Appointment(db.Model):
    __tablename__ = "appointment"

    id = db.Column(db.Integer, primary_key=True)
    employeeID = db.Column(db.Integer, db.ForeignKey("employee.id"))
    patientID = db.Column(db.String(255), db.ForeignKey("patient.nationalID"))
    departmentID = db.Column(db.Integer, db.ForeignKey("department.id"))
    date = db.Column(db.Date)
    time = db.Column(db.Time)
    status = db.Column(db.String(255))
    appointment_type = db.Column(db.String(255))

    patient = db.relationship("Patient", back_populates="appointments")
    employee = db.relationship("Employee")
    department = db.relationship("Department")
    diagnoses = db.relationship("DoctorDiagnosis", back_populates="appointment")
    admission = db.relationship(
        "Admission", back_populates="appointment", uselist=False
    )


class Admission(db.Model):
    __tablename__ = "admission"

    id = db.Column(db.Integer, primary_key=True)
    patientID = db.Column(db.String(255), db.ForeignKey("patient.nationalID"))
    bedID = db.Column(db.Integer, db.ForeignKey("bed.id"))
    employeeID = db.Column(db.Integer, db.ForeignKey("employee.id"))
    appointmentID = db.Column(db.Integer, db.ForeignKey("appointment.id"))
    entrydate = db.Column(db.Date)
    exitdate = db.Column(db.Date)
    reason = db.Column(db.String(255))

    patient = db.relationship("Patient", back_populates="admissions")
    bed = db.relationship("Bed", back_populates="admissions", foreign_keys=[bedID])
    employee = db.relationship("Employee")
    appointment = db.relationship("Appointment", back_populates="admission")
    diagnoses = db.relationship("DoctorDiagnosis", back_populates="admission")

    @property
    def is_active(self):
        return self.exitdate is None


class PatientTransfer(db.Model):
    __tablename__ = "patienttransfer"

    id = db.Column(db.Integer, primary_key=True)
    date = db.Column(db.Date)
    time = db.Column(db.Time)
    reason = db.Column(db.String(255))
    admissionID = db.Column(db.Integer, db.ForeignKey("admission.id"))
    fromBedID = db.Column(db.Integer, db.ForeignKey("bed.id"))
    toBedID = db.Column(db.Integer, db.ForeignKey("bed.id"))

    admission = db.relationship("Admission")
    from_bed = db.relationship("Bed", foreign_keys=[fromBedID])
    to_bed = db.relationship("Bed", foreign_keys=[toBedID])
