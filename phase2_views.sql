-- View: Disease Frequency Report
-- Shows how many times each disease has been diagnosed
-- Useful for identifying most common conditions in the facility
CREATE VIEW [vw_DiseaseFrequency] AS
SELECT
  [ic].[id]         AS icdID,
  [ic].[code]       AS icdCode,
  [ic].[name]       AS diseaseName,
  COUNT([dd].[id])  AS diagnosisCount  -- Total number of diagnoses for this disease
FROM [icddisease] AS [ic]
LEFT JOIN [doctordiagnosis] AS [dd] ON [dd].[icdID] = [ic].[id]
GROUP BY [ic].[id], [ic].[code], [ic].[name]
GO
-- View: Treatment Effectiveness Analysis
-- Shows outcome distribution for each disease with percentage breakdown
-- Helps evaluate treatment success rates across different conditions
CREATE VIEW [vw_TreatmentEffectiveness] AS
SELECT
  [ic].[id]            AS icdID,
  [ic].[name]           AS diseaseName,
  [to1].[outcomeStatus],                                    -- Treatment outcome (e.g., Recovered, Improved, Unchanged)
  COUNT(*)              AS caseCount,                       -- Number of cases with this outcome
  CAST(ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY [ic].[id]), 2) AS float) AS percentOfCases  -- Percentage distribution within each disease
FROM [treatmentoutcome] AS [to1]
INNER JOIN [doctordiagnosis] AS [dd] ON [dd].[id] = [to1].[doctordiagnosisID]
INNER JOIN [icddisease] AS [ic] ON [ic].[id] = [dd].[icdID]
WHERE [to1].[outcomeStatus] IS NOT NULL
GROUP BY [ic].[id], [ic].[name], [to1].[outcomeStatus]
GO
-- View: KPI - 30-Day Readmission Rate
-- Calculates the percentage of patients readmitted within 30 days
-- Key quality indicator for patient care and discharge planning
CREATE VIEW [vw_KPI_ReadmissionRate] AS
SELECT
  [d].[id]   AS departmentID,
  [d].[name] AS departmentName,
  COUNT([a].[id])                                           AS totalAdmissions,                                              -- Total admissions for this department
  SUM(CAST([dbo].[fn_IsReadmission30Day]([a].[id]) AS int))  AS readmissions30Day,                                           -- Count of patients readmitted within 30 days
  CAST(ROUND(100.0 * SUM(CAST([dbo].[fn_IsReadmission30Day]([a].[id]) AS int))
       / NULLIF(COUNT([a].[id]), 0), 2) AS float)            AS readmissionRatePercent  -- Readmission rate as percentage
FROM [admission] AS [a]
INNER JOIN [bed] AS [b] ON [b].[id] = [a].[bedID]
INNER JOIN [department] AS [d] ON [d].[id] = [b].[departmentID]
WHERE [a].[exitdate] IS NOT NULL  -- Only include completed admissions
GROUP BY [d].[id], [d].[name]
GO
-- View: KPI - Average Length of Stay
-- Calculates average number of days patients stay in each department
-- Important metric for resource planning and operational efficiency
CREATE VIEW [vw_KPI_AvgLengthOfStay] AS
SELECT
  [d].[id]   AS departmentID,
  [d].[name] AS departmentName,
  CAST(ROUND(AVG(CAST([dbo].[fn_CalculateLengthOfStay]([a].[id]) AS float)), 2) AS float) AS avgLengthOfStayDays  -- Average stay duration in days
FROM [admission] AS [a]
INNER JOIN [bed] AS [b] ON [b].[id] = [a].[bedID]
INNER JOIN [department] AS [d] ON [d].[id] = [b].[departmentID]
WHERE [a].[exitdate] IS NOT NULL  -- Only include completed admissions
GROUP BY [d].[id], [d].[name]
GO
-- View: KPI - Average Wait Time
-- Calculates average waiting time from check-in to service start
-- Key patient experience metric for outpatient services
CREATE VIEW [vw_KPI_AvgWaitTime] AS
SELECT
  [d].[id]   AS departmentID,
  [d].[name] AS departmentName,
  CAST(ROUND(AVG(CAST([dbo].[fn_CalculateWaitMinutes]([ap].[id]) AS float)), 1) AS float) AS avgWaitMinutes  -- Average wait time in minutes
FROM [appointment] AS [ap]
INNER JOIN [department] AS [d] ON [d].[id] = [ap].[departmentID]
WHERE [ap].[checkInTime] IS NOT NULL AND [ap].[serviceStartTime] IS NOT NULL  -- Only include appointments with complete timing data
GROUP BY [d].[id], [d].[name]
GO
-- View: Operating Room Status Dashboard
-- Shows real-time status of all operating rooms including current surgeries
-- Useful for OR scheduling and resource management
CREATE VIEW [vw_OperatingRoomStatus] AS
SELECT
  [o].[id]      AS operatingRoomID,
  [o].[roomNumber],
  [o].[status],                                                      -- Room status: Free, Occupied, or Maintenance
  [d].[name]    AS departmentName,
  [sr].[id]     AS currentSurgeryID,                                 -- Currently active surgery (if any)
  [p].[name]    AS currentPatientName,                               -- Patient currently in surgery
  [sr].[procedureName],                                              -- Name of surgical procedure being performed
  [sr].[actualStart]                                                 -- Start time of current surgery
FROM [operatingroom] AS [o]
LEFT JOIN [department] AS [d] ON [d].[id] = [o].[departmentID]
LEFT JOIN [surgeryrecord] AS [sr] ON [sr].[operatingRoomID] = [o].[id] AND [sr].[status] = N'InProgress'  -- Only join ongoing surgeries
LEFT JOIN [patient] AS [p] ON [p].[nationalID] = [sr].[patientID]
GO
-- View: Busiest Departments
-- Provides workload metrics across departments including admissions,
-- appointments, and surgeries for capacity planning
CREATE VIEW [vw_BusiestDepartments] AS
SELECT
  [d].[id]   AS departmentID,
  [d].[name] AS departmentName,
  (SELECT COUNT(*) FROM [admission] AS [a] INNER JOIN [bed] AS [b] ON [b].[id] = [a].[bedID]
     WHERE [b].[departmentID] = [d].[id])                                                     AS totalAdmissions,   -- All admissions to this department
  (SELECT COUNT(*) FROM [appointment] AS [ap] WHERE [ap].[departmentID] = [d].[id])            AS totalAppointments, -- All appointments scheduled in this department
  (SELECT COUNT(*) FROM [surgeryrecord] AS [sr] INNER JOIN [operatingroom] AS [o] ON [o].[id] = [sr].[operatingRoomID]
     WHERE [o].[departmentID] = [d].[id])                                                      AS totalSurgeries     -- All surgeries performed in this department
FROM [department] AS [d]
GO
-- View: Drug Consumption Report
-- Shows medication usage patterns including total quantity dispensed
-- and number of unique patients served per drug
CREATE VIEW [vw_DrugConsumptionReport] AS
SELECT
  [dg].[id]   AS drugID,
  [dg].[name] AS drugName,
  [dg].[type] AS drugType,
  SUM([pi].[quantity])             AS totalQuantityDispensed,  -- Total units of this drug dispensed
  COUNT(DISTINCT [pr].[patientID]) AS distinctPatients         -- Number of unique patients who received this drug
FROM [prescriptionitem] AS [pi]
INNER JOIN [drug] AS [dg] ON [dg].[id] = [pi].[drugID]
INNER JOIN [prescription] AS [pr] ON [pr].[id] = [pi].[prescriptionID]
WHERE [pr].[status] = N'Dispensed'  -- Only include prescriptions that were actually dispensed
GROUP BY [dg].[id], [dg].[name], [dg].[type]
GO
-- View: Pending Safety Alerts
-- Displays all unacknowledged safety alerts (drug interactions and allergies)
-- Used by clinical staff to review and address patient safety concerns
CREATE VIEW [vw_PendingSafetyAlerts] AS
SELECT
  [psa].[id]       AS alertID,
  [psa].[alertType],                                              -- Type: DrugInteraction or Allergy
  [psa].[severity],                                               -- Severity level (e.g., Critical, Major, Moderate)
  [psa].[message],                                                -- Alert description
  [psa].[createdAt],                                              -- When the alert was generated
  [p].[nationalID] AS patientID,
  [p].[name]       AS patientName,
  [dg].[name]      AS prescribedDrug,                             -- The drug that triggered the alert
  [rdg].[name]     AS relatedDrug                                 -- Interacting drug (null for allergy alerts)
FROM [prescriptionsafetyalert] AS [psa]
INNER JOIN [prescriptionitem] AS [pi] ON [pi].[id] = [psa].[prescriptionItemID]
INNER JOIN [prescription] AS [pr] ON [pr].[id] = [pi].[prescriptionID]
INNER JOIN [patient] AS [p] ON [p].[nationalID] = [pr].[patientID]
INNER JOIN [drug] AS [dg] ON [dg].[id] = [pi].[drugID]
LEFT JOIN [drug] AS [rdg] ON [rdg].[id] = [psa].[relatedDrugID]
WHERE [psa].[acknowledgedAt] IS NULL  -- Only show alerts that haven't been acknowledged yet
GO

-- View: Doctor Follow-Up Queue
-- Shows upcoming follow-up appointments for the current session user
-- Personalized list for doctors to manage patient follow-ups
CREATE VIEW [vw_DoctorFollowUpQueue] AS
SELECT
  [f].[id]         AS followUpID,
  [p].[nationalID] AS patientID,
  [p].[name]       AS patientName,
  [f].[followUpDate],                                               -- Date of the scheduled follow-up
  [f].[nextFollowUpDate],                                           -- Recommended date for next follow-up
  [ic].[name]      AS conditionBeingTracked,                        -- Disease being monitored
  [f].[progressStatus]                                              -- Current status (e.g., Improving, Stable, Worsening)
FROM [followup] AS [f]
INNER JOIN [patient] AS [p] ON [p].[nationalID] = [f].[patientID]
LEFT JOIN [doctordiagnosis] AS [dd] ON [dd].[id] = [f].[doctordiagnosisID]
LEFT JOIN [icddisease] AS [ic] ON [ic].[id] = [dd].[icdID]
WHERE [f].[employeeID] = [dbo].[fn_CurrentSessionEmployeeID]()  -- Filter for the currently logged-in doctor
  AND [f].[nextFollowUpDate] IS NOT NULL                         -- Only include follow-ups with a scheduled date
  AND [f].[nextFollowUpDate] >= CAST(GETDATE() AS date)          -- Only show upcoming or today's follow-ups
GO