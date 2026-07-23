"""
Login system — mirrors: UserAccount

Not currently wired into Flask (no login UI yet — see CHANGES.md for how
this would connect: a Flask login route calling sp_Login, storing
role/patientID/employeeID in Flask's session, optionally re-asserting
that identity into SESSION_CONTEXT on the DB connection per request so
the vw_My*/vw_Doctor*/vw_Nurse* views in 05_views.sql filter correctly).
Modeled here so the table isn't invisible to the ORM if/when that's built.
"""
from app.extensions import db


class UserAccount(db.Model):
    __tablename__ = "UserAccount"

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(100), unique=True)
    passwordHash = db.Column(db.LargeBinary(64))
    passwordSalt = db.Column(db.String(36))  # GUID as text — portable across SQL Server / SQLite
    role = db.Column(db.String(50))  # Patient|Doctor|Nurse|Pharmacist|LabTech|Reception|Manager
    patientID = db.Column(db.String(255), db.ForeignKey("patient.nationalID"))
    employeeID = db.Column(db.Integer, db.ForeignKey("employee.id"))
    isActive = db.Column(db.Boolean)
    createdAt = db.Column(db.DateTime)
    lastLoginAt = db.Column(db.DateTime)

    patient = db.relationship("Patient")
    employee = db.relationship("Employee")
