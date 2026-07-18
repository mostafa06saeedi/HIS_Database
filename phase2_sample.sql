-- SURGEONS (new employees — Phase 1's [surgeon] ISA table had zero rows


SET IDENTITY_INSERT [employee] ON;
INSERT INTO [employee] ([id], [departmentID], [name], [contractType], [phone], [role], [specialization], [medicalsystemID]) VALUES
(46, 3, N'Dr. Patricia Nguyen', N'Full-Time', N'555-204-7761', N'Surgeon', N'General Surgery', N'MED-10046'),
(47, 6, N'Dr. Marcus Webb', N'Full-Time', N'555-388-2290', N'Surgeon', N'Orthopedic Surgery', N'MED-10047');
SET IDENTITY_INSERT [employee] OFF;

INSERT INTO [surgeon] ([employeeID], [surgicalSpecialty]) VALUES
(46, N'General Surgery'),
(47, N'Orthopedic Surgery');

GO

-- OPERATING ROOMS

SET IDENTITY_INSERT [operatingroom] ON;
INSERT INTO [operatingroom] ([id], [departmentID], [roomNumber], [status]) VALUES
(1, 3, N'OR-1', N'Free'),
(2, 3, N'OR-2', N'Free'),
(3, 6, N'OR-3', N'Free');
SET IDENTITY_INSERT [operatingroom] OFF;

GO

-- SURGERY RECORDS 

SET IDENTITY_INSERT [surgeryrecord] ON;
INSERT INTO [surgeryrecord] ([id], [operatingRoomID], [patientID], [admissionID], [surgeonID], [procedureName], [scheduledStart], [actualStart], [actualEnd], [status]) VALUES
(1, 1, N'230-89-9751', 12, 46, N'Appendectomy (laparoscopic)', '2026-05-29 07:00:00', '2026-05-29 07:00:00', '2026-05-29 08:31:00', N'Completed'),
(2, 2, N'182-27-3471', 20, 46, N'Appendectomy (laparoscopic)', '2026-06-01 08:00:00', '2026-06-01 08:00:00', '2026-06-01 09:15:00', N'Completed'),
(3, 1, N'901-15-6688', 41, 46, N'Appendectomy (laparoscopic)', '2026-06-09 09:00:00', '2026-06-09 09:00:00', '2026-06-09 09:58:00', N'Completed'),
(4, 2, N'860-80-3546', 47, 46, N'Appendectomy (laparoscopic)', '2026-06-12 07:00:00', '2026-06-12 07:00:00', '2026-06-12 08:16:00', N'Completed'),
(5, 3, N'506-35-2245', 2, 47, N'Total Hip Arthroplasty', '2026-05-25 08:00:00', '2026-05-25 08:00:00', '2026-05-25 09:50:00', N'Completed'),
(6, 3, N'546-87-9379', 14, 47, N'Total Hip Arthroplasty', '2026-06-01 09:00:00', '2026-06-01 09:00:00', '2026-06-01 11:00:00', N'Completed'),
(7, 3, N'702-38-1117', 22, 47, N'Total Hip Arthroplasty', '2026-06-03 10:00:00', '2026-06-03 10:00:00', '2026-06-03 11:50:00', N'Completed'),
(8, 3, N'672-86-6198', 38, 47, N'Total Hip Arthroplasty', '2026-06-10 08:00:00', '2026-06-10 08:00:00', '2026-06-10 10:20:00', N'Completed'),
(9, 3, N'952-63-7381', 46, 47, N'Total Hip Arthroplasty', '2026-06-13 09:00:00', '2026-06-13 09:00:00', '2026-06-13 11:10:00', N'Completed'),
(10, 3, N'374-51-5022', 32, 47, N'Total Hip Arthroplasty', '2026-06-08 09:00:00', '2026-06-08 09:00:00', NULL, N'InProgress');
SET IDENTITY_INSERT [surgeryrecord] OFF;

GO

-- TREATMENT OUTCOMES (longitudinal treatment analysis)

SET IDENTITY_INSERT [treatmentoutcome] ON;
INSERT INTO [treatmentoutcome] ([id], [doctordiagnosisID], [outcomeStatus], [complicationNote], [evaluatedDate], [evaluatedbyemployeeID]) VALUES
(1, 67, N'Unchanged', NULL, '2026-06-06', 13),
(2, 68, N'Worsened', NULL, '2026-06-01', 11),
(3, 69, N'Improved', NULL, '2026-06-07', 9),
(4, 70, N'Improved', NULL, '2026-06-09', 4),
(5, 71, N'Recovered', NULL, '2026-05-31', 6),
(6, 73, N'Recovered', NULL, '2026-06-09', 1),
(7, 74, N'Recovered', NULL, '2026-06-10', 8),
(8, 77, N'Recovered', NULL, '2026-06-01', 12),
(9, 80, N'Improved', NULL, '2026-06-07', 12),
(10, 82, N'Recovered', NULL, '2026-06-05', 3),
(11, 83, N'Recovered', NULL, '2026-06-12', 3),
(12, 84, N'Recovered', NULL, '2026-06-13', 4),
(13, 85, N'Improved', NULL, '2026-06-09', 14),
(14, 86, N'Improved', NULL, '2026-06-05', 13),
(15, 87, N'Unchanged', NULL, '2026-06-08', 7),
(16, 90, N'Improved', NULL, '2026-06-15', 15),
(17, 91, N'Recovered', NULL, '2026-06-17', 7),
(18, 92, N'Unchanged', NULL, '2026-06-09', 8),
(19, 98, N'Deceased', N'Respiratory failure following COPD exacerbation; comfort care per family wishes.', '2026-06-18', 12),
(20, 99, N'Improved', NULL, '2026-06-15', 2),
(21, 102, N'Unchanged', NULL, '2026-06-16', 12),
(22, 104, N'Relapsed', N'Re-admitted with recurrent COPD exacerbation six weeks after discharge.', '2026-06-19', 1),
(23, 107, N'Unchanged', NULL, '2026-06-11', 6),
(24, 108, N'Improved', NULL, '2026-06-16', 12),
(25, 111, N'Improved', NULL, '2026-06-20', 15),
(26, 116, N'Improved', NULL, '2026-06-24', 8),
(27, 118, N'Worsened', NULL, '2026-06-26', 13),
(28, 119, N'Improved', NULL, '2026-06-29', 15),
(29, 1, N'Improved', NULL, '2026-06-18', 6),
(30, 2, N'Unchanged', NULL, '2026-06-19', 14),
(31, 3, N'Worsened', NULL, '2026-06-16', 13),
(32, 4, N'Improved', NULL, '2026-06-18', 11),
(33, 5, N'Improved', NULL, '2026-07-10', 7),
(34, 7, N'Unchanged', NULL, '2026-07-12', 5),
(35, 10, N'Improved', NULL, '2026-07-11', 8),
(36, 11, N'Improved', NULL, '2026-07-10', 13),
(37, 16, N'Improved', NULL, '2026-06-22', 12),
(38, 22, N'Unchanged', NULL, '2026-07-11', 11),
(39, 23, N'Worsened', NULL, '2026-07-02', 13),
(40, 24, N'Improved', NULL, '2026-06-26', 6),
(41, 28, N'Worsened', NULL, '2026-07-11', 9),
(42, 29, N'Improved', NULL, '2026-07-10', 15),
(43, 32, N'Unchanged', NULL, '2026-06-27', 1),
(44, 33, N'Worsened', NULL, '2026-07-12', 5),
(45, 36, N'Improved', NULL, '2026-06-26', 2),
(46, 39, N'Improved', NULL, '2026-07-12', 15),
(47, 42, N'Unchanged', NULL, '2026-06-22', 1),
(48, 44, N'Improved', NULL, '2026-07-13', 15),
(49, 45, N'Improved', NULL, '2026-07-01', 5),
(50, 51, N'Improved', NULL, '2026-06-26', 13),
(51, 57, N'Unchanged', NULL, '2026-07-12', 5),
(52, 58, N'Worsened', NULL, '2026-07-11', 9),
(53, 59, N'Improved', NULL, '2026-07-10', 5),
(54, 60, N'Improved', NULL, '2026-06-30', 8),
(55, 61, N'Improved', NULL, '2026-07-10', 8),
(56, 64, N'Improved', NULL, '2026-07-11', 10),
(57, 65, N'Improved', NULL, '2026-06-23', 12);
SET IDENTITY_INSERT [treatmentoutcome] OFF;

GO

-- FOLLOW-UPS (patient monitoring over time)

SET IDENTITY_INSERT [followup] ON;
INSERT INTO [followup] ([id], [patientID], [doctordiagnosisID], [appointmentID], [employeeID], [followUpDate], [newSymptoms], [progressStatus], [treatmentChanged], [changeDescription], [nextFollowUpDate]) VALUES
(1, N'230-34-7888', 1, NULL, 6, '2026-06-05', N'Fatigue, mild ankle swelling', N'Improving', 0, NULL, '2026-06-18'),
(2, N'901-15-6688', 3, NULL, 13, '2026-06-03', N'Mild wheeze with exertion, using inhaler 2x/week', N'Worsening', 1, N'Stepped up to combination inhaler', '2026-06-16'),
(3, N'258-34-5861', 5, NULL, 7, '2026-06-27', N'Mild wheeze with exertion, using inhaler 2x/week', N'Improving', 0, NULL, '2026-07-10'),
(4, N'182-27-3471', 10, NULL, 8, '2026-07-01', N'Reports fatigue and cold intolerance', N'Improving', 0, NULL, '2026-07-11'),
(5, N'230-89-9751', 16, NULL, 12, '2026-06-09', N'Mild wheeze with exertion, using inhaler 2x/week', N'Improving', 0, NULL, '2026-06-22'),
(6, N'566-63-4185', 23, NULL, 13, '2026-06-14', N'Occasional headaches, BP borderline at home checks', N'Worsening', 0, NULL, '2026-07-02'),
(7, N'509-96-9785', 28, NULL, 9, '2026-06-28', N'Fatigue, mild ankle swelling', N'Worsening', 0, NULL, '2026-07-11'),
(8, N'323-69-5198', 32, NULL, 1, '2026-06-14', N'Productive cough, mild dyspnea on exertion', N'Stable', 0, NULL, '2026-06-27'),
(9, N'807-29-9938', 36, NULL, 2, '2026-06-08', N'Mild wheeze with exertion, using inhaler 2x/week', N'Improving', 1, N'Stepped up to combination inhaler', '2026-06-26'),
(10, N'470-91-8532', 42, NULL, 1, '2026-05-30', N'Occasional headaches, BP borderline at home checks', N'Stable', 1, N'Increased Lisinopril to 20mg', '2026-06-22'),
(11, N'533-45-1722', 45, NULL, 5, '2026-06-18', N'Shortness of breath climbing stairs, improved from baseline', N'Improving', 1, N'Increased Furosemide dose', '2026-07-01'),
(12, N'458-49-4728', 57, NULL, 5, '2026-07-13', N'Mild wheeze with exertion, using inhaler 2x/week', N'Stable', 1, N'Stepped up to combination inhaler', '2026-07-12'),
(13, N'261-17-9320', 59, NULL, 5, '2026-07-03', N'Mild wheeze with exertion, using inhaler 2x/week', N'Improving', 0, NULL, '2026-07-10'),
(14, N'897-64-4585', 61, NULL, 8, '2026-06-27', N'Fatigue, mild ankle swelling', N'Improving', 0, NULL, '2026-07-10'),
(15, N'261-17-9320', 65, NULL, 12, '2026-06-05', N'Reports fatigue and cold intolerance', N'Improving', 0, NULL, '2026-06-23'),
(16, N'230-89-9751', NULL, NULL, 46, '2026-06-12', N'Incision healing well, no fever, tolerating regular diet', N'Stable', 0, NULL, '2026-07-03'),
(17, N'182-27-3471', NULL, NULL, 46, '2026-06-27', N'Mild wound erythema, no discharge, afebrile', N'Stable', 1, N'Extended oral antibiotic course by 3 days', '2026-07-18'),
(18, N'506-35-2245', NULL, NULL, 47, '2026-06-15', N'Ambulating with walker, physio progressing on schedule', N'Improving', 0, NULL, '2026-07-06');
SET IDENTITY_INSERT [followup] OFF;

GO

-- PATIENT ALLERGIES (clinical decision support)

SET IDENTITY_INSERT [patientallergy] ON;
INSERT INTO [patientallergy] ([id], [patientID], [drugID], [substanceName], [severity], [reaction], [recordedDate]) VALUES
(1, N'860-80-3546', 1, NULL, N'Severe', N'Anaphylaxis (documented in prior chart)', '2026-06-20'),
(2, N'242-23-9935', 5, NULL, N'Moderate', N'Facial swelling, hives', '2026-06-20'),
(3, N'489-22-6881', NULL, N'Sulfa drugs', N'Moderate', N'Widespread rash', '2026-06-20'),
(4, N'982-56-4150', NULL, N'Latex', N'Mild', N'Contact dermatitis', '2026-06-20'),
(5, N'266-57-6820', NULL, N'Penicillin family', N'Severe', N'Anaphylaxis', '2026-06-20'),
(6, N'505-92-8517', 12, NULL, N'Moderate', N'Severe nausea and itching', '2026-06-20'),
(7, N'621-73-2489', NULL, N'Iodinated contrast dye', N'Moderate', N'Hives, mild bronchospasm', '2026-06-20'),
(8, N'100-86-6310', 17, NULL, N'Mild', N'GI upset', '2026-06-20'),
(9, N'878-78-3060', NULL, N'Aspirin', N'Moderate', N'Wheezing', '2026-06-20'),
(10, N'830-49-7537', NULL, N'Codeine', N'Mild', N'Nausea', '2026-06-20');
SET IDENTITY_INSERT [patientallergy] OFF;

GO

-- APPOINTMENT TIMING BACKFILL (service-quality KPIs)

UPDATE [appointment]
SET
  [checkInTime]      = DATEADD(MINUTE, -1 * (4 + ([id] % 11)), CAST([date] AS datetime) + CAST([time] AS datetime)),
  [serviceStartTime] = DATEADD(MINUTE,      (3 + ([id] % 26)), CAST([date] AS datetime) + CAST([time] AS datetime)),
  [checkOutTime]     = DATEADD(MINUTE,      (25 + ([id] % 26) + (8 + ([id] % 14))), CAST([date] AS datetime) + CAST([time] AS datetime))
WHERE [id] IN (2, 3, 4, 8, 9, 10, 13, 14, 15, 17, 18, 23, 25, 27, 31, 34, 35, 39, 40, 48, 53, 54, 56, 58, 62, 64, 65, 73, 75, 84, 85, 87, 90, 101, 102, 105, 107, 108, 109, 115, 116, 122, 123, 130, 132, 133, 135, 139, 154, 156, 157, 162, 163, 164, 165, 166, 167, 169, 171, 176, 177, 180, 186, 195, 196, 197)

GO

-- ====PHASE 2 GOES LIVE ==== everything above was a historical backfill loaded

-- Schedule a new elective surgery through the app-facing procedure
DECLARE @newSurgeryID int;
EXEC [sp_ScheduleSurgery]
  @operatingRoomID = 1,
  @patientID       = N'478-46-3584',
  @scheduledStart  = '2026-07-22 08:30:00',
  @surgeonID       = 46,
  @procedureName   = N'Laparoscopic Cholecystectomy',
  @newSurgeryID    = @newSurgeryID OUTPUT;

-- A new prescription comes in for the patient with the on-file Amoxicillin allergy.
-- trg_prescriptionitem_safety_check fires on the INSERT into prescriptionitem below
-- and logs a Severe 'Allergy' row into prescriptionsafetyalert automatically —
-- nothing further to run, just query vw_PendingSafetyAlerts afterward to see it.
SET IDENTITY_INSERT [prescription] ON;
INSERT INTO [prescription] ([id], [patientID], [employeeID], [appointmentID], [admissionID], [date], [status]) VALUES
(101, N'860-80-3546', 2, NULL, 47, '2026-07-16', N'Pending');
SET IDENTITY_INSERT [prescription] OFF;

SET IDENTITY_INSERT [prescriptionitem] ON;
INSERT INTO [prescriptionitem] ([id], [prescriptionID], [drugID], [dose], [duration], [quantity]) VALUES
(213, 101, 1, N'500mg', N'7 days', 21);  -- Amoxicillin — patient has a Severe allergy on file
SET IDENTITY_INSERT [prescriptionitem] OFF;

-- Build the management dashboard snapshot for a handful of days across the dataset
-- (sp_RefreshDailyDepartmentStats is meant to run nightly in production; called
-- here manually to populate dailydepartmentstats for demonstration)
EXEC [sp_RefreshDailyDepartmentStats] @statDate = '2026-06-05';
EXEC [sp_RefreshDailyDepartmentStats] @statDate = '2026-06-10';
EXEC [sp_RefreshDailyDepartmentStats] @statDate = '2026-06-15';
EXEC [sp_RefreshDailyDepartmentStats] @statDate = '2026-06-20';

GO