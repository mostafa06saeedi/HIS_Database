"""
Module 4 — Staff Management (ISA inheritance)
Mirrors: department, employee, doctor, surgeon, nurse, adminstaff,
         shift, employeeshift
"""
from app.extensions import db


class Department(db.Model):
    __tablename__ = "department"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255))
    type = db.Column(db.String(255))

    employees = db.relationship("Employee", back_populates="department")
    beds = db.relationship("Bed", back_populates="department")


class Employee(db.Model):
    __tablename__ = "employee"

    id = db.Column(db.Integer, primary_key=True)
    departmentID = db.Column(db.Integer, db.ForeignKey("department.id"))
    name = db.Column(db.String(255))
    contractType = db.Column(db.String(255))
    phone = db.Column(db.String(255))
    role = db.Column(db.String(255))
    specialization = db.Column(db.String(255))
    medicalsystemID = db.Column(db.String(255))

    department = db.relationship("Department", back_populates="employees")

    # ISA subtype rows (each optional — a given employee has at most one)
    doctor_profile = db.relationship(
        "Doctor", back_populates="employee", uselist=False
    )
    surgeon_profile = db.relationship(
        "Surgeon", back_populates="employee", uselist=False
    )
    nurse_profile = db.relationship(
        "Nurse", back_populates="employee", uselist=False
    )
    adminstaff_profile = db.relationship(
        "AdminStaff", back_populates="employee", uselist=False
    )

    @property
    def subtype_label(self):
        """Which ISA subtype this employee row belongs to, for display."""
        if self.doctor_profile:
            return "Doctor"
        if self.surgeon_profile:
            return "Surgeon"
        if self.nurse_profile:
            return "Nurse"
        if self.adminstaff_profile:
            return "Admin Staff"
        return "Unassigned"


class Doctor(db.Model):
    __tablename__ = "doctor"

    employeeID = db.Column(db.Integer, db.ForeignKey("employee.id"), primary_key=True)
    specialization = db.Column(db.String(255))
    medicalLicenseNo = db.Column(db.String(255))

    employee = db.relationship("Employee", back_populates="doctor_profile")


class Surgeon(db.Model):
    __tablename__ = "surgeon"

    employeeID = db.Column(db.Integer, db.ForeignKey("employee.id"), primary_key=True)
    surgicalSpecialty = db.Column(db.String(255))

    employee = db.relationship("Employee", back_populates="surgeon_profile")


class Nurse(db.Model):
    __tablename__ = "nurse"

    employeeID = db.Column(db.Integer, db.ForeignKey("employee.id"), primary_key=True)
    grade = db.Column(db.String(255))

    employee = db.relationship("Employee", back_populates="nurse_profile")


class AdminStaff(db.Model):
    __tablename__ = "adminstaff"

    employeeID = db.Column(db.Integer, db.ForeignKey("employee.id"), primary_key=True)
    role = db.Column(db.String(255))

    employee = db.relationship("Employee", back_populates="adminstaff_profile")


class Shift(db.Model):
    __tablename__ = "shift"

    id = db.Column(db.Integer, primary_key=True)
    shiftDate = db.Column(db.Date)
    startTime = db.Column(db.Time)
    endTime = db.Column(db.Time)
    shiftType = db.Column(db.String(255))


class EmployeeShift(db.Model):
    __tablename__ = "employeeshift"

    id = db.Column(db.Integer, primary_key=True)
    employeeID = db.Column(db.Integer, db.ForeignKey("employee.id"))
    shiftID = db.Column(db.Integer, db.ForeignKey("shift.id"))

    employee = db.relationship("Employee")
    shift = db.relationship("Shift")
