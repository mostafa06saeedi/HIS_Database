-- TREATMENT OUTCOME (per diagnosed disease)
-- Records how a specific diagnosed condition ended (recovery, relapse, etc.)
CREATE TABLE [treatmentoutcome] (
  [id]                    int           IDENTITY(1,1) NOT NULL,
  [doctordiagnosisID]     int           NULL,
  [outcomeStatus]         nvarchar(255) NULL,   -- Recovered/Improved/Unchanged/Worsened/Relapsed/Deceased/ReferredOut
  [complicationICD_ID]    int           NULL,
  [complicationNote]      nvarchar(255) NULL,
  [evaluatedDate]         date          NULL,
  [evaluatedbyemployeeID] int           NULL,
  CONSTRAINT [PK_treatmentoutcome] PRIMARY KEY ([id])
)

-- FOLLOW-UP (post-visit monitoring)
-- Tracks follow-up visits: new symptoms, progress, and treatment changes
CREATE TABLE [followup] (
  [id]                int           IDENTITY(1,1) NOT NULL,
  [patientID]         nvarchar(255) NULL,
  [doctordiagnosisID] int           NULL,
  [appointmentID]     int           NULL,
  [employeeID]        int           NULL,
  [followUpDate]      date          NULL,
  [newSymptoms]       nvarchar(255) NULL,
  [progressStatus]    nvarchar(255) NULL,   -- Improving/Stable/Worsening
  [treatmentChanged]  bit           NULL,
  [changeDescription] nvarchar(255) NULL,
  [nextFollowUpDate]  date          NULL,
  CONSTRAINT [PK_followup] PRIMARY KEY ([id])
)

-- OPERATING ROOM & SURGERY (resource tracking)
-- Adds operating rooms as bookable resources and logs surgery start/end times
CREATE TABLE [operatingroom] (
  [id]           int           IDENTITY(1,1) NOT NULL,
  [departmentID] int           NULL,
  [roomNumber]   nvarchar(255) NULL,
  [status]       nvarchar(255) NULL,   -- Free/Occupied/UnderMaintenance
  CONSTRAINT [PK_operatingroom] PRIMARY KEY ([id])
)

CREATE TABLE [surgeryrecord] (
  [id]              int           IDENTITY(1,1) NOT NULL,
  [operatingRoomID] int           NULL,
  [patientID]       nvarchar(255) NULL,
  [admissionID]     int           NULL,
  [surgeonID]       int           NULL,
  [procedureName]   nvarchar(255) NULL,
  [scheduledStart]  datetime      NULL,
  [actualStart]     datetime      NULL,
  [actualEnd]       datetime      NULL,
  [status]          nvarchar(255) NULL,   -- Scheduled/InProgress/Completed/Cancelled
  CONSTRAINT [PK_surgeryrecord] PRIMARY KEY ([id])
)

-- CLINICAL DECISION SUPPORT (allergy & drug alerts)
-- Stores patient allergies and logs prescription safety alerts (drug interactions / allergies)
CREATE TABLE [patientallergy] (
  [id]            int           IDENTITY(1,1) NOT NULL,
  [patientID]     nvarchar(255) NULL,
  [drugID]        int           NULL,
  [substanceName] nvarchar(255) NULL,   -- free-text for non-drug allergens (e.g. Latex)
  [severity]      nvarchar(255) NULL,   -- Mild/Moderate/Severe
  [reaction]      nvarchar(255) NULL,
  [recordedDate]  date          NULL,
  CONSTRAINT [PK_patientallergy] PRIMARY KEY ([id])
)

CREATE TABLE [prescriptionsafetyalert] (
  [id]                      int           IDENTITY(1,1) NOT NULL,
  [prescriptionItemID]      int           NULL,
  [alertType]               nvarchar(255) NULL,   -- DrugInteraction/Allergy
  [relatedDrugID]           int           NULL,
  [severity]                nvarchar(255) NULL,   -- Minor/Moderate/Severe
  [message]                 nvarchar(255) NULL,
  [createdAt]               datetime      NULL,
  [acknowledgedbyemployeeID] int          NULL,
  [acknowledgedAt]          datetime      NULL,
  CONSTRAINT [PK_prescriptionsafetyalert] PRIMARY KEY ([id])
)

-- MANAGEMENT REPORTING (pre-aggregated stats)
-- Daily snapshot per department for fast dashboard queries
CREATE TABLE [dailydepartmentstats] (
  [id]                int           IDENTITY(1,1) NOT NULL,
  [statDate]          date          NULL,
  [departmentID]      int           NULL,
  [totalBeds]         int           NULL,
  [occupiedBeds]      int           NULL,
  [occupancyPercent]  float         NULL,
  [newAdmissions]     int           NULL,
  [discharges]        int           NULL,
  [appointmentsCount] int           NULL,
  [avgWaitMinutes]    float         NULL,
  CONSTRAINT [PK_dailydepartmentstats] PRIMARY KEY ([id])
)
GO

-- SERVICE QUALITY KPIs – extend appointment 
-- Adds actual check-in, service start, and check-out times to [appointment]
ALTER TABLE [appointment] ADD [checkInTime]      datetime NULL
ALTER TABLE [appointment] ADD [serviceStartTime] datetime NULL
ALTER TABLE [appointment] ADD [checkOutTime]     datetime NULL
GO

-- == FOREIGN KEY CONSTRAINTS ==
ALTER TABLE [treatmentoutcome]
  ADD CONSTRAINT [FK_treatmentoutcome_doctordiagnosis] FOREIGN KEY ([doctordiagnosisID]) REFERENCES [doctordiagnosis] ([id])

ALTER TABLE [treatmentoutcome]
  ADD CONSTRAINT [FK_treatmentoutcome_icddisease] FOREIGN KEY ([complicationICD_ID]) REFERENCES [icddisease] ([id])

ALTER TABLE [treatmentoutcome]
  ADD CONSTRAINT [FK_treatmentoutcome_employee] FOREIGN KEY ([evaluatedbyemployeeID]) REFERENCES [employee] ([id])

ALTER TABLE [followup]
  ADD CONSTRAINT [FK_followup_patient] FOREIGN KEY ([patientID]) REFERENCES [patient] ([nationalID])

ALTER TABLE [followup]
  ADD CONSTRAINT [FK_followup_doctordiagnosis] FOREIGN KEY ([doctordiagnosisID]) REFERENCES [doctordiagnosis] ([id])

ALTER TABLE [followup]
  ADD CONSTRAINT [FK_followup_appointment] FOREIGN KEY ([appointmentID]) REFERENCES [appointment] ([id])

ALTER TABLE [followup]
  ADD CONSTRAINT [FK_followup_employee] FOREIGN KEY ([employeeID]) REFERENCES [employee] ([id])

ALTER TABLE [operatingroom]
  ADD CONSTRAINT [FK_operatingroom_department] FOREIGN KEY ([departmentID]) REFERENCES [department] ([id])

ALTER TABLE [surgeryrecord]
  ADD CONSTRAINT [FK_surgeryrecord_operatingroom] FOREIGN KEY ([operatingRoomID]) REFERENCES [operatingroom] ([id])

ALTER TABLE [surgeryrecord]
  ADD CONSTRAINT [FK_surgeryrecord_patient] FOREIGN KEY ([patientID]) REFERENCES [patient] ([nationalID])

ALTER TABLE [surgeryrecord]
  ADD CONSTRAINT [FK_surgeryrecord_admission] FOREIGN KEY ([admissionID]) REFERENCES [admission] ([id])

ALTER TABLE [surgeryrecord]
  ADD CONSTRAINT [FK_surgeryrecord_surgeon] FOREIGN KEY ([surgeonID]) REFERENCES [surgeon] ([employeeID])

ALTER TABLE [patientallergy]
  ADD CONSTRAINT [FK_patientallergy_patient] FOREIGN KEY ([patientID]) REFERENCES [patient] ([nationalID])

ALTER TABLE [patientallergy]
  ADD CONSTRAINT [FK_patientallergy_drug] FOREIGN KEY ([drugID]) REFERENCES [drug] ([id])

ALTER TABLE [prescriptionsafetyalert]
  ADD CONSTRAINT [FK_prescriptionsafetyalert_item] FOREIGN KEY ([prescriptionItemID]) REFERENCES [prescriptionitem] ([id])

ALTER TABLE [prescriptionsafetyalert]
  ADD CONSTRAINT [FK_prescriptionsafetyalert_drug] FOREIGN KEY ([relatedDrugID]) REFERENCES [drug] ([id])

ALTER TABLE [prescriptionsafetyalert]
  ADD CONSTRAINT [FK_prescriptionsafetyalert_employee] FOREIGN KEY ([acknowledgedbyemployeeID]) REFERENCES [employee] ([id])

ALTER TABLE [dailydepartmentstats]
  ADD CONSTRAINT [FK_dailydepartmentstats_department] FOREIGN KEY ([departmentID]) REFERENCES [department] ([id])

-- == DEFAULT VALUES ==
ALTER TABLE [treatmentoutcome]        ADD CONSTRAINT [DF_treatmentoutcome_evaluatedDate] DEFAULT (GETDATE())     FOR [evaluatedDate]
ALTER TABLE [patientallergy]          ADD CONSTRAINT [DF_patientallergy_recordedDate]    DEFAULT (GETDATE())     FOR [recordedDate]
ALTER TABLE [followup]                ADD CONSTRAINT [DF_followup_treatmentChanged]      DEFAULT (0)             FOR [treatmentChanged]
ALTER TABLE [operatingroom]           ADD CONSTRAINT [DF_operatingroom_status]           DEFAULT (N'Free')       FOR [status]
ALTER TABLE [surgeryrecord]           ADD CONSTRAINT [DF_surgeryrecord_status]           DEFAULT (N'Scheduled')  FOR [status]
ALTER TABLE [prescriptionsafetyalert] ADD CONSTRAINT [DF_prescriptionsafetyalert_createdAt] DEFAULT (GETDATE()) FOR [createdAt]

-- == CHECK CONSTRAINTS ==
ALTER TABLE [treatmentoutcome]
  ADD CONSTRAINT [CK_treatmentoutcome_status] CHECK ([outcomeStatus] IN
      (N'Recovered', N'Improved', N'Unchanged', N'Worsened', N'Relapsed', N'Deceased', N'ReferredOut') OR [outcomeStatus] IS NULL)

ALTER TABLE [followup]
  ADD CONSTRAINT [CK_followup_progress] CHECK ([progressStatus] IN (N'Improving', N'Stable', N'Worsening') OR [progressStatus] IS NULL)

ALTER TABLE [operatingroom]
  ADD CONSTRAINT [CK_operatingroom_status] CHECK ([status] IN (N'Free', N'Occupied', N'UnderMaintenance') OR [status] IS NULL)

ALTER TABLE [surgeryrecord]
  ADD CONSTRAINT [CK_surgeryrecord_status] CHECK ([status] IN (N'Scheduled', N'InProgress', N'Completed', N'Cancelled') OR [status] IS NULL)

ALTER TABLE [surgeryrecord]
  ADD CONSTRAINT [CK_surgeryrecord_times] CHECK ([actualEnd] IS NULL OR [actualStart] IS NULL OR [actualEnd] >= [actualStart])

ALTER TABLE [patientallergy]
  ADD CONSTRAINT [CK_patientallergy_severity] CHECK ([severity] IN (N'Mild', N'Moderate', N'Severe') OR [severity] IS NULL)

ALTER TABLE [patientallergy]
  ADD CONSTRAINT [CK_patientallergy_source] CHECK ([drugID] IS NOT NULL OR [substanceName] IS NOT NULL)

ALTER TABLE [prescriptionsafetyalert]
  ADD CONSTRAINT [CK_prescriptionsafetyalert_type] CHECK ([alertType] IN (N'DrugInteraction', N'Allergy') OR [alertType] IS NULL)

ALTER TABLE [prescriptionsafetyalert]
  ADD CONSTRAINT [CK_prescriptionsafetyalert_severity] CHECK ([severity] IN (N'Minor', N'Moderate', N'Severe') OR [severity] IS NULL)

ALTER TABLE [appointment]
  ADD CONSTRAINT [CK_appointment_timing] CHECK (
        ([serviceStartTime] IS NULL OR [checkInTime] IS NULL OR [serviceStartTime] >= [checkInTime])
    AND ([checkOutTime]     IS NULL OR [serviceStartTime] IS NULL OR [checkOutTime] >= [serviceStartTime])
  )

-- == ALTER COLUMN TO NOT NULL (Data Integrity) ==
ALTER TABLE [followup]                ALTER COLUMN [patientID]    nvarchar(255) NOT NULL
ALTER TABLE [followup]                ALTER COLUMN [employeeID]   int           NOT NULL
ALTER TABLE [followup]                ALTER COLUMN [followUpDate] date          NOT NULL
ALTER TABLE [surgeryrecord]           ALTER COLUMN [patientID]    nvarchar(255) NOT NULL
ALTER TABLE [patientallergy]          ALTER COLUMN [patientID]    nvarchar(255) NOT NULL
ALTER TABLE [patientallergy]          ALTER COLUMN [severity]     nvarchar(255) NOT NULL
ALTER TABLE [prescriptionsafetyalert] ALTER COLUMN [prescriptionItemID] int     NOT NULL
ALTER TABLE [prescriptionsafetyalert] ALTER COLUMN [alertType]    nvarchar(255) NOT NULL
ALTER TABLE [prescriptionsafetyalert] ALTER COLUMN [severity]     nvarchar(255) NOT NULL

-- == UNIQUE CONSTRAINTS ==
ALTER TABLE [dailydepartmentstats]
  ADD CONSTRAINT [UQ_dailydepartmentstats_date_dept] UNIQUE ([statDate], [departmentID])

-- == INDEXES (Performance Optimization) ==
CREATE INDEX [IX_treatmentoutcome_doctordiagnosisID]     ON [treatmentoutcome] ([doctordiagnosisID])
CREATE INDEX [IX_followup_patientID]                     ON [followup] ([patientID])
CREATE INDEX [IX_followup_doctordiagnosisID]             ON [followup] ([doctordiagnosisID])
CREATE INDEX [IX_surgeryrecord_operatingRoomID]          ON [surgeryrecord] ([operatingRoomID])
CREATE INDEX [IX_surgeryrecord_patientID]                ON [surgeryrecord] ([patientID])
CREATE INDEX [IX_surgeryrecord_surgeonID]                ON [surgeryrecord] ([surgeonID])
CREATE INDEX [IX_patientallergy_patientID]               ON [patientallergy] ([patientID])
CREATE INDEX [IX_patientallergy_drugID]                  ON [patientallergy] ([drugID])
CREATE INDEX [IX_prescriptionsafetyalert_itemID]         ON [prescriptionsafetyalert] ([prescriptionItemID])
CREATE INDEX [IX_dailydepartmentstats_statDate]          ON [dailydepartmentstats] ([statDate])
GO