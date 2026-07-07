"""
Smoke test: boots the app against a throwaway SQLite file (standing in
for SQL Server), seeds one row per table using the REAL enum values from
01_schemas.sql's CHECK constraints, then hits every route with Flask's
test client. This does NOT touch the real MSSQL config.
"""
import os
import sys
from datetime import date, datetime, time

_db_path = os.path.join(os.getcwd(), "smoketest.db")
os.environ["DATABASE_URL"] = f"sqlite:///{_db_path}"
if os.path.exists(_db_path):
    os.remove(_db_path)
for stray in (os.path.join(os.getcwd(), "instance", "smoketest.db"),):
    if os.path.exists(stray):
        os.remove(stray)

sys.path.insert(0, os.getcwd())

from app import create_app
from app.extensions import db
from app.models import (
    Department, Employee, Doctor, Surgeon, Nurse, AdminStaff, Shift,
    EmployeeShift, Insurance, Patient, MedicalRecord, ICDDisease,
    DoctorDiagnosis, Bed, Appointment, Admission, PatientTransfer,
    LabImagingRequest, IsCritical, LabResult, LabAlert, Drug,
    Prescription, PrescriptionItem, DrugInteraction, Storage,
    StorageTransaction, PaymentMethod, Invoice, InvoiceItem, Payment,
    UserAccount, IoTDevice, DeviceTransfer, Log, AlertThreshold, Alert,
)

app = create_app()

with app.app_context():
    db.create_all()

    dept = Department(name="ICU", type="inpatient")
    dept2 = Department(name="Emergency", type="emergency")
    db.session.add_all([dept, dept2])
    db.session.flush()

    ins = Insurance(name="Basic Health Plan", type="public", coveragepercent=70, isActive=True)
    db.session.add(ins)
    db.session.flush()

    patient = Patient(
        nationalID="1234567890", insuranceID=ins.id, name="Reza Ahmadi",
        datebirth=date(1985, 3, 12), gender="مرد", phone="0912xxxxxxx",
        address="Tehran",
    )
    db.session.add(patient)
    db.session.flush()

    record = MedicalRecord(
        patientID=patient.nationalID, preMedicalRecord="Hypertension",
        predrugconsumption="none", smokingHistory="former",
        weight=78.5, height=178, bloodpressure="130/85",
    )
    icd = ICDDisease(code="I10", name="Essential hypertension")
    db.session.add_all([record, icd])
    db.session.flush()

    emp = Employee(departmentID=dept.id, name="Dr. Sara Karimi", contractType="full-time",
                    phone="0910000", role="physician", specialization="cardiology")
    db.session.add(emp)
    db.session.flush()
    doctor = Doctor(employeeID=emp.id, specialization="cardiology", medicalLicenseNo="MD-1001")
    db.session.add(doctor)

    emp2 = Employee(departmentID=dept.id, name="Nurse Yara", contractType="full-time", phone="0911")
    db.session.add(emp2)
    db.session.flush()
    nurse = Nurse(employeeID=emp2.id, grade="senior")
    db.session.add(nurse)

    shift = Shift(shiftDate=date.today(), startTime=time(8, 0), endTime=time(16, 0), shiftType="day")
    db.session.add(shift)
    db.session.flush()
    db.session.add(EmployeeShift(employeeID=emp.id, shiftID=shift.id))

    bed_free = Bed(departmentID=dept.id, status="Free", room="101")
    bed_occ = Bed(departmentID=dept.id, status="Occupied", room="102")
    bed_er = Bed(departmentID=dept2.id, status="Reserved", room="ER-1")
    db.session.add_all([bed_free, bed_occ, bed_er])
    db.session.flush()

    appt = Appointment(employeeID=emp.id, patientID=patient.nationalID, departmentID=dept.id,
                        date=date.today(), time=time(10, 0), status="Scheduled",
                        appointment_type="InPerson")
    db.session.add(appt)
    db.session.flush()

    db.session.add(DoctorDiagnosis(appointmentID=appt.id, icdID=icd.id, description="Routine check"))

    admission = Admission(patientID=patient.nationalID, bedID=bed_occ.id, employeeID=emp.id,
                           appointmentID=appt.id, entrydate=date.today(), reason="observation")
    db.session.add(admission)
    db.session.flush()

    db.session.add(PatientTransfer(date=date.today(), time=time(12, 0), reason="ward change",
                                    admissionID=admission.id, fromBedID=bed_free.id, toBedID=bed_occ.id))

    labreq = LabImagingRequest(employeeID=emp.id, appointmentID=appt.id, type="Lab",
                                date=date.today(), status="Completed")
    db.session.add(labreq)
    db.session.flush()

    ref_range = IsCritical(type="HR", referenceMin=60, referenceMax=100,
                            isCritical_status="normal", unit="bpm")
    db.session.add(ref_range)
    db.session.flush()

    labresult = LabResult(reportedbyemployeeID=emp.id, isCritical=ref_range.id,
                           LabimagingrequestID=labreq.id, value="95", status="Completed",
                           date=date.today(), description="within range")
    db.session.add(labresult)
    db.session.flush()

    db.session.add(LabAlert(doctorID=doctor.employeeID, labResultID=labresult.id,
                             severity="Normal", status="Resolved", createdAt=date.today()))

    drug = Drug(name="Amoxicillin", type="antibiotic", description="oral")
    drug2 = Drug(name="Warfarin", type="anticoagulant", description="blood thinner")
    db.session.add_all([drug, drug2])
    db.session.flush()

    db.session.add(DrugInteraction(drugID1=drug.id, drugID2=drug2.id,
                                    severity="Moderate", description="test interaction pair"))

    presc = Prescription(patientID=patient.nationalID, employeeID=emp.id, appointmentID=appt.id,
                          date=date.today(), status="Dispensed")
    db.session.add(presc)
    db.session.flush()
    db.session.add(PrescriptionItem(prescriptionID=presc.id, drugID=drug.id, dose="500mg",
                                     duration="7 days", quantity=21))

    storage = Storage(name="Main Pharmacy Store", inventory=500, type="drug")
    db.session.add(storage)
    db.session.flush()
    db.session.add(StorageTransaction(drugID=drug.id, storageID=storage.id, date=date.today(),
                                       type="OUT", quantity=21, reason="dispensed"))

    pm = PaymentMethod(type="credit card")
    db.session.add(pm)
    db.session.flush()
    invoice = Invoice(patientID=patient.nationalID, admissionID=admission.id, insuranceId=ins.id,
                       paymentmethodID=pm.id, total_amount=1250000, status="PartiallyPaid",
                       date=date.today(), insuranceAmount=875000, patientAmount=375000, paidAmount=200000)
    db.session.add(invoice)
    db.session.flush()
    db.session.add(InvoiceItem(invoiceID=invoice.id, item="Room charge", type="service",
                                description="ICU daily rate", amount=1250000))
    db.session.add(Payment(invoiceID=invoice.id, patientID=patient.nationalID,
                            paymentmethodID=pm.id, amount=200000, type="Payment",
                            date=datetime.now()))

    device = IoTDevice(macaddress="AA:BB:CC:DD:EE:01", type="vitals wristband",
                        status="Active", installationdate=date.today())
    db.session.add(device)
    db.session.flush()

    db.session.add(DeviceTransfer(patientID=patient.nationalID, admissionID=admission.id,
                                   departmentID=dept.id, bedID=bed_occ.id, iotdeviceID=device.id,
                                   assignedAt=date.today()))

    log = Log(deviceID=device.id, timestamp=datetime.now(), type="HR", value=42.0, unit="bpm")
    db.session.add(log)
    db.session.flush()

    threshold = AlertThreshold(measurementType="HR", minValue=60, maxValue=100,
                                severity="Critical", isGlobal=True, createdate=date.today())
    db.session.add(threshold)
    db.session.flush()

    db.session.add(Alert(logID=log.id, alertThresholdID=threshold.id, severity="Critical",
                          status="Unreviewed", createdtime=datetime.now()))

    db.session.commit()
    print("Seed complete.")

    # ---- hit every route ----
    client = app.test_client()
    routes_to_check = [
        ("/", "dashboard"),
        ("/patients/", "patients list"),
        ("/patients/new", "patient create form"),
        (f"/patients/{patient.nationalID}", "patient detail"),
        (f"/patients/{patient.nationalID}/edit", "patient edit form"),
        ("/admissions/", "admissions list (active)"),
        ("/admissions/?all=1", "admissions list (all)"),
        ("/admissions/new", "admission create form"),
        (f"/admissions/{admission.id}", "admission detail"),
        ("/iot/", "iot devices"),
        (f"/iot/devices/{device.id}", "iot device detail"),
        ("/iot/alerts", "iot alerts (open)"),
        ("/iot/alerts?status=all", "iot alerts (all)"),
        ("/iot/thresholds", "iot thresholds"),
        ("/staff/", "staff directory"),
        ("/appointments/", "appointments list"),
        ("/lab/", "lab requests"),
        ("/lab/alerts", "lab alerts (open)"),
        ("/lab/alerts?status=all", "lab alerts (all)"),
        ("/pharmacy/", "prescriptions"),
        ("/inventory/", "inventory transactions"),
        ("/financial/", "invoices"),
    ]

    failures = []
    for path, label in routes_to_check:
        try:
            resp = client.get(path)
            status = "OK " if resp.status_code == 200 else f"FAIL({resp.status_code})"
            print(f"{status:10s} {label:32s} {path}")
            if resp.status_code != 200:
                failures.append((path, label, resp.status_code, resp.get_data(as_text=True)[:800]))
        except Exception as e:
            print(f"EXCEPT     {label:32s} {path}  -> {e}")
            failures.append((path, label, "EXCEPTION", str(e)))

    print("\n--- POST action checks ---")
    resp = client.post(f"/patients/{patient.nationalID}/medical-record", data={
        "preMedicalRecord": "updated", "predrugconsumption": "none", "smokingHistory": "never",
        "weight": "80", "height": "178", "bloodpressure": "125/80",
    }, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "save medical record")

    resp = client.post(f"/admissions/{admission.id}/transfer", data={
        "toBedID": str(bed_free.id), "reason": "test transfer",
    }, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "transfer patient")

    resp = client.post(f"/admissions/{admission.id}/discharge", data={
        "exitdate": date.today().isoformat(),
    }, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "discharge patient")

    alert_row = Alert.query.first()
    resp = client.post(f"/iot/alerts/{alert_row.id}/acknowledge", data={"employeeID": str(emp.id)},
                        follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "acknowledge alert")

    resp = client.post(f"/iot/alerts/{alert_row.id}/resolve", data={}, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "resolve alert")

    lab_alert_row = LabAlert.query.first()
    resp = client.post(f"/lab/alerts/{lab_alert_row.id}/resolve", data={}, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "resolve lab alert")

    resp = client.post("/patients/new", data={
        "nationalID": "9999999999", "name": "Test Patient", "gender": "زن",
        "phone": "0999", "address": "Shiraz", "insuranceID": "0",
    }, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "create new patient")

    resp = client.post("/admissions/new", data={
        "patientID": patient.nationalID, "bedID": str(bed_free.id),
        "employeeID": str(emp.id), "entrydate": date.today().isoformat(),
        "reason": "test admit",
    }, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "create new admission")

    print("\n=== SUMMARY ===")
    if failures:
        print(f"{len(failures)} FAILURE(S):")
        for path, label, status, body in failures:
            print(f"\n--- {label} ({path}) status={status} ---")
            print(body)
    else:
        print("All checks passed.")

os.remove(_db_path)
