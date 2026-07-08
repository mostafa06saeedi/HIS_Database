"""
Importing every model module here ensures all mappers are registered
with SQLAlchemy's metadata before db.create_all() or any query runs —
required because our relationships reference each other by string name
across files (e.g. "Employee", "Patient").
"""
from app.models.staff import (
    Department,
    Employee,
    Doctor,
    Surgeon,
    Nurse,
    AdminStaff,
    Shift,
    EmployeeShift,
)
from app.models.patient import (
    Insurance,
    Patient,
    MedicalRecord,
    ICDDisease,
    DoctorDiagnosis,
)
from app.models.clinical import Bed, Appointment, Admission, PatientTransfer
from app.models.lab import LabImagingRequest, IsCritical, LabResult, LabAlert
from app.models.pharmacy import Drug, Prescription, PrescriptionItem, DrugInteraction
from app.models.inventory import Storage, StorageTransaction
from app.models.financial import PaymentMethod, Invoice, InvoiceItem, Payment
from app.models.auth import UserAccount
from app.models.iot import (
    IoTDevice,
    DeviceTransfer,
    Log,
    AlertThreshold,
    Alert,
)

__all__ = [
    "Department", "Employee", "Doctor", "Surgeon", "Nurse", "AdminStaff",
    "Shift", "EmployeeShift",
    "Insurance", "Patient", "MedicalRecord", "ICDDisease", "DoctorDiagnosis",
    "Bed", "Appointment", "Admission", "PatientTransfer",
    "LabImagingRequest", "IsCritical", "LabResult", "LabAlert",
    "Drug", "Prescription", "PrescriptionItem", "DrugInteraction",
    "Storage", "StorageTransaction",
    "PaymentMethod", "Invoice", "InvoiceItem", "Payment",
    "UserAccount",
    "IoTDevice", "DeviceTransfer", "Log", "AlertThreshold", "Alert",
]
