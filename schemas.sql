CREATE TABLE [patient] (
  [nationalID]  nvarchar(255) NOT NULL,
  [insuranceID] int           NULL,
  [name]        nvarchar(255) NULL,
  [datebirth]   date          NULL,
  [gender]      nvarchar(255) NULL,
  [phone]       nvarchar(255) NULL,
  [address]     nvarchar(255) NULL,
  CONSTRAINT [PK_patient] PRIMARY KEY ([nationalID])
)

CREATE TABLE [medicalrecord] (
  [id]               int           IDENTITY(1,1) NOT NULL,
  [patientID]        nvarchar(255) NULL,
  [preMedicalRecord] nvarchar(255) NULL,
  [predrugconsumption] nvarchar(255) NULL,
  [weight]           float         NULL,
  [height]           float         NULL,
  [bloodpressure]    nvarchar(255) NULL,
  [smokingHistory]   nvarchar(255) NULL,
  CONSTRAINT [PK_medicalrecord] PRIMARY KEY ([id]),
  CONSTRAINT [UQ_medicalrecord_patientID] UNIQUE ([patientID])
)

CREATE TABLE [insurance] (
  [id]              int           IDENTITY(1,1) NOT NULL,
  [name]            nvarchar(255) NULL,
  [type]            nvarchar(255) NULL,
  [coveragepercent] float         NULL,
  [isActive]        bit           NULL,
  CONSTRAINT [PK_insurance] PRIMARY KEY ([id])
)

CREATE TABLE [icddisease] (
  [id]   int           IDENTITY(1,1) NOT NULL,
  [code] nvarchar(255) NULL,
  [name] nvarchar(255) NULL,
  CONSTRAINT [PK_icddisease] PRIMARY KEY ([id])
)

CREATE TABLE [doctordiagnosis] (
  [id]          int           IDENTITY(1,1) NOT NULL,
  [appointmentID] int         NULL,
  [admissionID] int           NULL,
  [icdID]       int           NULL,
  [description] nvarchar(255) NULL,
  CONSTRAINT [PK_doctordiagnosis] PRIMARY KEY ([id])
)

CREATE TABLE [department] (
  [id]   int           IDENTITY(1,1) NOT NULL,
  [name] nvarchar(255) NULL,
  [type] nvarchar(255) NULL,
  CONSTRAINT [PK_department] PRIMARY KEY ([id])
)

CREATE TABLE [employee] (
  [id]            int           IDENTITY(1,1) NOT NULL,
  [departmentID]  int           NULL,
  [name]          nvarchar(255) NULL,
  [contractType]  nvarchar(255) NULL,
  [phone]         nvarchar(255) NULL,
  [role]          nvarchar(255) NULL,
  [specialization] nvarchar(255) NULL,
  [medicalsystemID] nvarchar(255) NULL,
  CONSTRAINT [PK_employee] PRIMARY KEY ([id])
)

CREATE TABLE [doctor] (
  [employeeID]      int           NOT NULL,
  [specialization]  nvarchar(255) NULL,
  [medicalLicenseNo] nvarchar(255) NULL,
  CONSTRAINT [PK_doctor] PRIMARY KEY ([employeeID])
)

CREATE TABLE [surgeon] (
  [employeeID]      int           NOT NULL,
  [surgicalSpecialty] nvarchar(255) NULL,
  CONSTRAINT [PK_surgeon] PRIMARY KEY ([employeeID])
)

CREATE TABLE [nurse] (
  [employeeID] int           NOT NULL,
  [grade]      nvarchar(255) NULL,
  CONSTRAINT [PK_nurse] PRIMARY KEY ([employeeID])
)

CREATE TABLE [adminstaff] (
  [employeeID] int           NOT NULL,
  [role]       nvarchar(255) NULL,
  CONSTRAINT [PK_adminstaff] PRIMARY KEY ([employeeID])
)

CREATE TABLE [shift] (
  [id]        int           IDENTITY(1,1) NOT NULL,
  [shiftDate] date          NULL,
  [startTime] time          NULL,
  [endTime]   time          NULL,
  [shiftType] nvarchar(255) NULL,
  CONSTRAINT [PK_shift] PRIMARY KEY ([id])
)

CREATE TABLE [employeeshift] (
  [id]         int IDENTITY(1,1) NOT NULL,
  [employeeID] int NULL,
  [shiftID]    int NULL,
  CONSTRAINT [PK_employeeshift] PRIMARY KEY ([id])
)

CREATE TABLE [appointment] (
  [id]               int           IDENTITY(1,1) NOT NULL,
  [employeeID]       int           NULL,
  [patientID]        nvarchar(255) NULL,
  [departmentID]     int           NULL,
  [date]             date          NULL,
  [time]             time          NULL,
  [status]           nvarchar(255) NULL,
  [appointment_type] nvarchar(255) NULL,
  CONSTRAINT [PK_appointment] PRIMARY KEY ([id])
)

CREATE TABLE [bed] (
  [id]           int           IDENTITY(1,1) NOT NULL,
  [departmentID] int           NULL,
  [status]       nvarchar(255) NULL,
  [room]         nvarchar(255) NULL,
  CONSTRAINT [PK_bed] PRIMARY KEY ([id])
)

CREATE TABLE [admission] (
  [id]            int           IDENTITY(1,1) NOT NULL,
  [patientID]     nvarchar(255) NULL,
  [bedID]         int           NULL,
  [employeeID]    int           NULL,
  [appointmentID] int           NULL,
  [entrydate]     date          NULL,
  [exitdate]      date          NULL,
  [reason]        nvarchar(255) NULL,
  CONSTRAINT [PK_admission] PRIMARY KEY ([id])
)

CREATE TABLE [patienttransfer] (
  [id]          int           IDENTITY(1,1) NOT NULL,
  [date]        date          NULL,
  [time]        time          NULL,
  [reason]      nvarchar(255) NULL,
  [admissionID] int           NULL,
  [fromBedID]   int           NULL,
  [toBedID]     int           NULL,
  CONSTRAINT [PK_patienttransfer] PRIMARY KEY ([id])
)

CREATE TABLE [Labimagingrequest] (
  [id]            int           IDENTITY(1,1) NOT NULL,
  [employeeID]    int           NULL,
  [appointmentID] int           NULL,
  [admissionID]   int           NULL,
  [type]          nvarchar(255) NULL,
  [date]          date          NULL,
  [status]        nvarchar(255) NULL,
  CONSTRAINT [PK_Labimagingrequest] PRIMARY KEY ([id])
)

CREATE TABLE [isCritical] (
  [id]               int           IDENTITY(1,1) NOT NULL,
  [type]             nvarchar(255) NULL,
  [referenceMin]     float         NULL,
  [referenceMax]     float         NULL,
  [isCritical_status] nvarchar(255) NULL,
  [unit]             nvarchar(255) NULL,
  CONSTRAINT [PK_isCritical] PRIMARY KEY ([id])
)

CREATE TABLE [labresult] (
  [id]                    int           IDENTITY(1,1) NOT NULL,
  [reportedbyemployeeID]  int           NULL,
  [isCritical]            int           NULL,
  [LabimagingrequestID]   int           NULL,
  [value]                 nvarchar(255) NULL,
  [status]                nvarchar(255) NULL,
  [date]                  date          NULL,
  [description]           nvarchar(255) NULL,
  CONSTRAINT [PK_labresult] PRIMARY KEY ([id])
)

CREATE TABLE [labalert] (
  [id]          int           IDENTITY(1,1) NOT NULL,
  [doctorID]    int           NULL,
  [labResultID] int           NULL,
  [severity]    nvarchar(255) NULL,
  [status]      nvarchar(255) NULL,
  [createdAt]   date          NULL,
  [resolvedAt]  date          NULL,
  CONSTRAINT [PK_labalert] PRIMARY KEY ([id])
)

CREATE TABLE [prescription] (
  [id]            int           IDENTITY(1,1) NOT NULL,
  [patientID]     nvarchar(255) NULL,
  [employeeID]    int           NULL,
  [appointmentID] int           NULL,
  [admissionID]   int           NULL,
  [date]          date          NULL,
  [status]        nvarchar(255) NULL,
  CONSTRAINT [PK_prescription] PRIMARY KEY ([id])
)

CREATE TABLE [drug] (
  [id]          int           IDENTITY(1,1) NOT NULL,
  [name]        nvarchar(255) NULL,
  [type]        nvarchar(255) NULL,
  [description] nvarchar(255) NULL,
  CONSTRAINT [PK_drug] PRIMARY KEY ([id])
)

CREATE TABLE [prescriptionitem] (
  [id]             int           IDENTITY(1,1) NOT NULL,
  [prescriptionID] int           NULL,
  [drugID]         int           NULL,
  [dose]           nvarchar(255) NULL,
  [duration]       nvarchar(255) NULL,
  [quantity]       int           NULL,
  CONSTRAINT [PK_prescriptionitem] PRIMARY KEY ([id])
)

CREATE TABLE [storage] (
  [id]        int           IDENTITY(1,1) NOT NULL,
  [name]      nvarchar(255) NULL,
  [inventory] int           NULL,
  [type]      nvarchar(255) NULL,
  CONSTRAINT [PK_storage] PRIMARY KEY ([id])
)

CREATE TABLE [storage_transaction] (
  [id]        int           IDENTITY(1,1) NOT NULL,
  [drugID]    int           NULL,
  [storageID] int           NULL,
  [date]      date          NULL,
  [type]      nvarchar(255) NULL,
  [quantity]  int           NULL,
  [reason]    nvarchar(255) NULL,
  CONSTRAINT [PK_storage_transaction] PRIMARY KEY ([id])
)

CREATE TABLE [paymentmethod] (
  [id]   int           IDENTITY(1,1) NOT NULL,
  [type] nvarchar(255) NULL,
  CONSTRAINT [PK_paymentmethod] PRIMARY KEY ([id])
)

CREATE TABLE [invoice] (
  [id]              int           IDENTITY(1,1) NOT NULL,
  [patientID]       nvarchar(255) NULL,
  [admissionID]     int           NULL,
  [appointmentID]   int           NULL,
  [insuranceId]     int           NULL,
  [paymentmethodID] int           NULL,
  [total_amount]    float         NULL,
  [status]          nvarchar(255) NULL,
  [date]            date          NULL,
  [insuranceAmount] float         NULL,
  [patientAmount]   float         NULL,
  [paidAmount]      float         NOT NULL DEFAULT (0),
  CONSTRAINT [PK_invoice] PRIMARY KEY ([id])
)

CREATE TABLE [invoiceitem] (
  [id]          int           IDENTITY(1,1) NOT NULL,
  [invoiceID]   int           NULL,
  [item]        nvarchar(255) NULL,
  [type]        nvarchar(255) NULL,
  [description] nvarchar(255) NULL,
  [amount]      float         NULL,
  CONSTRAINT [PK_invoiceitem] PRIMARY KEY ([id])
)

CREATE TABLE [payment] (
  [id]              int           IDENTITY(1,1) NOT NULL,
  [invoiceID]       int           NOT NULL,
  [patientID]       nvarchar(255) NOT NULL,
  [paymentmethodID] int           NULL,
  [amount]          float         NOT NULL,
  [type]            nvarchar(50)  NOT NULL DEFAULT ('Payment'),
  [date]            datetime      NOT NULL DEFAULT (GETDATE()),
  CONSTRAINT [PK_payment] PRIMARY KEY ([id]),
  CONSTRAINT [FK_payment_invoice] FOREIGN KEY ([invoiceID]) REFERENCES [invoice] ([id]),
  CONSTRAINT [FK_payment_patient] FOREIGN KEY ([patientID]) REFERENCES [patient] ([nationalID]),
  CONSTRAINT [FK_payment_paymentmethod] FOREIGN KEY ([paymentmethodID]) REFERENCES [paymentmethod] ([id]),
  CONSTRAINT [CK_payment_type] CHECK ([type] IN (N'Prepayment', N'Payment')),
  CONSTRAINT [CK_payment_amount] CHECK ([amount] > 0)
)

CREATE TABLE [druginteraction] (
  [id]          int           IDENTITY(1,1) NOT NULL,
  [drugID1]     int           NOT NULL,
  [drugID2]     int           NOT NULL,
  [severity]    nvarchar(50)  NULL,
  [description] nvarchar(255) NULL,
  CONSTRAINT [PK_druginteraction] PRIMARY KEY ([id]),
  CONSTRAINT [FK_druginteraction_drug1] FOREIGN KEY ([drugID1]) REFERENCES [drug] ([id]),
  CONSTRAINT [FK_druginteraction_drug2] FOREIGN KEY ([drugID2]) REFERENCES [drug] ([id]),
  CONSTRAINT [CK_druginteraction_distinct] CHECK ([drugID1] <> [drugID2]),
  CONSTRAINT [CK_druginteraction_severity] CHECK ([severity] IN (N'Minor', N'Moderate', N'Severe') OR [severity] IS NULL)
)

ALTER TABLE [druginteraction]
  ADD [drugPairLow]  AS (CASE WHEN [drugID1] < [drugID2] THEN [drugID1] ELSE [drugID2] END) PERSISTED,
      [drugPairHigh] AS (CASE WHEN [drugID1] < [drugID2] THEN [drugID2] ELSE [drugID1] END) PERSISTED

ALTER TABLE [druginteraction]
  ADD CONSTRAINT [UQ_druginteraction_unordered_pair] UNIQUE ([drugPairLow], [drugPairHigh])

CREATE TABLE [UserAccount] (
  [id]            int              IDENTITY(1,1) NOT NULL,
  [username]      nvarchar(100)    NOT NULL,
  [passwordHash]  varbinary(64)    NOT NULL,
  [passwordSalt]  uniqueidentifier NOT NULL DEFAULT (NEWID()),
  [role]          nvarchar(50)     NOT NULL,
  [patientID]     nvarchar(255)    NULL,
  [employeeID]    int              NULL,
  [isActive]      bit              NOT NULL DEFAULT (1),
  [createdAt]     datetime         NOT NULL DEFAULT (GETDATE()),
  [lastLoginAt]   datetime         NULL,
  CONSTRAINT [PK_UserAccount] PRIMARY KEY ([id]),
  CONSTRAINT [UQ_UserAccount_username] UNIQUE ([username]),
  CONSTRAINT [FK_UserAccount_patient]  FOREIGN KEY ([patientID])  REFERENCES [patient] ([nationalID]),
  CONSTRAINT [FK_UserAccount_employee] FOREIGN KEY ([employeeID]) REFERENCES [employee] ([id]),
  CONSTRAINT [CK_UserAccount_role] CHECK ([role] IN
      (N'Patient', N'Doctor', N'Nurse', N'Pharmacist', N'LabTech', N'Reception', N'Manager')),
  CONSTRAINT [CK_UserAccount_owner] CHECK (
      ([role] = N'Patient' AND [patientID] IS NOT NULL AND [employeeID] IS NULL)
   OR ([role] <> N'Patient' AND [employeeID] IS NOT NULL AND [patientID] IS NULL)
  )
)

CREATE INDEX [IX_UserAccount_patientID]  ON [UserAccount] ([patientID])
CREATE INDEX [IX_UserAccount_employeeID] ON [UserAccount] ([employeeID])

CREATE TABLE [iotdevice] (
  [id]               int           IDENTITY(1,1) NOT NULL,
  [macaddress]       nvarchar(255) NULL,
  [type]             nvarchar(255) NULL,
  [status]           nvarchar(255) NULL,
  [installationdate] date          NULL,
  CONSTRAINT [PK_iotdevice] PRIMARY KEY ([id])
)

CREATE TABLE [devicetransfer] (
  [id]          int           IDENTITY(1,1) NOT NULL,
  [patientID]   nvarchar(255) NULL,
  [admissionID] int           NULL,
  [departmentID] int          NULL,
  [bedID]       int           NULL,
  [iotdeviceID] int           NULL,
  [assignedAt]  date          NULL,
  [unassignedAt] date         NULL,
  CONSTRAINT [PK_devicetransfer] PRIMARY KEY ([id])
)

CREATE TABLE [logs] (
  [id]        int           IDENTITY(1,1) NOT NULL,
  [deviceID]  int           NULL,
  [timestamp] datetime      NULL,
  [type]      nvarchar(255) NULL,
  [value]     float         NULL,
  [unit]      nvarchar(255) NULL,
  CONSTRAINT [PK_logs] PRIMARY KEY ([id])
)

CREATE TABLE [alert] (
  [id]                       int           IDENTITY(1,1) NOT NULL,
  [logID]                    int           NULL,
  [alertThresholdID]         int           NULL,
  [acknowledgedbyemployeeID] int           NULL,
  [severity]                 nvarchar(255) NULL,
  [status]                   nvarchar(255) NULL,
  [createdtime]              datetime      NULL,
  [resolvedtime]             datetime      NULL,
  CONSTRAINT [PK_alert] PRIMARY KEY ([id])
)

CREATE TABLE [AlertThreshold] (
  [id]              int           IDENTITY(1,1) NOT NULL,
  [measurementType] nvarchar(255) NULL,
  [minValue]        float         NULL,
  [maxValue]        float         NULL,
  [severity]        nvarchar(255) NULL,
  [isGlobal]        bit           NULL,
  [employeeID]      int           NULL,
  [patientID]       nvarchar(255) NULL,
  [createdate]      date          NULL,
  CONSTRAINT [PK_AlertThreshold] PRIMARY KEY ([id])
)

ALTER TABLE [patient]
  ADD CONSTRAINT [FK_patient_insurance]
  FOREIGN KEY ([insuranceID]) REFERENCES [insurance] ([id])

ALTER TABLE [medicalrecord]
  ADD CONSTRAINT [FK_medicalrecord_patient]
  FOREIGN KEY ([patientID]) REFERENCES [patient] ([nationalID])

ALTER TABLE [doctordiagnosis]
  ADD CONSTRAINT [FK_doctordiagnosis_appointment]
  FOREIGN KEY ([appointmentID]) REFERENCES [appointment] ([id])

ALTER TABLE [doctordiagnosis]
  ADD CONSTRAINT [FK_doctordiagnosis_admission]
  FOREIGN KEY ([admissionID]) REFERENCES [admission] ([id])

ALTER TABLE [doctordiagnosis]
  ADD CONSTRAINT [FK_doctordiagnosis_icddisease]
  FOREIGN KEY ([icdID]) REFERENCES [icddisease] ([id])

ALTER TABLE [employee]
  ADD CONSTRAINT [FK_employee_department]
  FOREIGN KEY ([departmentID]) REFERENCES [department] ([id])

ALTER TABLE [doctor]
  ADD CONSTRAINT [FK_doctor_employee]
  FOREIGN KEY ([employeeID]) REFERENCES [employee] ([id])

ALTER TABLE [surgeon]
  ADD CONSTRAINT [FK_surgeon_employee]
  FOREIGN KEY ([employeeID]) REFERENCES [employee] ([id])

ALTER TABLE [nurse]
  ADD CONSTRAINT [FK_nurse_employee]
  FOREIGN KEY ([employeeID]) REFERENCES [employee] ([id])

ALTER TABLE [adminstaff]
  ADD CONSTRAINT [FK_adminstaff_employee]
  FOREIGN KEY ([employeeID]) REFERENCES [employee] ([id])

ALTER TABLE [employeeshift]
  ADD CONSTRAINT [FK_employeeshift_employee]
  FOREIGN KEY ([employeeID]) REFERENCES [employee] ([id])

ALTER TABLE [employeeshift]
  ADD CONSTRAINT [FK_employeeshift_shift]
  FOREIGN KEY ([shiftID]) REFERENCES [shift] ([id])

ALTER TABLE [appointment]
  ADD CONSTRAINT [FK_appointment_patient]
  FOREIGN KEY ([patientID]) REFERENCES [patient] ([nationalID])

ALTER TABLE [appointment]
  ADD CONSTRAINT [FK_appointment_department]
  FOREIGN KEY ([departmentID]) REFERENCES [department] ([id])

ALTER TABLE [appointment]
  ADD CONSTRAINT [FK_appointment_employee]
  FOREIGN KEY ([employeeID]) REFERENCES [employee] ([id])

ALTER TABLE [admission]
  ADD CONSTRAINT [FK_admission_patient]
  FOREIGN KEY ([patientID]) REFERENCES [patient] ([nationalID])

ALTER TABLE [admission]
  ADD CONSTRAINT [FK_admission_bed]
  FOREIGN KEY ([bedID]) REFERENCES [bed] ([id])

ALTER TABLE [admission]
  ADD CONSTRAINT [FK_admission_employee]
  FOREIGN KEY ([employeeID]) REFERENCES [employee] ([id])

ALTER TABLE [admission]
  ADD CONSTRAINT [FK_admission_appointment]
  FOREIGN KEY ([appointmentID]) REFERENCES [appointment] ([id])

ALTER TABLE [bed]
  ADD CONSTRAINT [FK_bed_department]
  FOREIGN KEY ([departmentID]) REFERENCES [department] ([id])

ALTER TABLE [patienttransfer]
  ADD CONSTRAINT [FK_patienttransfer_admission]
  FOREIGN KEY ([admissionID]) REFERENCES [admission] ([id])

ALTER TABLE [patienttransfer]
  ADD CONSTRAINT [FK_patienttransfer_fromBed]
  FOREIGN KEY ([fromBedID]) REFERENCES [bed] ([id])

ALTER TABLE [patienttransfer]
  ADD CONSTRAINT [FK_patienttransfer_toBed]
  FOREIGN KEY ([toBedID]) REFERENCES [bed] ([id])

ALTER TABLE [Labimagingrequest]
  ADD CONSTRAINT [FK_Labimagingrequest_employee]
  FOREIGN KEY ([employeeID]) REFERENCES [employee] ([id])

ALTER TABLE [Labimagingrequest]
  ADD CONSTRAINT [FK_Labimagingrequest_appointment]
  FOREIGN KEY ([appointmentID]) REFERENCES [appointment] ([id])

ALTER TABLE [Labimagingrequest]
  ADD CONSTRAINT [FK_Labimagingrequest_admission]
  FOREIGN KEY ([admissionID]) REFERENCES [admission] ([id])

ALTER TABLE [labresult]
  ADD CONSTRAINT [FK_labresult_employee]
  FOREIGN KEY ([reportedbyemployeeID]) REFERENCES [employee] ([id])

ALTER TABLE [labresult]
  ADD CONSTRAINT [FK_labresult_isCritical]
  FOREIGN KEY ([isCritical]) REFERENCES [isCritical] ([id])

ALTER TABLE [labresult]
  ADD CONSTRAINT [FK_labresult_Labimagingrequest]
  FOREIGN KEY ([LabimagingrequestID]) REFERENCES [Labimagingrequest] ([id])

ALTER TABLE [labalert]
  ADD CONSTRAINT [FK_labalert_doctor]
  FOREIGN KEY ([doctorID]) REFERENCES [doctor] ([employeeID])

ALTER TABLE [labalert]
  ADD CONSTRAINT [FK_labalert_labresult]
  FOREIGN KEY ([labResultID]) REFERENCES [labresult] ([id])

ALTER TABLE [prescription]
  ADD CONSTRAINT [FK_prescription_patient]
  FOREIGN KEY ([patientID]) REFERENCES [patient] ([nationalID])

ALTER TABLE [prescription]
  ADD CONSTRAINT [FK_prescription_employee]
  FOREIGN KEY ([employeeID]) REFERENCES [employee] ([id])

ALTER TABLE [prescription]
  ADD CONSTRAINT [FK_prescription_appointment]
  FOREIGN KEY ([appointmentID]) REFERENCES [appointment] ([id])

ALTER TABLE [prescription]
  ADD CONSTRAINT [FK_prescription_admission]
  FOREIGN KEY ([admissionID]) REFERENCES [admission] ([id])

ALTER TABLE [prescriptionitem]
  ADD CONSTRAINT [FK_prescriptionitem_prescription]
  FOREIGN KEY ([prescriptionID]) REFERENCES [prescription] ([id])

ALTER TABLE [prescriptionitem]
  ADD CONSTRAINT [FK_prescriptionitem_drug]
  FOREIGN KEY ([drugID]) REFERENCES [drug] ([id])

ALTER TABLE [storage_transaction]
  ADD CONSTRAINT [FK_storage_transaction_drug]
  FOREIGN KEY ([drugID]) REFERENCES [drug] ([id])

ALTER TABLE [storage_transaction]
  ADD CONSTRAINT [FK_storage_transaction_storage]
  FOREIGN KEY ([storageID]) REFERENCES [storage] ([id])

ALTER TABLE [invoice]
  ADD CONSTRAINT [FK_invoice_patient]
  FOREIGN KEY ([patientID]) REFERENCES [patient] ([nationalID])

ALTER TABLE [invoice]
  ADD CONSTRAINT [FK_invoice_admission]
  FOREIGN KEY ([admissionID]) REFERENCES [admission] ([id])

ALTER TABLE [invoice]
  ADD CONSTRAINT [FK_invoice_appointment]
  FOREIGN KEY ([appointmentID]) REFERENCES [appointment] ([id])

ALTER TABLE [labalert]
  ADD CONSTRAINT [FK_labalert_labresult]
  FOREIGN KEY ([labResultID]) REFERENCES [labresult] ([id])

ALTER TABLE [prescription]
  ADD CONSTRAINT [FK_prescription_patient]
  FOREIGN KEY ([patientID]) REFERENCES [patient] ([nationalID])

ALTER TABLE [prescription]
  ADD CONSTRAINT [FK_prescription_employee]
  FOREIGN KEY ([employeeID]) REFERENCES [employee] ([id])

ALTER TABLE [prescription]
  ADD CONSTRAINT [FK_prescription_appointment]
  FOREIGN KEY ([appointmentID]) REFERENCES [appointment] ([id])

ALTER TABLE [prescription]
  ADD CONSTRAINT [FK_prescription_admission]
  FOREIGN KEY ([admissionID]) REFERENCES [admission] ([id])

ALTER TABLE [prescriptionitem]
  ADD CONSTRAINT [FK_prescriptionitem_prescription]
  FOREIGN KEY ([prescriptionID]) REFERENCES [prescription] ([id])

ALTER TABLE [prescriptionitem]
  ADD CONSTRAINT [FK_prescriptionitem_drug]
  FOREIGN KEY ([drugID]) REFERENCES [drug] ([id])

ALTER TABLE [storage_transaction]
  ADD CONSTRAINT [FK_storage_transaction_drug]
  FOREIGN KEY ([drugID]) REFERENCES [drug] ([id])

ALTER TABLE [storage_transaction]
  ADD CONSTRAINT [FK_storage_transaction_storage]
  FOREIGN KEY ([storageID]) REFERENCES [storage] ([id])

ALTER TABLE [invoice]
  ADD CONSTRAINT [FK_invoice_patient]
  FOREIGN KEY ([patientID]) REFERENCES [patient] ([nationalID])

ALTER TABLE [invoice]
  ADD CONSTRAINT [FK_invoice_admission]
  FOREIGN KEY ([admissionID]) REFERENCES [admission] ([id])

ALTER TABLE [invoice]
  ADD CONSTRAINT [FK_invoice_appointment]
  FOREIGN KEY ([appointmentID]) REFERENCES [appointment] ([id])

ALTER TABLE [invoice]
  ADD CONSTRAINT [FK_invoice_insurance]
  FOREIGN KEY ([insuranceId]) REFERENCES [insurance] ([id])

ALTER TABLE [invoice]
  ADD CONSTRAINT [FK_invoice_paymentmethod]
  FOREIGN KEY ([paymentmethodID]) REFERENCES [paymentmethod] ([id])

ALTER TABLE [invoiceitem]
  ADD CONSTRAINT [FK_invoiceitem_invoice]
  FOREIGN KEY ([invoiceID]) REFERENCES [invoice] ([id])

ALTER TABLE [devicetransfer]
  ADD CONSTRAINT [FK_devicetransfer_patient]
  FOREIGN KEY ([patientID]) REFERENCES [patient] ([nationalID])

ALTER TABLE [devicetransfer]
  ADD CONSTRAINT [FK_devicetransfer_admission]
  FOREIGN KEY ([admissionID]) REFERENCES [admission] ([id])

ALTER TABLE [devicetransfer]
  ADD CONSTRAINT [FK_devicetransfer_department]
  FOREIGN KEY ([departmentID]) REFERENCES [department] ([id])

ALTER TABLE [devicetransfer]
  ADD CONSTRAINT [FK_devicetransfer_bed]
  FOREIGN KEY ([bedID]) REFERENCES [bed] ([id])

ALTER TABLE [devicetransfer]
  ADD CONSTRAINT [FK_devicetransfer_iotdevice]
  FOREIGN KEY ([iotdeviceID]) REFERENCES [iotdevice] ([id])

ALTER TABLE [logs]
  ADD CONSTRAINT [FK_logs_iotdevice]
  FOREIGN KEY ([deviceID]) REFERENCES [iotdevice] ([id])

ALTER TABLE [alert]
  ADD CONSTRAINT [FK_alert_logs]
  FOREIGN KEY ([logID]) REFERENCES [logs] ([id])

ALTER TABLE [alert]
  ADD CONSTRAINT [FK_alert_AlertThreshold]
  FOREIGN KEY ([alertThresholdID]) REFERENCES [AlertThreshold] ([id])

ALTER TABLE [alert]
  ADD CONSTRAINT [FK_alert_employee]
  FOREIGN KEY ([acknowledgedbyemployeeID]) REFERENCES [employee] ([id])

ALTER TABLE [AlertThreshold]
  ADD CONSTRAINT [FK_AlertThreshold_employee]
  FOREIGN KEY ([employeeID]) REFERENCES [employee] ([id])

ALTER TABLE [AlertThreshold]
  ADD CONSTRAINT [FK_AlertThreshold_patient]
  FOREIGN KEY ([patientID]) REFERENCES [patient] ([nationalID])


ALTER TABLE [insurance]        ADD CONSTRAINT [DF_insurance_isActive]        DEFAULT (1)              FOR [isActive]
ALTER TABLE [AlertThreshold]   ADD CONSTRAINT [DF_AlertThreshold_isGlobal]   DEFAULT (1)              FOR [isGlobal]
ALTER TABLE [AlertThreshold]   ADD CONSTRAINT [DF_AlertThreshold_createdate] DEFAULT (GETDATE())      FOR [createdate]
ALTER TABLE [appointment]      ADD CONSTRAINT [DF_appointment_status]       DEFAULT (N'Scheduled')   FOR [status]
ALTER TABLE [bed]              ADD CONSTRAINT [DF_bed_status]               DEFAULT (N'Free')        FOR [status]
ALTER TABLE [prescription]     ADD CONSTRAINT [DF_prescription_status]      DEFAULT (N'Pending')     FOR [status]
ALTER TABLE [prescription]     ADD CONSTRAINT [DF_prescription_date]        DEFAULT (GETDATE())      FOR [date]
ALTER TABLE [invoice]          ADD CONSTRAINT [DF_invoice_status]           DEFAULT (N'Unpaid')      FOR [status]
ALTER TABLE [invoice]          ADD CONSTRAINT [DF_invoice_date]             DEFAULT (GETDATE())      FOR [date]
ALTER TABLE [invoice]          ADD CONSTRAINT [DF_invoice_total]            DEFAULT (0)              FOR [total_amount]
ALTER TABLE [storage]          ADD CONSTRAINT [DF_storage_inventory]        DEFAULT (0)              FOR [inventory]
ALTER TABLE [storage_transaction] ADD CONSTRAINT [DF_storagetransaction_date] DEFAULT (GETDATE())    FOR [date]
ALTER TABLE [iotdevice]        ADD CONSTRAINT [DF_iotdevice_status]         DEFAULT (N'Active')      FOR [status]
ALTER TABLE [iotdevice]        ADD CONSTRAINT [DF_iotdevice_installdate]    DEFAULT (GETDATE())      FOR [installationdate]
ALTER TABLE [logs]             ADD CONSTRAINT [DF_logs_timestamp]           DEFAULT (GETDATE())      FOR [timestamp]
ALTER TABLE [alert]            ADD CONSTRAINT [DF_alert_status]             DEFAULT (N'Unreviewed')  FOR [status]
ALTER TABLE [alert]            ADD CONSTRAINT [DF_alert_createdtime]        DEFAULT (GETDATE())      FOR [createdtime]
ALTER TABLE [labalert]         ADD CONSTRAINT [DF_labalert_status]          DEFAULT (N'Unreviewed')  FOR [status]
ALTER TABLE [labalert]         ADD CONSTRAINT [DF_labalert_createdAt]       DEFAULT (GETDATE())      FOR [createdAt]
ALTER TABLE [Labimagingrequest] ADD CONSTRAINT [DF_Labimagingrequest_status] DEFAULT (N'Requested')  FOR [status]
ALTER TABLE [Labimagingrequest] ADD CONSTRAINT [DF_Labimagingrequest_date]  DEFAULT (GETDATE())      FOR [date]
ALTER TABLE [labresult]        ADD CONSTRAINT [DF_labresult_status]         DEFAULT (N'Pending')     FOR [status]
ALTER TABLE [labresult]        ADD CONSTRAINT [DF_labresult_date]           DEFAULT (GETDATE())      FOR [date]
ALTER TABLE [admission]        ADD CONSTRAINT [DF_admission_entrydate]      DEFAULT (GETDATE())      FOR [entrydate]


ALTER TABLE [patient]
  ADD CONSTRAINT [CK_patient_gender] CHECK ([gender] IN (N'Male', N'Female') OR [gender] IS NULL)

ALTER TABLE [bed]
  ADD CONSTRAINT [CK_bed_status] CHECK ([status] IN (N'Free', N'Reserved', N'Occupied'))

ALTER TABLE [admission]
  ADD CONSTRAINT [CK_admission_dates] CHECK ([exitdate] IS NULL OR [exitdate] >= [entrydate])

ALTER TABLE [appointment]
  ADD CONSTRAINT [CK_appointment_status] CHECK ([status] IN (N'Scheduled', N'Completed', N'Cancelled', N'Rescheduled'))

ALTER TABLE [appointment]
  ADD CONSTRAINT [CK_appointment_type] CHECK ([appointment_type] IN (N'InPerson', N'Online') OR [appointment_type] IS NULL)

ALTER TABLE [doctordiagnosis]
  ADD CONSTRAINT [CK_doctordiagnosis_source] CHECK ([appointmentID] IS NOT NULL OR [admissionID] IS NOT NULL)

ALTER TABLE [Labimagingrequest]
  ADD CONSTRAINT [CK_Labimagingrequest_type] CHECK ([type] IN (N'Lab', N'Imaging'))

ALTER TABLE [Labimagingrequest]
  ADD CONSTRAINT [CK_Labimagingrequest_status] CHECK ([status] IN (N'Requested', N'InProgress', N'Completed'))

ALTER TABLE [Labimagingrequest]
  ADD CONSTRAINT [CK_Labimagingrequest_source] CHECK ([appointmentID] IS NOT NULL OR [admissionID] IS NOT NULL)

ALTER TABLE [labresult]
  ADD CONSTRAINT [CK_labresult_status] CHECK ([status] IN (N'Pending', N'Completed'))

ALTER TABLE [labalert]
  ADD CONSTRAINT [CK_labalert_severity] CHECK ([severity] IN (N'Normal', N'Moderate', N'Critical'))

ALTER TABLE [labalert]
  ADD CONSTRAINT [CK_labalert_status] CHECK ([status] IN (N'Unreviewed', N'ConfirmedByNurse', N'Resolved'))

ALTER TABLE [prescription]
  ADD CONSTRAINT [CK_prescription_status] CHECK ([status] IN (N'Pending', N'Dispensed', N'Cancelled'))

ALTER TABLE [prescription]
  ADD CONSTRAINT [CK_prescription_source] CHECK ([appointmentID] IS NOT NULL OR [admissionID] IS NOT NULL)

ALTER TABLE [prescriptionitem]
  ADD CONSTRAINT [CK_prescriptionitem_quantity] CHECK ([quantity] > 0)

ALTER TABLE [storage_transaction]
  ADD CONSTRAINT [CK_storagetransaction_type] CHECK ([type] IN (N'IN', N'OUT'))

ALTER TABLE [storage_transaction]
  ADD CONSTRAINT [CK_storagetransaction_quantity] CHECK ([quantity] > 0)

ALTER TABLE [invoice]
  ADD CONSTRAINT [CK_invoice_status] CHECK ([status] IN (N'Unpaid', N'PartiallyPaid', N'Paid'))

ALTER TABLE [invoice]
  ADD CONSTRAINT [CK_invoice_source] CHECK ([admissionID] IS NOT NULL OR [appointmentID] IS NOT NULL)

ALTER TABLE [iotdevice]
  ADD CONSTRAINT [CK_iotdevice_status] CHECK ([status] IN (N'Active', N'Inactive', N'UnderMaintenance'))

ALTER TABLE [alert]
  ADD CONSTRAINT [CK_alert_severity] CHECK ([severity] IN (N'Normal', N'Moderate', N'Critical'))

ALTER TABLE [alert]
  ADD CONSTRAINT [CK_alert_status] CHECK ([status] IN (N'Unreviewed', N'ConfirmedByNurse', N'Resolved'))

ALTER TABLE [AlertThreshold]
  ADD CONSTRAINT [CK_AlertThreshold_severity] CHECK ([severity] IN (N'Normal', N'Moderate', N'Critical'))

ALTER TABLE [AlertThreshold]
  ADD CONSTRAINT [CK_AlertThreshold_range] CHECK ([maxValue] IS NULL OR [minValue] IS NULL OR [maxValue] >= [minValue])


ALTER TABLE [patient]            ALTER COLUMN [name]        nvarchar(255) NOT NULL
ALTER TABLE [employee]           ALTER COLUMN [name]        nvarchar(255) NOT NULL
ALTER TABLE [drug]               ALTER COLUMN [name]        nvarchar(255) NOT NULL
ALTER TABLE [appointment]        ALTER COLUMN [patientID]   nvarchar(255) NOT NULL
ALTER TABLE [admission]          ALTER COLUMN [patientID]   nvarchar(255) NOT NULL
ALTER TABLE [admission]          ALTER COLUMN [bedID]       int NOT NULL
ALTER TABLE [invoice]            ALTER COLUMN [patientID]   nvarchar(255) NOT NULL
ALTER TABLE [iotdevice]          ALTER COLUMN [macaddress]  nvarchar(255) NOT NULL
ALTER TABLE [logs]               ALTER COLUMN [deviceID]    int NOT NULL
ALTER TABLE [logs]               ALTER COLUMN [type]        nvarchar(255) NOT NULL
ALTER TABLE [logs]               ALTER COLUMN [value]       float NOT NULL


ALTER TABLE [iotdevice]
  ADD CONSTRAINT [UQ_iotdevice_macaddress] UNIQUE ([macaddress])

ALTER TABLE [icddisease]
  ADD CONSTRAINT [UQ_icddisease_code] UNIQUE ([code])

ALTER TABLE [employeeshift]
  ADD CONSTRAINT [UQ_employeeshift_pair] UNIQUE ([employeeID], [shiftID])


CREATE INDEX [IX_patient_insuranceID]            ON [patient] ([insuranceID])
CREATE INDEX [IX_appointment_patientID]          ON [appointment] ([patientID])
CREATE INDEX [IX_appointment_employeeID]         ON [appointment] ([employeeID])
CREATE INDEX [IX_appointment_departmentID]       ON [appointment] ([departmentID])
CREATE INDEX [IX_appointment_date_time]          ON [appointment] ([date], [time])
CREATE INDEX [IX_admission_patientID]            ON [admission] ([patientID])
CREATE INDEX [IX_admission_bedID]                ON [admission] ([bedID])
CREATE INDEX [IX_admission_employeeID]           ON [admission] ([employeeID])
CREATE INDEX [IX_bed_departmentID]               ON [bed] ([departmentID])
CREATE INDEX [IX_patienttransfer_admissionID]    ON [patienttransfer] ([admissionID])
CREATE INDEX [IX_Labimagingrequest_appointmentID] ON [Labimagingrequest] ([appointmentID])
CREATE INDEX [IX_Labimagingrequest_admissionID]  ON [Labimagingrequest] ([admissionID])
CREATE INDEX [IX_labresult_LabimagingrequestID]  ON [labresult] ([LabimagingrequestID])
CREATE INDEX [IX_labresult_isCritical]           ON [labresult] ([isCritical])
CREATE INDEX [IX_prescription_patientID]         ON [prescription] ([patientID])
CREATE INDEX [IX_prescriptionitem_prescriptionID] ON [prescriptionitem] ([prescriptionID])
CREATE INDEX [IX_prescriptionitem_drugID]        ON [prescriptionitem] ([drugID])
CREATE INDEX [IX_storage_transaction_drugID]     ON [storage_transaction] ([drugID])
CREATE INDEX [IX_storage_transaction_storageID]  ON [storage_transaction] ([storageID])
CREATE INDEX [IX_invoice_patientID]              ON [invoice] ([patientID])
CREATE INDEX [IX_invoiceitem_invoiceID]          ON [invoiceitem] ([invoiceID])
CREATE INDEX [IX_payment_invoiceID]              ON [payment] ([invoiceID])
CREATE INDEX [IX_devicetransfer_iotdeviceID]     ON [devicetransfer] ([iotdeviceID])
CREATE INDEX [IX_devicetransfer_patientID]       ON [devicetransfer] ([patientID])
CREATE INDEX [IX_logs_deviceID_timestamp]        ON [logs] ([deviceID], [timestamp])
CREATE INDEX [IX_alert_logID]                    ON [alert] ([logID])
CREATE INDEX [IX_AlertThreshold_measurementType]  ON [AlertThreshold] ([measurementType])

