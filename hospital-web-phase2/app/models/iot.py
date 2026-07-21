"""
Module 9 — IoT & Smart Alerts
Mirrors: iotdevice, devicetransfer, logs, AlertThreshold, alert
"""
from app.extensions import db


class IoTDevice(db.Model):
    __tablename__ = "iotdevice"

    id = db.Column(db.Integer, primary_key=True)
    macaddress = db.Column(db.String(255))
    type = db.Column(db.String(255))
    status = db.Column(db.String(255))  # active / inactive / under repair
    installationdate = db.Column(db.Date)

    transfers = db.relationship("DeviceTransfer", back_populates="device")
    logs = db.relationship("Log", back_populates="device")


class DeviceTransfer(db.Model):
    __tablename__ = "devicetransfer"

    id = db.Column(db.Integer, primary_key=True)
    patientID = db.Column(db.String(255), db.ForeignKey("patient.nationalID"))
    admissionID = db.Column(db.Integer, db.ForeignKey("admission.id"))
    departmentID = db.Column(db.Integer, db.ForeignKey("department.id"))
    bedID = db.Column(db.Integer, db.ForeignKey("bed.id"))
    iotdeviceID = db.Column(db.Integer, db.ForeignKey("iotdevice.id"))
    assignedAt = db.Column(db.Date)
    unassignedAt = db.Column(db.Date)

    patient = db.relationship("Patient")
    admission = db.relationship("Admission")
    department = db.relationship("Department")
    bed = db.relationship("Bed")
    device = db.relationship("IoTDevice", back_populates="transfers")

    @property
    def is_active(self):
        return self.unassignedAt is None


class Log(db.Model):
    __tablename__ = "logs"

    id = db.Column(db.Integer, primary_key=True)
    deviceID = db.Column(db.Integer, db.ForeignKey("iotdevice.id"))
    timestamp = db.Column(db.DateTime)
    type = db.Column(db.String(255))  # HR, SpO2, temperature, humidity, weight...
    value = db.Column(db.Float)
    unit = db.Column(db.String(255))

    device = db.relationship("IoTDevice", back_populates="logs")
    alerts = db.relationship("Alert", back_populates="log")


class AlertThreshold(db.Model):
    __tablename__ = "AlertThreshold"

    id = db.Column(db.Integer, primary_key=True)
    measurementType = db.Column(db.String(255))
    minValue = db.Column(db.Float)
    maxValue = db.Column(db.Float)
    severity = db.Column(db.String(255))
    isGlobal = db.Column(db.Boolean)
    employeeID = db.Column(db.Integer, db.ForeignKey("employee.id"))
    patientID = db.Column(db.String(255), db.ForeignKey("patient.nationalID"))
    createdate = db.Column(db.Date)

    employee = db.relationship("Employee")
    patient = db.relationship("Patient")
    alerts = db.relationship("Alert", back_populates="threshold")


class Alert(db.Model):
    __tablename__ = "alert"

    id = db.Column(db.Integer, primary_key=True)
    logID = db.Column(db.Integer, db.ForeignKey("logs.id"))
    alertThresholdID = db.Column(db.Integer, db.ForeignKey("AlertThreshold.id"))
    acknowledgedbyemployeeID = db.Column(db.Integer, db.ForeignKey("employee.id"))
    severity = db.Column(db.String(255))
    status = db.Column(db.String(255))  # unreviewed / acknowledged / resolved
    createdtime = db.Column(db.DateTime)
    resolvedtime = db.Column(db.DateTime)

    log = db.relationship("Log", back_populates="alerts")
    threshold = db.relationship("AlertThreshold", back_populates="alerts")
    acknowledged_by = db.relationship("Employee")
