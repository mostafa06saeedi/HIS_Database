"""
Module 2 — Admissions & Appointments
Module 3 — Hospital Resources
Mirrors: appointment, bed, admission, patienttransfer

Phase 2 (§3 — service quality KPIs) extends [appointment] with three
nullable timestamps rather than a new table (checkInTime, serviceStartTime,
checkOutTime) — see phase2_schemas.sql. wait_minutes below mirrors
fn_CalculateWaitMinutes for use when the app isn't running against the
real SQL Server (e.g. the SQLite smoketest fallback).
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

    # Phase 2 (§3 — wait-time / visit-duration KPIs)
    checkInTime = db.Column(db.DateTime)       # actual arrival/check-in
    serviceStartTime = db.Column(db.DateTime)  # doctor actually started seeing patient
    checkOutTime = db.Column(db.DateTime)      # visit ended

    patient = db.relationship("Patient", back_populates="appointments")
    employee = db.relationship("Employee")
    department = db.relationship("Department")
    diagnoses = db.relationship("DoctorDiagnosis", back_populates="appointment")
    admission = db.relationship(
        "Admission", back_populates="appointment", uselist=False
    )
    followups = db.relationship("FollowUp", back_populates="appointment")

    @property
    def wait_minutes(self):
        """Mirrors fn_CalculateWaitMinutes: check-in -> service start, in minutes."""
        if not self.checkInTime or not self.serviceStartTime:
            return None
        delta = self.serviceStartTime - self.checkInTime
        return int(delta.total_seconds() // 60)

    @property
    def visit_minutes(self):
        if not self.serviceStartTime or not self.checkOutTime:
            return None
        delta = self.checkOutTime - self.serviceStartTime
        return int(delta.total_seconds() // 60)


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

    # Phase 2 (§4 — resource optimization: a surgery may be tied to a stay)
    surgeries = db.relationship("SurgeryRecord", back_populates="admission")

    @property
    def is_active(self):
        return self.exitdate is None

    @property
    def length_of_stay_days(self):
        """Mirrors fn_CalculateLengthOfStay."""
        from datetime import date
        end = self.exitdate or date.today()
        if not self.entrydate:
            return None
        return (end - self.entrydate).days

    @property
    def is_readmission_30day(self):
        """Mirrors fn_IsReadmission30Day for the SQLite/offline fallback."""
        if not self.entrydate:
            return False
        for other in self.patient.admissions if self.patient else []:
            if other.id == self.id or not other.exitdate:
                continue
            if other.exitdate < self.entrydate and (self.entrydate - other.exitdate).days <= 30:
                return True
        return False


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
