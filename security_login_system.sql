-- PATIENT ACCOUNT REGISTRATION
-- Procedure: Creates a login account for an existing patient
-- Validates that the patient exists in the system first
-- Prevents duplicate usernames
-- Uses SHA2_256 hashing with salt for password security
-- Parameters: Patient national ID, username, and password
CREATE PROCEDURE [sp_RegisterPatientLogin]
  @nationalID nvarchar(255),
  @username   nvarchar(100),
  @password   nvarchar(100)
AS
BEGIN
  SET NOCOUNT ON

  -- Verify patient exists in the system
  IF NOT EXISTS (SELECT 1 FROM [patient] WHERE [nationalID] = @nationalID)
  BEGIN
    RAISERROR(N'Patient with this national ID not found; register with sp_RegisterPatient first.', 16, 1)
    RETURN
  END

  -- Check for duplicate username
  IF EXISTS (SELECT 1 FROM [UserAccount] WHERE [username] = @username)
  BEGIN
    RAISERROR(N'This username is already taken.', 16, 1)
    RETURN
  END

  -- Generate a unique salt for this user
  DECLARE @salt uniqueidentifier = NEWID()

  -- Store password hash with salt (SHA2_256 encryption)
  -- Format: SHA2_256(salt + password) for enhanced security
  INSERT INTO [UserAccount] ([username], [passwordHash], [passwordSalt], [role], [patientID])
  VALUES (@username, HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt) + @password), @salt, N'Patient', @nationalID)
END
GO
-- EMPLOYEE ACCOUNT REGISTRATION
-- Procedure: Creates a login account for an existing employee
-- Validates employee exists and role matches their designation
-- For doctors: verifies they're in doctor table
-- For nurses: verifies they're in nurse table
-- For admin roles: verifies adminstaff role matches
-- Parameters: Employee ID, username, password, and role
CREATE PROCEDURE [sp_RegisterEmployeeLogin]
  @employeeID int,
  @username   nvarchar(100),
  @password   nvarchar(100),
  @role       nvarchar(50)
AS
BEGIN
  SET NOCOUNT ON

  -- Verify employee exists in the system
  IF NOT EXISTS (SELECT 1 FROM [employee] WHERE [id] = @employeeID)
  BEGIN
    RAISERROR(N'Employee with this ID not found.', 16, 1)
    RETURN
  END

  -- Validate Doctor role
  IF @role = N'Doctor' AND NOT EXISTS (SELECT 1 FROM [doctor] WHERE [employeeID] = @employeeID)
  BEGIN
    RAISERROR(N'This employee is not registered as a doctor; Doctor role is invalid.', 16, 1)
    RETURN
  END

  -- Validate Nurse role
  IF @role = N'Nurse' AND NOT EXISTS (SELECT 1 FROM [nurse] WHERE [employeeID] = @employeeID)
  BEGIN
    RAISERROR(N'This employee is not registered as a nurse; Nurse role is invalid.', 16, 1)
    RETURN
  END

  -- Validate Admin staff roles (Pharmacist, LabTech, Reception, Manager)
  IF @role IN (N'Pharmacist', N'LabTech', N'Reception', N'Manager')
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM [adminstaff]
      WHERE [employeeID] = @employeeID
        AND LOWER([role]) = LOWER(CASE @role WHEN N'LabTech' THEN N'lab_tech' ELSE @role END)
    )
    BEGIN
      RAISERROR(N'Selected role does not match the employee role registered in adminstaff.', 16, 1)
      RETURN
    END
  END

  -- Check for duplicate username
  IF EXISTS (SELECT 1 FROM [UserAccount] WHERE [username] = @username)
  BEGIN
    RAISERROR(N'This username is already taken.', 16, 1)
    RETURN
  END

  -- Generate a unique salt for this user
  DECLARE @salt uniqueidentifier = NEWID()

  -- Store password hash with salt
  INSERT INTO [UserAccount] ([username], [passwordHash], [passwordSalt], [role], [employeeID])
  VALUES (@username, HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt) + @password), @salt, @role, @employeeID)
END
GO
-- AUTHENTICATION PROCEDURES
-- Procedure: Authenticates a user and establishes session context
-- Validates username exists and account is active
-- Compares hashed password with stored hash
-- Sets session context variables for Row-Level Security (RLS)
-- Updates last login timestamp
-- Returns success status and message
-- Parameters: Username, password, output success flag and message
CREATE PROCEDURE [sp_Login]
  @username nvarchar(100),
  @password nvarchar(100),
  @success  bit OUTPUT,
  @message  nvarchar(255) OUTPUT
AS
BEGIN
  SET NOCOUNT ON

  -- Retrieve user account details
  DECLARE @id int, @hash varbinary(64), @salt uniqueidentifier,
          @role nvarchar(50), @patientID nvarchar(255), @employeeID int, @isActive bit

  SELECT @id = [id], @hash = [passwordHash], @salt = [passwordSalt], @role = [role],
         @patientID = [patientID], @employeeID = [employeeID], @isActive = [isActive]
  FROM [UserAccount]
  WHERE [username] = @username

  -- Check if username exists
  IF @id IS NULL
  BEGIN
    SET @success = 0
    SET @message = N'Username not found.'
    RETURN
  END

  -- Check if account is active
  IF @isActive = 0
  BEGIN
    SET @success = 0
    SET @message = N'This account has been deactivated.'
    RETURN
  END

  -- Verify password (hash match)
  IF HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt) + @password) <> @hash
  BEGIN
    SET @success = 0
    SET @message = N'Incorrect password.'
    RETURN
  END

  -- Set session context for Row-Level Security (RLS)
  -- These values are used by views and functions to filter data
  EXEC [sys].[sp_set_session_context] @key = N'UserID',     @value = @id
  EXEC [sys].[sp_set_session_context] @key = N'Role',       @value = @role
  EXEC [sys].[sp_set_session_context] @key = N'PatientID',  @value = @patientID
  EXEC [sys].[sp_set_session_context] @key = N'EmployeeID', @value = @employeeID

  -- Update last login timestamp
  UPDATE [UserAccount] SET [lastLoginAt] = GETDATE() WHERE [id] = @id

  -- Login successful
  SET @success = 1
  SET @message = N'Login successful - Role: ' + @role
END
GO

-- Procedure: Logs out the current user
-- Clears all session context variables
-- Should be called when user logs out or session ends
CREATE PROCEDURE [sp_Logout]
AS
BEGIN
  SET NOCOUNT ON

  -- Clear all session context variables
  EXEC [sys].[sp_set_session_context] @key = N'UserID',     @value = NULL
  EXEC [sys].[sp_set_session_context] @key = N'Role',       @value = NULL
  EXEC [sys].[sp_set_session_context] @key = N'PatientID',  @value = NULL
  EXEC [sys].[sp_set_session_context] @key = N'EmployeeID', @value = NULL
END
GO

-- Procedure: Changes user password
-- Requires current password for verification
-- Generates new salt for enhanced security
-- Parameters: Username, old password, new password
CREATE PROCEDURE [sp_ChangePassword]
  @username     nvarchar(100),
  @oldPassword  nvarchar(100),
  @newPassword  nvarchar(100)
AS
BEGIN
  SET NOCOUNT ON

  -- Get current hash and salt for verification
  DECLARE @hash varbinary(64), @salt uniqueidentifier
  SELECT @hash = [passwordHash], @salt = [passwordSalt] FROM [UserAccount] WHERE [username] = @username

  -- Verify old password
  IF @hash IS NULL OR HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt) + @oldPassword) <> @hash
  BEGIN
    RAISERROR(N'Incorrect username or current password.', 16, 1)
    RETURN
  END

  -- Generate new salt and update password
  DECLARE @newSalt uniqueidentifier = NEWID()
  UPDATE [UserAccount]
  SET [passwordHash] = HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @newSalt) + @newPassword),
      [passwordSalt] = @newSalt
  WHERE [username] = @username
END
GO
-- ROLE DEFINITIONS
-- Create database roles for each user type
-- Roles control access to views, procedures, and data
CREATE ROLE [role_Patient]      -- Patient portal access
CREATE ROLE [role_Doctor]       -- Doctor dashboard access
CREATE ROLE [role_Nurse]        -- Nurse dashboard access
CREATE ROLE [role_Pharmacist]   -- Pharmacy system access
CREATE ROLE [role_LabTech]      -- Laboratory system access
CREATE ROLE [role_Reception]    -- Reception desk access
CREATE ROLE [role_Manager]      -- Management reporting access
GO
-- PUBLIC PERMISSIONS (Available to all users)
-- Authentication procedures are available to everyone (pre-login)
GRANT EXECUTE ON [sp_Login]          TO PUBLIC
GRANT EXECUTE ON [sp_Logout]         TO PUBLIC
GRANT EXECUTE ON [sp_ChangePassword] TO PUBLIC
GO
-- PATIENT ROLE PERMISSION
-- Patient views (read-only access to their own data)
GRANT SELECT  ON [vw_MyProfile]        TO [role_Patient]
GRANT SELECT  ON [vw_MyMedicalRecord]  TO [role_Patient]
GRANT SELECT  ON [vw_MyAppointments]   TO [role_Patient]
GRANT SELECT  ON [vw_MyAdmissions]     TO [role_Patient]
GRANT SELECT  ON [vw_MyLabResults]     TO [role_Patient]
GRANT SELECT  ON [vw_MyPrescriptions]  TO [role_Patient]
GRANT SELECT  ON [vw_MyInvoices]       TO [role_Patient]

-- Patient can book and cancel their own appointments
GRANT EXECUTE ON [sp_BookAppointment]  TO [role_Patient]
GRANT EXECUTE ON [sp_CancelAppointment] TO [role_Patient]
GO
-- DOCTOR ROLE PERMISSIONS
-- Doctor views (their patients and their data)
GRANT SELECT  ON [vw_DoctorMyAppointments]      TO [role_Doctor]
GRANT SELECT  ON [vw_DoctorMyAdmittedPatients]  TO [role_Doctor]
GRANT SELECT  ON [vw_DoctorPendingLabResults]   TO [role_Doctor]
GRANT SELECT  ON [vw_DoctorPatientHistory]      TO [role_Doctor]

-- Doctor medical procedures
GRANT EXECUTE ON [sp_AddDoctorDiagnosis]        TO [role_Doctor]
GRANT EXECUTE ON [sp_RequestLabImaging]         TO [role_Doctor]
GRANT EXECUTE ON [sp_IssuePrescription]         TO [role_Doctor]
GRANT EXECUTE ON [sp_AddPrescriptionItem]       TO [role_Doctor]

-- Doctor lab alert management
GRANT EXECUTE ON [sp_AcknowledgeLabAlert]       TO [role_Doctor]
GRANT EXECUTE ON [sp_ResolveLabAlert]           TO [role_Doctor]

-- Doctor patient management
GRANT EXECUTE ON [sp_AdmitPatient]              TO [role_Doctor]
GRANT EXECUTE ON [sp_TransferPatient]           TO [role_Doctor]
GRANT EXECUTE ON [sp_DischargePatient]          TO [role_Doctor]
GO
-- NURSE ROLE PERMISSIONS
-- Nurse views (ward patients and alerts)
GRANT SELECT  ON [vw_NurseActiveAlerts] TO [role_Nurse]
GRANT SELECT  ON [vw_NurseWardPatients] TO [role_Nurse]

-- Nurse alert management
GRANT EXECUTE ON [sp_AcknowledgeAlert]  TO [role_Nurse]
GRANT EXECUTE ON [sp_ResolveAlert]      TO [role_Nurse]

-- Nurse can record IoT device readings
GRANT EXECUTE ON [sp_RecordDeviceLog]   TO [role_Nurse]
GO
-- PHARMACIST ROLE PERMISSIONS
-- Pharmacist views (pending prescriptions)
GRANT SELECT  ON [vw_PharmacyPendingPrescriptions] TO [role_Pharmacist]

-- Pharmacist inventory management
GRANT EXECUTE ON [sp_DispenseMedication]           TO [role_Pharmacist]
GRANT EXECUTE ON [sp_ReceiveStock]                 TO [role_Pharmacist]
GRANT EXECUTE ON [sp_AddDrugInteraction]           TO [role_Pharmacist]
GO
-- LAB TECHNICIAN ROLE PERMISSIONS
-- Lab technician views (pending requests)
GRANT SELECT  ON [vw_LabPendingRequests] TO [role_LabTech]

-- Lab technician can record lab results
GRANT EXECUTE ON [sp_RecordLabResult]    TO [role_LabTech]
GO
-- RECEPTION ROLE PERMISSIONS
-- Reception views (daily operations)
GRANT SELECT  ON [vw_ReceptionTodayAppointments] TO [role_Reception]
GRANT SELECT  ON [vw_DepartmentBedCapacity]      TO [role_Reception]
GRANT SELECT  ON [vw_CurrentAdmissions]          TO [role_Reception]

-- Reception patient registration
GRANT EXECUTE ON [sp_RegisterPatient]            TO [role_Reception]
GRANT EXECUTE ON [sp_RegisterPatientLogin]       TO [role_Reception]

-- Reception appointment management
GRANT EXECUTE ON [sp_BookAppointment]            TO [role_Reception]
GRANT EXECUTE ON [sp_RescheduleAppointment]      TO [role_Reception]

-- Reception admission management
GRANT EXECUTE ON [sp_AdmitPatient]               TO [role_Reception]
GRANT EXECUTE ON [sp_DischargePatient]           TO [role_Reception]
GRANT EXECUTE ON [sp_TransferPatient]            TO [role_Reception]

-- Reception financial operations
GRANT EXECUTE ON [sp_CreateInvoice]              TO [role_Reception]
GRANT EXECUTE ON [sp_AddInvoiceItem]             TO [role_Reception]
GRANT EXECUTE ON [sp_RecordPayment]              TO [role_Reception]
GO
-- MANAGER ROLE PERMISSIONS
-- Manager views (hospital-wide reports)
GRANT SELECT ON [vw_ManagerDepartmentReport] TO [role_Manager]
GRANT SELECT ON [vw_DepartmentBedCapacity]   TO [role_Manager]
GRANT SELECT ON [vw_CurrentAdmissions]       TO [role_Manager]
GO
-- ROW-LEVEL SECURITY (RLS) - Data Protection
-- DENY direct table access to patients (must use views)
-- This enforces Row-Level Security by forcing patients to use views
-- that automatically filter data based on session context
DENY SELECT ON [patient]        TO [role_Patient]
DENY SELECT ON [medicalrecord]  TO [role_Patient]
DENY SELECT ON [labresult]      TO [role_Patient]
DENY SELECT ON [invoice]        TO [role_Patient]
DENY SELECT ON [admission]      TO [role_Patient]
DENY SELECT ON [prescription]   TO [role_Patient]
GO