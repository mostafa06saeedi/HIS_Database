"""
Module 5 — Lab & Imaging
Mirrors: Labimagingrequest, isCritical, labresult, labalert

Matches the team's actual executed schema (01_schemas.sql): isCritical was
KEPT under its original name (not renamed) — labresult.status tracks
workflow ('Pending'/'Completed'), while clinical severity lives on
labalert.severity ('Normal'/'Moderate'/'Critical'), auto-populated by
trg_labresult_critical_alert.
"""
from app.extensions import db


class IsCritical(db.Model):
    __tablename__ = "isCritical"

    id = db.Column(db.Integer, primary_key=True)
    type = db.Column(db.String(255))
    referenceMin = db.Column(db.Float)
    referenceMax = db.Column(db.Float)
    isCritical_status = db.Column(db.String(255))
    unit = db.Column(db.String(255))


class LabImagingRequest(db.Model):
    __tablename__ = "Labimagingrequest"

    id = db.Column(db.Integer, primary_key=True)
    employeeID = db.Column(db.Integer, db.ForeignKey("employee.id"))
    appointmentID = db.Column(db.Integer, db.ForeignKey("appointment.id"))
    admissionID = db.Column(db.Integer, db.ForeignKey("admission.id"))
    type = db.Column(db.String(255))          # 'Lab' | 'Imaging'
    date = db.Column(db.Date)
    status = db.Column(db.String(255))        # 'Requested' | 'InProgress' | 'Completed'

    employee = db.relationship("Employee")
    appointment = db.relationship("Appointment")
    admission = db.relationship("Admission")
    results = db.relationship("LabResult", back_populates="request")


class LabResult(db.Model):
    __tablename__ = "labresult"

    id = db.Column(db.Integer, primary_key=True)
    reportedbyemployeeID = db.Column(db.Integer, db.ForeignKey("employee.id"))
    isCritical = db.Column(db.Integer, db.ForeignKey("isCritical.id"))
    LabimagingrequestID = db.Column(
        db.Integer, db.ForeignKey("Labimagingrequest.id")
    )
    value = db.Column(db.String(255))
    status = db.Column(db.String(255))   # 'Pending' | 'Completed' — workflow, not severity
    date = db.Column(db.Date)
    description = db.Column(db.String(255))

    reported_by = db.relationship("Employee")
    reference_range = db.relationship("IsCritical")
    request = db.relationship("LabImagingRequest", back_populates="results")
    alerts = db.relationship("LabAlert", back_populates="lab_result")


class LabAlert(db.Model):
    __tablename__ = "labalert"

    id = db.Column(db.Integer, primary_key=True)
    doctorID = db.Column(db.Integer, db.ForeignKey("doctor.employeeID"))
    labResultID = db.Column(db.Integer, db.ForeignKey("labresult.id"))
    severity = db.Column(db.String(255))   # 'Normal' | 'Moderate' | 'Critical'
    status = db.Column(db.String(255))     # 'Unreviewed' | 'ConfirmedByNurse' | 'Resolved'
    createdAt = db.Column(db.Date)
    resolvedAt = db.Column(db.Date)

    doctor = db.relationship("Doctor")
    lab_result = db.relationship("LabResult", back_populates="alerts")
