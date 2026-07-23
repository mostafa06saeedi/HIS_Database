"""
Module 6 — Pharmacy & Electronic Prescriptions
Mirrors: prescription, drug, prescriptionitem
"""
from app.extensions import db


class Drug(db.Model):
    __tablename__ = "drug"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255))
    type = db.Column(db.String(255))
    description = db.Column(db.String(255))


class Prescription(db.Model):
    __tablename__ = "prescription"

    id = db.Column(db.Integer, primary_key=True)
    patientID = db.Column(db.String(255), db.ForeignKey("patient.nationalID"))
    employeeID = db.Column(db.Integer, db.ForeignKey("employee.id"))
    appointmentID = db.Column(db.Integer, db.ForeignKey("appointment.id"))
    admissionID = db.Column(db.Integer, db.ForeignKey("admission.id"))
    date = db.Column(db.Date)
    status = db.Column(db.String(255))

    patient = db.relationship("Patient")
    employee = db.relationship("Employee")
    appointment = db.relationship("Appointment")
    admission = db.relationship("Admission")
    items = db.relationship("PrescriptionItem", back_populates="prescription")


class PrescriptionItem(db.Model):
    __tablename__ = "prescriptionitem"

    id = db.Column(db.Integer, primary_key=True)
    prescriptionID = db.Column(db.Integer, db.ForeignKey("prescription.id"))
    drugID = db.Column(db.Integer, db.ForeignKey("drug.id"))
    dose = db.Column(db.String(255))
    duration = db.Column(db.String(255))
    quantity = db.Column(db.Integer)

    prescription = db.relationship("Prescription", back_populates="items")
    drug = db.relationship("Drug")

    # Phase 2 (§5 — clinical decision support: interaction/allergy alerts)
    safety_alerts = db.relationship("PrescriptionSafetyAlert", back_populates="item")


class DrugInteraction(db.Model):
    """Matches the real schema: drugID1/drugID2, severity Minor|Moderate|Severe.
    A generated pair (drugPairLow, drugPairHigh) + unique index in the DB
    blocks reversed-order duplicates — not modeled here since Flask never
    needs to read those two columns directly."""
    __tablename__ = "druginteraction"

    id = db.Column(db.Integer, primary_key=True)
    drugID1 = db.Column(db.Integer, db.ForeignKey("drug.id"))
    drugID2 = db.Column(db.Integer, db.ForeignKey("drug.id"))
    severity = db.Column(db.String(50))   # Minor | Moderate | Severe
    description = db.Column(db.String(255))

    drug_a = db.relationship("Drug", foreign_keys=[drugID1])
    drug_b = db.relationship("Drug", foreign_keys=[drugID2])
