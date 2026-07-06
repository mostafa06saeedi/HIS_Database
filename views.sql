CREATE VIEW [vw_MyProfile] AS
SELECT [p].[nationalID], [p].[name], [p].[datebirth], [dbo].[fn_CalculateAge]([p].[nationalID]) AS age,
       [p].[gender], [p].[phone], [p].[address], [ins].[name] AS insuranceName, [ins].[coveragepercent]
FROM [patient] AS [p]
LEFT JOIN [insurance] AS [ins] ON [ins].[id] = [p].[insuranceID]
WHERE [p].[nationalID] = [dbo].[fn_CurrentSessionPatientID]()
GO

CREATE VIEW [vw_MyMedicalRecord] AS
SELECT [mr].[patientID], [mr].[preMedicalRecord], [mr].[predrugconsumption], [mr].[smokingHistory],
       [mr].[weight], [mr].[height], [mr].[bloodpressure]
FROM [medicalrecord] AS [mr]
WHERE [mr].[patientID] = [dbo].[fn_CurrentSessionPatientID]()
GO

CREATE VIEW [vw_MyAppointments] AS
SELECT [a].[id] AS appointmentID, [a].[date], [a].[time], [a].[status], [a].[appointment_type],
       [e].[name] AS doctorName, [d].[name] AS departmentName
FROM [appointment] AS [a]
INNER JOIN [employee] AS [e] ON [e].[id] = [a].[employeeID]
INNER JOIN [department] AS [d] ON [d].[id] = [a].[departmentID]
WHERE [a].[patientID] = [dbo].[fn_CurrentSessionPatientID]()
GO

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
