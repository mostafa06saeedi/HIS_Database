"""
Smoke test: boots the app against a throwaway SQLite file (standing in
for SQL Server), seeds one row per table using the REAL enum values from
01_schemas.sql / phase2_schemas.sql's CHECK constraints, then hits every
route with Flask's test client. This does NOT touch the real MSSQL config.
"""
import os
import sys
from datetime import date, datetime, time, timedelta

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
    TreatmentOutcome, FollowUp, OperatingRoom, SurgeryRecord,
    PatientAllergy, PrescriptionSafetyAlert, DailyDepartmentStats,
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
    icd2 = ICDDisease(code="J45.9", name="Asthma, unspecified")
    db.session.add_all([record, icd, icd2])
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

    emp3 = Employee(departmentID=dept.id, name="Dr. Omid Surgeon", contractType="full-time", phone="0913")
    db.session.add(emp3)
    db.session.flush()
    surgeon = Surgeon(employeeID=emp3.id, surgicalSpecialty="General Surgery")
    db.session.add(surgeon)

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

    dd1 = DoctorDiagnosis(appointmentID=appt.id, icdID=icd.id, description="Routine check")
    db.session.add(dd1)
    db.session.flush()

    admission = Admission(patientID=patient.nationalID, bedID=bed_occ.id, employeeID=emp.id,
                           appointmentID=appt.id, entrydate=date.today() - timedelta(days=3),
                           exitdate=date.today(), reason="observation")
    db.session.add(admission)
    db.session.flush()

    dd2 = DoctorDiagnosis(admissionID=admission.id, icdID=icd2.id, description="Admitting diagnosis")
    db.session.add(dd2)
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
    presc_item = PrescriptionItem(prescriptionID=presc.id, drugID=drug.id, dose="500mg",
                                   duration="7 days", quantity=21)
    db.session.add(presc_item)
    db.session.flush()

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

    # ---- Phase 2 seed data ----
    db.session.add(TreatmentOutcome(
        doctordiagnosisID=dd2.id, outcomeStatus="Improved",
        evaluatedDate=date.today(), evaluatedbyemployeeID=emp.id,
    ))

    db.session.add(FollowUp(
        patientID=patient.nationalID, doctordiagnosisID=dd2.id, appointmentID=appt.id,
        employeeID=emp.id, followUpDate=date.today(), newSymptoms="mild cough",
        progressStatus="Stable", treatmentChanged=False,
        nextFollowUpDate=date.today() + timedelta(days=14),
    ))

    op_room = OperatingRoom(departmentID=dept.id, roomNumber="OR-1", status="Free")
    db.session.add(op_room)
    db.session.flush()

    surgery = SurgeryRecord(
        operatingRoomID=op_room.id, patientID=patient.nationalID, admissionID=admission.id,
        surgeonID=surgeon.employeeID, procedureName="Appendectomy",
        scheduledStart=datetime.now() + timedelta(hours=2), status="Scheduled",
    )
    db.session.add(surgery)
    db.session.flush()

    db.session.add(PatientAllergy(
        patientID=patient.nationalID, drugID=drug2.id, severity="Moderate",
        reaction="Rash", recordedDate=date.today(),
    ))

    safety_alert = PrescriptionSafetyAlert(
        prescriptionItemID=presc_item.id, alertType="DrugInteraction", relatedDrugID=drug2.id,
        severity="Moderate", message="Interaction detected with another active prescription.",
        createdAt=datetime.now(),
    )
    db.session.add(safety_alert)
    db.session.flush()

    db.session.add(DailyDepartmentStats(
        statDate=date.today(), departmentID=dept.id, totalBeds=3, occupiedBeds=1,
        occupancyPercent=33.33, newAdmissions=0, discharges=1, appointmentsCount=1,
        avgWaitMinutes=None,
    ))

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
        ("/appointments/?status=Scheduled", "appointments list (filtered)"),
        ("/lab/", "lab requests"),
        ("/lab/alerts", "lab alerts (open)"),
        ("/lab/alerts?status=all", "lab alerts (all)"),
        ("/pharmacy/", "prescriptions"),
        ("/inventory/", "inventory transactions"),
        ("/financial/", "invoices"),
        # ---- Phase 2 ----
        ("/followups/", "follow-ups queue (upcoming)"),
        ("/followups/?scope=all", "follow-ups queue (all)"),
        ("/followups/new", "follow-up create form"),
        ("/surgery/", "surgery & OR board"),
        ("/surgery/new", "schedule surgery form"),
        ("/safety/", "safety alerts (open)"),
        ("/safety/?status=all", "safety alerts (all)"),
        ("/reports/", "reports & KPIs"),
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

    print("\n--- Phase 2 POST action checks ---")

    resp = client.post(f"/appointments/{appt.id}/check-in", data={}, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "appointment check-in")

    resp = client.post(f"/appointments/{appt.id}/start-service", data={}, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "appointment start-service")

    resp = client.post(f"/appointments/{appt.id}/check-out", data={}, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "appointment check-out")

    resp = client.post(f"/patients/{patient.nationalID}/allergies", data={
        "drugID": "0", "substanceName": "Latex", "severity": "Mild", "reaction": "Contact rash",
    }, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "record patient allergy")

    resp = client.post(f"/patients/{patient.nationalID}/followups", data={
        "employeeID": str(emp.id), "doctordiagnosisID": "0",
        "followUpDate": date.today().isoformat(), "newSymptoms": "none",
        "progressStatus": "Stable",
    }, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "record follow-up (patient page)")

    resp = client.post(f"/patients/{patient.nationalID}/diagnoses/{dd1.id}/outcome", data={
        "outcomeStatus": "Recovered", "complicationICD_ID": "0",
        "evaluatedbyemployeeID": str(emp.id),
    }, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "record treatment outcome")

    resp = client.post("/followups/new", data={
        "patientID": patient.nationalID, "employeeID": str(emp.id),
        "doctordiagnosisID": "0", "followUpDate": date.today().isoformat(),
        "progressStatus": "Improving",
    }, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "record follow-up (hospital-wide)")

    resp = client.post("/surgery/new", data={
        "operatingRoomID": str(op_room.id), "patientID": patient.nationalID,
        "admissionID": "0", "surgeonID": str(surgeon.employeeID),
        "procedureName": "Gallbladder removal",
        "scheduledStart": (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%dT%H:%M"),
    }, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "schedule new surgery")

    resp = client.post(f"/surgery/{surgery.id}/start", data={}, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "start surgery")

    resp = client.post(f"/surgery/{surgery.id}/complete", data={}, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "complete surgery")

    resp = client.post(f"/safety/{safety_alert.id}/acknowledge", data={"employeeID": str(emp.id)},
                        follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "acknowledge safety alert")

    resp = client.post("/reports/refresh-daily-stats", data={}, follow_redirects=True)
    print("OK " if resp.status_code == 200 else f"FAIL({resp.status_code})", "refresh daily department stats")

    print("\n--- Re-check GET routes now that data exists (non-empty render paths) ---")
    for path, label in [
        (f"/patients/{patient.nationalID}", "patient detail (populated)"),
        (f"/admissions/{admission.id}", "admission detail (with linked surgery)"),
        ("/appointments/?status=Completed", "appointments list (completed, with wait time)"),
        ("/followups/", "follow-ups queue (populated, upcoming)"),
        ("/followups/?scope=all", "follow-ups queue (populated, all)"),
        ("/surgery/", "surgery board (populated)"),
        ("/surgery/?status=all", "surgery list (all, populated)"),
        ("/safety/?status=all", "safety alerts (populated, all)"),
        ("/reports/", "reports & KPIs (populated)"),
    ]:
        try:
            resp = client.get(path)
            status = "OK " if resp.status_code == 200 else f"FAIL({resp.status_code})"
            print(f"{status:10s} {label:32s} {path}")
            if resp.status_code != 200:
                failures.append((path, label, resp.status_code, resp.get_data(as_text=True)[:1200]))
        except Exception as e:
            print(f"EXCEPT     {label:32s} {path}  -> {e}")
            failures.append((path, label, "EXCEPTION", str(e)))

    print("\n=== SUMMARY ===")
    if failures:
        print(f"{len(failures)} FAILURE(S):")
        for path, label, status, body in failures:
            print(f"\n--- {label} ({path}) status={status} ---")
            print(body)
    else:
        print("All checks passed.")

os.remove(_db_path)
