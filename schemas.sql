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