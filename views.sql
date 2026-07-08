-- PATIENT PORTAL VIEWS (Patient Role)
-- View: Patient's personal profile information
-- Uses session context to filter for the current logged-in patient
-- Automatically calculates patient's age using fn_CalculateAge
-- Shows insurance information if available
-- Security: Row-level security via fn_CurrentSessionPatientID()
CREATE VIEW [vw_MyProfile] AS
SELECT [p].[nationalID], [p].[name], [p].[datebirth], [dbo].[fn_CalculateAge]([p].[nationalID]) AS age,
       [p].[gender], [p].[phone], [p].[address], [ins].[name] AS insuranceName, [ins].[coveragepercent]
FROM [patient] AS [p]
LEFT JOIN [insurance] AS [ins] ON [ins].[id] = [p].[insuranceID]
WHERE [p].[nationalID] = [dbo].[fn_CurrentSessionPatientID]()
GO

-- View: Patient's complete medical record
-- Includes medical history, medications, vitals, and lifestyle information
-- Security: Filters to current patient only
CREATE VIEW [vw_MyMedicalRecord] AS
SELECT [mr].[patientID], [mr].[preMedicalRecord], [mr].[predrugconsumption], [mr].[smokingHistory],
       [mr].[weight], [mr].[height], [mr].[bloodpressure]
FROM [medicalrecord] AS [mr]
WHERE [mr].[patientID] = [dbo].[fn_CurrentSessionPatientID]()
GO

-- View: Patient's appointment history
-- Shows all appointments with doctor and department details
-- Includes appointment type and current status
-- Security: Filters to current patient only
CREATE VIEW [vw_MyAppointments] AS
SELECT [a].[id] AS appointmentID, [a].[date], [a].[time], [a].[status], [a].[appointment_type],
       [e].[name] AS doctorName, [d].[name] AS departmentName
FROM [appointment] AS [a]
INNER JOIN [employee] AS [e] ON [e].[id] = [a].[employeeID]
INNER JOIN [department] AS [d] ON [d].[id] = [a].[departmentID]
WHERE [a].[patientID] = [dbo].[fn_CurrentSessionPatientID]()
GO

-- View: Patient's admission history (past and current)
-- Shows hospital stays with department, room, and doctor information
-- Includes a computed status column indicating if currently hospitalized
-- Security: Filters to current patient only
CREATE VIEW [vw_MyAdmissions] AS
SELECT [ad].[id] AS admissionID, [ad].[entrydate], [ad].[exitdate], [ad].[reason],
       [d].[name] AS departmentName, [b].[room], [e].[name] AS responsibleDoctor,
       CASE WHEN [ad].[exitdate] IS NULL THEN N'در حال بستری' ELSE N'ترخیص‌شده' END AS currentStatus
FROM [admission] AS [ad]
INNER JOIN [bed] AS [b] ON [b].[id] = [ad].[bedID]
INNER JOIN [department] AS [d] ON [d].[id] = [b].[departmentID]
INNER JOIN [employee] AS [e] ON [e].[id] = [ad].[employeeID]
WHERE [ad].[patientID] = [dbo].[fn_CurrentSessionPatientID]()
GO

-- View: Patient's lab test results
-- Shows all lab results with critical flag and physician notification status
-- Links through appointment or admission to find patient context
-- Uses EXISTS to check for critical alerts
-- Security: Filters using patient ID from appointment or admission context
CREATE VIEW [vw_MyLabResults] AS
SELECT
  [lr].[id]           AS labResultID,
  [req].[type]        AS testType,
  [lr].[value],
  [lr].[status],
  [lr].[date],
  [lr].[description],
  CASE WHEN [lr].[isCritical] IS NOT NULL
            AND EXISTS (SELECT 1 FROM [labalert] WHERE [labResultID] = [lr].[id])
       THEN N'Critical - Physician Notified' ELSE N'Normal' END AS resultFlag,
  [e].[name]          AS reportedBy
FROM [labresult] AS [lr]
INNER JOIN [Labimagingrequest] AS [req] ON [req].[id] = [lr].[LabimagingrequestID]
INNER JOIN [employee] AS [e] ON [e].[id] = [lr].[reportedbyemployeeID]
LEFT JOIN [appointment] AS [ap] ON [ap].[id] = [req].[appointmentID]
LEFT JOIN [admission]   AS [ad] ON [ad].[id] = [req].[admissionID]
WHERE [dbo].[fn_CurrentSessionPatientID]() IN (ISNULL([ap].[patientID], N''), ISNULL([ad].[patientID], N''))
GO

-- View: Patient's prescription history
-- Shows all medications prescribed with dosage and duration
-- Includes prescribing doctor information
-- Security: Filters to current patient only
CREATE VIEW [vw_MyPrescriptions] AS
SELECT
  [pr].[id]        AS prescriptionID,
  [pr].[date],
  [pr].[status],
  [dg].[name]      AS drugName,
  [pi].[dose],
  [pi].[duration],
  [pi].[quantity],
  [e].[name]       AS prescribedBy
FROM [prescription] AS [pr]
INNER JOIN [prescriptionitem] AS [pi] ON [pi].[prescriptionID] = [pr].[id]
INNER JOIN [drug] AS [dg] ON [dg].[id] = [pi].[drugID]
INNER JOIN [employee] AS [e] ON [e].[id] = [pr].[employeeID]
WHERE [pr].[patientID] = [dbo].[fn_CurrentSessionPatientID]()
GO

-- View: Patient's financial invoices
-- Shows all invoices with amounts, insurance coverage, payment status
-- Computes remaining balance (patient amount minus paid amount)
-- Security: Filters to current patient only
CREATE VIEW [vw_MyInvoices] AS
SELECT
  [inv].[id]              AS invoiceID,
  [inv].[date],
  [inv].[total_amount],
  [inv].[insuranceAmount],
  [inv].[patientAmount],
  [inv].[paidAmount],
  [inv].[patientAmount] - [inv].[paidAmount] AS remainingBalance,
  [inv].[status]
FROM [invoice] AS [inv]
WHERE [inv].[patientID] = [dbo].[fn_CurrentSessionPatientID]()
GO
-- DOCTOR PORTAL VIEWS (Doctor Role)
-- View: Doctor's scheduled appointments (today and upcoming)
-- Shows patient details including age
-- Only shows appointments with status 'Scheduled' or 'Rescheduled'
-- Security: Filters to current doctor using session context
CREATE VIEW [vw_DoctorMyAppointments] AS
SELECT [a].[id] AS appointmentID, [a].[date], [a].[time], [a].[status],
       [p].[nationalID] AS patientID, [p].[name] AS patientName,
       [dbo].[fn_CalculateAge]([p].[nationalID]) AS patientAge
FROM [appointment] AS [a]
INNER JOIN [patient] AS [p] ON [p].[nationalID] = [a].[patientID]
WHERE [a].[employeeID] = [dbo].[fn_CurrentSessionEmployeeID]()
  AND [a].[status] IN (N'Scheduled', N'Rescheduled')
GO

-- View: Doctor's currently admitted patients
-- Shows all patients under this doctor's care who are still hospitalized
-- Calculates number of days admitted
-- Security: Filters to current doctor's patients
CREATE VIEW [vw_DoctorMyAdmittedPatients] AS
SELECT [ad].[id] AS admissionID, [p].[nationalID] AS patientID, [p].[name] AS patientName,
       [ad].[entrydate], [d].[name] AS departmentName, [b].[room],
       DATEDIFF(DAY, [ad].[entrydate], GETDATE()) AS daysAdmitted
FROM [admission] AS [ad]
INNER JOIN [patient] AS [p] ON [p].[nationalID] = [ad].[patientID]
INNER JOIN [bed] AS [b] ON [b].[id] = [ad].[bedID]
INNER JOIN [department] AS [d] ON [d].[id] = [b].[departmentID]
WHERE [ad].[employeeID] = [dbo].[fn_CurrentSessionEmployeeID]()
  AND [ad].[exitdate] IS NULL
GO

-- View: Doctor's pending critical lab alerts
-- Shows lab results that triggered critical alerts, waiting for review
-- Includes patient information and test details
-- Security: Filters to current doctor's alerts
CREATE VIEW [vw_DoctorPendingLabResults] AS
SELECT
  [la].[id]          AS labAlertID,
  [la].[severity],
  [la].[status]      AS alertStatus,
  [la].[createdAt],
  [lr].[value],
  [lr].[description],
  [req].[type]       AS testType,
  [p].[nationalID]   AS patientID,
  [p].[name]         AS patientName
FROM [labalert] AS [la]
INNER JOIN [labresult] AS [lr] ON [lr].[id] = [la].[labResultID]
INNER JOIN [Labimagingrequest] AS [req] ON [req].[id] = [lr].[LabimagingrequestID]
LEFT JOIN [appointment] AS [ap] ON [ap].[id] = [req].[appointmentID]
LEFT JOIN [admission]   AS [ad] ON [ad].[id] = [req].[admissionID]
INNER JOIN [patient] AS [p] ON [p].[nationalID] = ISNULL([ap].[patientID], [ad].[patientID])
WHERE [la].[doctorID] = [dbo].[fn_CurrentSessionEmployeeID]()
  AND [la].[status] <> N'Resolved'
GO

-- View: Doctor's patient diagnosis history
-- Shows all diagnoses made by the doctor for their patients
-- Includes ICD codes and diagnosis dates
-- Security: Filters based on doctor's employee ID
CREATE VIEW [vw_DoctorPatientHistory] AS
SELECT
  [p].[nationalID]  AS patientID,
  [p].[name]        AS patientName,
  [ic].[code]       AS icdCode,
  [ic].[name]       AS diagnosisName,
  [dd].[description],
  COALESCE([ap].[date], [ad].[entrydate]) AS diagnosisDate
FROM [doctordiagnosis] AS [dd]
INNER JOIN [icddisease] AS [ic] ON [ic].[id] = [dd].[icdID]
LEFT JOIN [appointment] AS [ap] ON [ap].[id] = [dd].[appointmentID]
LEFT JOIN [admission]   AS [ad] ON [ad].[id] = [dd].[admissionID]
INNER JOIN [patient] AS [p] ON [p].[nationalID] = ISNULL([ap].[patientID], [ad].[patientID])
WHERE [dbo].[fn_CurrentSessionEmployeeID]() IN (ISNULL([ap].[employeeID], -1), ISNULL([ad].[employeeID], -1))
GO
-- NURSE PORTAL VIEWS (Nurse Role)
-- View: Active IoT alerts for nurse's department
-- Shows all unresolved alerts (vital signs, critical readings)
-- Includes patient location (room, department)
-- Security: Filters by nurse's department using session context
CREATE VIEW [vw_NurseActiveAlerts] AS
SELECT
  [al].[id]         AS alertID,
  [al].[severity],
  [al].[status],
  [al].[createdtime],
  [l].[type]        AS measurementType,
  [l].[value],
  [l].[unit],
  [p].[nationalID]  AS patientID,
  [p].[name]        AS patientName,
  [b].[room],
  [d].[name]        AS departmentName
FROM [alert] AS [al]
INNER JOIN [logs] AS [l] ON [l].[id] = [al].[logID]
INNER JOIN [devicetransfer] AS [dt] ON [dt].[iotdeviceID] = [l].[deviceID] AND [dt].[unassignedAt] IS NULL
INNER JOIN [patient] AS [p] ON [p].[nationalID] = [dt].[patientID]
INNER JOIN [bed] AS [b] ON [b].[id] = [dt].[bedID]
INNER JOIN [department] AS [d] ON [d].[id] = [b].[departmentID]
WHERE [al].[status] <> N'Resolved'
  AND [d].[id] = (SELECT [departmentID] FROM [employee] WHERE [id] = [dbo].[fn_CurrentSessionEmployeeID]())
GO

-- View: Patients currently in the nurse's ward
-- Shows all active admissions in the nurse's assigned department
-- Includes admission duration and responsible doctor
-- Security: Filters by nurse's department
CREATE VIEW [vw_NurseWardPatients] AS
SELECT
  [p].[nationalID] AS patientID, [p].[name] AS patientName, [b].[room],
  [ad].[entrydate], DATEDIFF(DAY, [ad].[entrydate], GETDATE()) AS daysAdmitted,
  [e].[name] AS responsibleDoctor
FROM [admission] AS [ad]
INNER JOIN [patient] AS [p] ON [p].[nationalID] = [ad].[patientID]
INNER JOIN [bed] AS [b] ON [b].[id] = [ad].[bedID]
INNER JOIN [employee] AS [e] ON [e].[id] = [ad].[employeeID]
WHERE [ad].[exitdate] IS NULL
  AND [b].[departmentID] = (SELECT [departmentID] FROM [employee] WHERE [id] = [dbo].[fn_CurrentSessionEmployeeID]())
GO
-- PHARMACY PORTAL VIEWS (Pharmacist Role)
-- View: All pending prescriptions awaiting fulfillment
-- Shows patient and drug details, dosage, quantity
-- Used by pharmacists to see what needs to be dispensed
-- Security: No patient filtering (pharmacist can see all)
CREATE VIEW [vw_PharmacyPendingPrescriptions] AS
SELECT
  [pr].[id] AS prescriptionID, [pr].[date], [p].[nationalID] AS patientID, [p].[name] AS patientName,
  [dg].[id] AS drugID, [dg].[name] AS drugName, [pi].[dose], [pi].[duration], [pi].[quantity]
FROM [prescription] AS [pr]
INNER JOIN [prescriptionitem] AS [pi] ON [pi].[prescriptionID] = [pr].[id]
INNER JOIN [drug] AS [dg] ON [dg].[id] = [pi].[drugID]
INNER JOIN [patient] AS [p] ON [p].[nationalID] = [pr].[patientID]
WHERE [pr].[status] = N'Pending'
GO
-- LABORATORY PORTAL VIEWS (Lab Technician Role)
-- View: All pending lab/imaging requests
-- Shows requests that need to be processed (status = Requested or InProgress)
-- Includes patient and requesting doctor information
-- Used by lab technicians to manage their workload
CREATE VIEW [vw_LabPendingRequests] AS
SELECT
  [req].[id] AS requestID, [req].[type], [req].[date], [req].[status],
  [p].[nationalID] AS patientID, [p].[name] AS patientName,
  [e].[name] AS requestedByDoctor
FROM [Labimagingrequest] AS [req]
LEFT JOIN [appointment] AS [ap] ON [ap].[id] = [req].[appointmentID]
LEFT JOIN [admission]   AS [ad] ON [ad].[id] = [req].[admissionID]
INNER JOIN [patient] AS [p] ON [p].[nationalID] = ISNULL([ap].[patientID], [ad].[patientID])
INNER JOIN [employee] AS [e] ON [e].[id] = [req].[employeeID]
WHERE [req].[status] IN (N'Requested', N'InProgress')
GO
-- MANAGEMENT & ADMINISTRATION VIEWS
-- View: Department bed capacity and occupancy statistics
-- Uses the fn_GetDepartmentBedStats function
-- Shows total beds, occupancy counts, and percentages
-- Used by managers and administrators for resource planning
CREATE VIEW [vw_DepartmentBedCapacity] AS
SELECT * FROM [dbo].[fn_GetDepartmentBedStats]()
GO

-- View: All currently admitted patients (across all departments)
-- Shows comprehensive information about hospitalized patients
-- Includes admission duration and responsible doctor
-- Used by management for hospital census reporting
CREATE VIEW [vw_CurrentAdmissions] AS
SELECT
  [ad].[id] AS admissionID, [p].[nationalID] AS patientID, [p].[name] AS patientName,
  [d].[name] AS departmentName, [b].[room], [ad].[entrydate],
  DATEDIFF(DAY, [ad].[entrydate], GETDATE()) AS daysAdmitted,
  [e].[name] AS responsibleDoctor
FROM [admission] AS [ad]
INNER JOIN [patient] AS [p] ON [p].[nationalID] = [ad].[patientID]
INNER JOIN [bed] AS [b] ON [b].[id] = [ad].[bedID]
INNER JOIN [department] AS [d] ON [d].[id] = [b].[departmentID]
INNER JOIN [employee] AS [e] ON [e].[id] = [ad].[employeeID]
WHERE [ad].[exitdate] IS NULL
GO

-- View: Today's appointments for receptionist
-- Shows all appointments scheduled for today
-- Includes patient and doctor details
-- Used by reception staff to manage daily patient flow
CREATE VIEW [vw_ReceptionTodayAppointments] AS
SELECT
  [a].[id] AS appointmentID, [a].[time], [a].[status],
  [p].[nationalID] AS patientID, [p].[name] AS patientName,
  [e].[name] AS doctorName, [d].[name] AS departmentName
FROM [appointment] AS [a]
INNER JOIN [patient] AS [p] ON [p].[nationalID] = [a].[patientID]
INNER JOIN [employee] AS [e] ON [e].[id] = [a].[employeeID]
INNER JOIN [department] AS [d] ON [d].[id] = [a].[departmentID]
WHERE [a].[date] = CAST(GETDATE() AS date)
GO

-- View: Comprehensive department report for manager
-- Combines bed statistics with active admissions count
-- Shows occupancy, bed availability, and current patient load
-- Used by managers for operational oversight and planning
CREATE VIEW [vw_ManagerDepartmentReport] AS
SELECT
  [stats].[departmentID], [stats].[departmentName], [stats].[totalBeds],
  [stats].[occupiedBeds], [stats].[freeBeds], [stats].[occupancyPercent],
  [dbo].[fn_CountActiveAdmissions]([stats].[departmentID]) AS activeAdmissions
FROM [dbo].[fn_GetDepartmentBedStats]() AS [stats]
GO