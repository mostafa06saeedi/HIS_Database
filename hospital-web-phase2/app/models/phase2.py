"""
Phase 2 — Analysis & Smart Features (تحلیل و هوشمندسازی)
Mirrors: treatmentoutcome, followup, operatingroom, surgeryrecord,
         patientallergy, prescriptionsafetyalert, dailydepartmentstats

This module is purely additive on top of Phase 1's models — see
phase2_schemas.sql. Nothing here redefines a Phase 1 table; [appointment]
only gained three nullable columns, added directly in models/clinical.py.
"""
from app.extensions import db


class TreatmentOutcome(db.Model):
    """§1 — Treatment/outcome tracking, one row per evaluation of a
    diagnosed condition (Recovered/Improved/Unchanged/Worsened/Relapsed/
    Deceased/ReferredOut). Powers vw_TreatmentEffectiveness."""
    __tablename__ = "treatmentoutcome"

    id = db.Column(db.Integer, primary_key=True)
    doctordiagnosisID = db.Column(db.Integer, db.ForeignKey("doctordiagnosis.id"))
    outcomeStatus = db.Column(db.String(255))
    complicationICD_ID = db.Column(db.Integer, db.ForeignKey("icddisease.id"))
    complicationNote = db.Column(db.String(255))
    evaluatedDate = db.Column(db.Date)
    evaluatedbyemployeeID = db.Column(db.Integer, db.ForeignKey("employee.id"))

    diagnosis = db.relationship("DoctorDiagnosis", back_populates="outcomes")
    complication_icd = db.relationship("ICDDisease", foreign_keys=[complicationICD_ID])
    evaluated_by = db.relationship("Employee", foreign_keys=[evaluatedbyemployeeID])


class FollowUp(db.Model):
    """§2 — Patient follow-up / treatment monitoring over time."""
    __tablename__ = "followup"

    id = db.Column(db.Integer, primary_key=True)
    patientID = db.Column(db.String(255), db.ForeignKey("patient.nationalID"))
    doctordiagnosisID = db.Column(db.Integer, db.ForeignKey("doctordiagnosis.id"))
    appointmentID = db.Column(db.Integer, db.ForeignKey("appointment.id"))
    employeeID = db.Column(db.Integer, db.ForeignKey("employee.id"))
    followUpDate = db.Column(db.Date)
    newSymptoms = db.Column(db.String(255))
    progressStatus = db.Column(db.String(255))  # Improving | Stable | Worsening
    treatmentChanged = db.Column(db.Boolean)
    changeDescription = db.Column(db.String(255))
    nextFollowUpDate = db.Column(db.Date)

    patient = db.relationship("Patient", back_populates="followups")
    diagnosis = db.relationship("DoctorDiagnosis", back_populates="followups")
    appointment = db.relationship("Appointment", back_populates="followups")
    employee = db.relationship("Employee")


class OperatingRoom(db.Model):
    """§4 — Resource optimization: operating rooms as a bookable resource."""
    __tablename__ = "operatingroom"

    id = db.Column(db.Integer, primary_key=True)
    departmentID = db.Column(db.Integer, db.ForeignKey("department.id"))
    roomNumber = db.Column(db.String(255))
    status = db.Column(db.String(255))  # Free | Occupied | UnderMaintenance

    department = db.relationship("Department")
    surgeries = db.relationship("SurgeryRecord", back_populates="operating_room")


class SurgeryRecord(db.Model):
    """§4 — A single scheduled/performed surgery, timed for OR-utilization
    reporting (fn_GetORUtilizationPercent)."""
    __tablename__ = "surgeryrecord"

    id = db.Column(db.Integer, primary_key=True)
    operatingRoomID = db.Column(db.Integer, db.ForeignKey("operatingroom.id"))
    patientID = db.Column(db.String(255), db.ForeignKey("patient.nationalID"))
    admissionID = db.Column(db.Integer, db.ForeignKey("admission.id"))
    surgeonID = db.Column(db.Integer, db.ForeignKey("surgeon.employeeID"))
    procedureName = db.Column(db.String(255))
    scheduledStart = db.Column(db.DateTime)
    actualStart = db.Column(db.DateTime)
    actualEnd = db.Column(db.DateTime)
    status = db.Column(db.String(255))  # Scheduled | InProgress | Completed | Cancelled

    operating_room = db.relationship("OperatingRoom", back_populates="surgeries")
    patient = db.relationship("Patient")
    admission = db.relationship("Admission", back_populates="surgeries")
    surgeon = db.relationship("Surgeon")

    @property
    def duration_minutes(self):
        if not self.actualStart or not self.actualEnd:
            return None
        return int((self.actualEnd - self.actualStart).total_seconds() // 60)


class PatientAllergy(db.Model):
    """§5 — Recorded patient allergies (catalogued drug or free-text
    substance). Checked live by trg_prescriptionitem_safety_check."""
    __tablename__ = "patientallergy"

    id = db.Column(db.Integer, primary_key=True)
    patientID = db.Column(db.String(255), db.ForeignKey("patient.nationalID"))
    drugID = db.Column(db.Integer, db.ForeignKey("drug.id"))
    substanceName = db.Column(db.String(255))
    severity = db.Column(db.String(255))  # Mild | Moderate | Severe
    reaction = db.Column(db.String(255))
    recordedDate = db.Column(db.Date)

    patient = db.relationship("Patient", back_populates="allergies")
    drug = db.relationship("Drug")


class PrescriptionSafetyAlert(db.Model):
    """§5 — Interaction/allergy alerts logged by
    trg_prescriptionitem_safety_check. Powers vw_PendingSafetyAlerts."""
    __tablename__ = "prescriptionsafetyalert"

    id = db.Column(db.Integer, primary_key=True)
    prescriptionItemID = db.Column(db.Integer, db.ForeignKey("prescriptionitem.id"))
    alertType = db.Column(db.String(255))       # DrugInteraction | Allergy
    relatedDrugID = db.Column(db.Integer, db.ForeignKey("drug.id"))
    severity = db.Column(db.String(255))        # Minor | Moderate | Severe
    message = db.Column(db.String(255))
    createdAt = db.Column(db.DateTime)
    acknowledgedbyemployeeID = db.Column(db.Integer, db.ForeignKey("employee.id"))
    acknowledgedAt = db.Column(db.DateTime)

    item = db.relationship("PrescriptionItem", back_populates="safety_alerts")
    related_drug = db.relationship("Drug", foreign_keys=[relatedDrugID])
    acknowledged_by = db.relationship("Employee", foreign_keys=[acknowledgedbyemployeeID])


class DailyDepartmentStats(db.Model):
    """§6 — Pre-computed daily snapshot per department (aggregated table),
    rebuilt by sp_RefreshDailyDepartmentStats so dashboards don't re-scan
    admission/appointment directly."""
    __tablename__ = "dailydepartmentstats"

    id = db.Column(db.Integer, primary_key=True)
    statDate = db.Column(db.Date)
    departmentID = db.Column(db.Integer, db.ForeignKey("department.id"))
    totalBeds = db.Column(db.Integer)
    occupiedBeds = db.Column(db.Integer)
    occupancyPercent = db.Column(db.Float)
    newAdmissions = db.Column(db.Integer)
    discharges = db.Column(db.Integer)
    appointmentsCount = db.Column(db.Integer)
    avgWaitMinutes = db.Column(db.Float)

    department = db.relationship("Department")
