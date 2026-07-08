-- PATIENT MANAGEMENT PROCEDURES
-- Procedure: Registers a new patient in the system
-- Creates both a patient record and an empty medical record
-- Uses transaction to ensure both inserts succeed or fail together
-- Parameters: All patient demographic information
CREATE PROCEDURE [sp_RegisterPatient]
  @nationalID  nvarchar(255),     -- Primary key, unique patient identifier
  @insuranceID int = NULL,        -- Optional insurance reference
  @name        nvarchar(255),     -- Patient full name (required)
  @datebirth   date = NULL,       -- Date of birth
  @gender      nvarchar(255) = NULL,  -- Male/Female
  @phone       nvarchar(255) = NULL,  -- Contact number
  @address     nvarchar(255) = NULL   -- Residential address
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON  -- Automatically rolls back on error

  BEGIN TRY
    BEGIN TRANSACTION

    -- Insert patient demographics
    INSERT INTO [patient] ([nationalID], [insuranceID], [name], [datebirth], [gender], [phone], [address])
    VALUES (@nationalID, @insuranceID, @name, @datebirth, @gender, @phone, @address)

    -- Create empty medical record for the patient
    INSERT INTO [medicalrecord] ([patientID])
    VALUES (@nationalID)

    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
    THROW  -- Re-raise the error
  END CATCH
END
GO

-- Procedure: Updates patient medical record information
-- Uses ISNULL to only update fields that were provided (non-NULL)
-- Allows partial updates without requiring all fields
-- Parameters: Patient ID and medical history fields
CREATE PROCEDURE [sp_UpdateMedicalRecord]
  @patientID          nvarchar(255),       -- Patient to update
  @preMedicalRecord   nvarchar(255) = NULL,  -- Previous medical history
  @predrugconsumption nvarchar(255) = NULL,  -- Previous medication usage
  @smokingHistory     nvarchar(255) = NULL,  -- Smoking status
  @weight             float = NULL,          -- Current weight in kg
  @height             float = NULL,          -- Current height in cm
  @bloodpressure      nvarchar(255) = NULL   -- Blood pressure reading
AS
BEGIN
  SET NOCOUNT ON

  -- Only update fields that were provided (non-NULL values)
  UPDATE [medicalrecord]
  SET [preMedicalRecord]   = ISNULL(@preMedicalRecord, [preMedicalRecord]),
      [predrugconsumption] = ISNULL(@predrugconsumption, [predrugconsumption]),
      [smokingHistory]     = ISNULL(@smokingHistory, [smokingHistory]),
      [weight]             = ISNULL(@weight, [weight]),
      [height]             = ISNULL(@height, [height]),
      [bloodpressure]      = ISNULL(@bloodpressure, [bloodpressure])
  WHERE [patientID] = @patientID
END
GO
-- DIAGNOSIS PROCEDURES
-- Procedure: Records a doctor's diagnosis for a patient
-- Links to either an appointment OR an admission (must have at least one)
-- Uses ICD disease codes for standardized diagnosis recording
-- Parameters: Appointment or Admission ID, ICD code, and description
CREATE PROCEDURE [sp_AddDoctorDiagnosis]
  @appointmentID int = NULL,      -- Optional: diagnosis from appointment
  @admissionID   int = NULL,      -- Optional: diagnosis from admission
  @icdID         int,             -- ICD disease code reference (required)
  @description   nvarchar(255) = NULL  -- Additional diagnosis notes
AS
BEGIN
  SET NOCOUNT ON

  -- Insert the diagnosis (CHECK constraint ensures at least one source ID is provided)
  INSERT INTO [doctordiagnosis] ([appointmentID], [admissionID], [icdID], [description])
  VALUES (@appointmentID, @admissionID, @icdID, @description)
END
GO
-- APPOINTMENT MANAGEMENT PROCEDURES
-- Procedure: Books a new appointment for a patient
-- Automatically sets status to 'Scheduled'
-- Returns the new appointment ID via OUTPUT parameter
-- Conflict prevention handled by trigger trg_appointment_prevent_conflict
-- Parameters: Doctor, patient, department, date, time, and appointment type
CREATE PROCEDURE [sp_BookAppointment]
  @employeeID       int,                  -- Doctor or staff ID
  @patientID        nvarchar(255),        -- Patient identifier
  @departmentID     int,                  -- Department where appointment occurs
  @date             date,                 -- Appointment date
  @time             time,                 -- Appointment time
  @appointment_type nvarchar(255) = N'InPerson',  -- InPerson or Online
  @newAppointmentID int OUTPUT            -- Returns the generated appointment ID
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  BEGIN TRY
    BEGIN TRANSACTION

    -- Insert the appointment
    INSERT INTO [appointment] ([employeeID], [patientID], [departmentID], [date], [time], [status], [appointment_type])
    VALUES (@employeeID, @patientID, @departmentID, @date, @time, N'Scheduled', @appointment_type)

    -- Retrieve the ID of the newly created appointment
    SELECT TOP 1 @newAppointmentID = [id]
    FROM [appointment]
    WHERE [employeeID] = @employeeID
      AND [patientID]  = @patientID
      AND [date]       = @date
      AND [time]       = @time
      AND [status]     = N'Scheduled'
    ORDER BY [id] DESC

    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
    THROW
  END CATCH
END
GO

-- Procedure: Cancels an existing appointment
-- Sets status to 'Cancelled' (soft delete)
-- Keeps the record for auditing and history
-- Parameters: Appointment ID to cancel
CREATE PROCEDURE [sp_CancelAppointment]
  @appointmentID int
AS
BEGIN
  SET NOCOUNT ON

  UPDATE [appointment]
  SET [status] = N'Cancelled'
  WHERE [id] = @appointmentID
END
GO

-- Procedure: Reschedules an existing appointment to a new date/time
-- Validates that the new slot is available for the doctor
-- Prevents conflicts with existing appointments (excluding the current one)
-- Parameters: Appointment ID, new date, and new time
CREATE PROCEDURE [sp_RescheduleAppointment]
  @appointmentID int,
  @newDate       date,
  @newTime       time
AS
BEGIN
  SET NOCOUNT ON

  -- Get the doctor assigned to this appointment
  DECLARE @employeeID int
  SELECT @employeeID = [employeeID] FROM [appointment] WHERE [id] = @appointmentID

  -- Check if the doctor is already booked at the new time (excluding this appointment)
  IF EXISTS (
    SELECT 1 FROM [appointment]
    WHERE [employeeID] = @employeeID AND [date] = @newDate AND [time] = @newTime
      AND [status] <> N'Cancelled' AND [id] <> @appointmentID
  )
  BEGIN
    RAISERROR(N'The doctor already has an appointment at this new date and time.', 16, 1)
    RETURN
  END

  -- Update the appointment with new date, time, and status
  UPDATE [appointment]
  SET [date] = @newDate, [time] = @newTime, [status] = N'Rescheduled'
  WHERE [id] = @appointmentID
END
GO
-- ADMISSION & TRANSFER PROCEDURES
-- Procedure: Admits a patient to the hospital
-- Assigns a bed and admitting doctor
-- Automatically sets entry date to current date
-- Returns the new admission ID and department statistics
-- Bed status is handled by trigger trg_admission_bed_occupy
-- Parameters: Patient ID, bed ID, doctor ID, optional appointment ID, and reason
CREATE PROCEDURE [sp_AdmitPatient]
  @patientID      nvarchar(255),        -- Patient being admitted
  @bedID          int,                  -- Bed to assign
  @employeeID     int,                  -- Admitting doctor/staff
  @appointmentID  int = NULL,           -- Optional related appointment
  @reason         nvarchar(255) = NULL, -- Reason for admission
  @newAdmissionID int OUTPUT            -- Returns the admission ID
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  BEGIN TRY
    BEGIN TRANSACTION

    -- Create the admission record
    INSERT INTO [admission] ([patientID], [bedID], [employeeID], [appointmentID], [entrydate], [reason])
    VALUES (@patientID, @bedID, @employeeID, @appointmentID, GETDATE(), @reason)

    SET @newAdmissionID = SCOPE_IDENTITY()

    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
    THROW
  END CATCH

  -- Return department bed statistics after admission
  SELECT
    [d].[id]                                  AS departmentID,
    [d].[name]                                AS departmentName,
    COUNT([b2].[id])                          AS totalBeds,
    SUM(CASE WHEN [b2].[status]=N'Occupied' THEN 1 ELSE 0 END) AS occupiedBeds,
    SUM(CASE WHEN [b2].[status]=N'Free'     THEN 1 ELSE 0 END) AS freeBedsRemaining
  FROM [bed] AS [b]
  INNER JOIN [department] AS [d] ON [d].[id] = [b].[departmentID]
  INNER JOIN [bed] AS [b2] ON [b2].[departmentID] = [d].[id]
  WHERE [b].[id] = @bedID
  GROUP BY [d].[id], [d].[name]
END
GO

-- Procedure: Transfers a patient from one bed to another
-- Uses fn_GetPatientCurrentBed to determine current bed
-- Creates a patienttransfer record with current date and time
-- Bed status updates handled by trigger trg_patienttransfer_bed_update
-- Parameters: Admission ID, destination bed ID, and optional reason
CREATE PROCEDURE [sp_TransferPatient]
  @admissionID int,                 -- The admission to transfer
  @toBedID     int,                 -- Destination bed
  @reason      nvarchar(255) = NULL -- Reason for transfer
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  -- Get the current bed for this admission
  DECLARE @fromBedID int = dbo.fn_GetPatientCurrentBed(@admissionID)

  BEGIN TRY
    BEGIN TRANSACTION

    -- Record the transfer with current date and time
    INSERT INTO [patienttransfer] ([date], [time], [reason], [admissionID], [fromBedID], [toBedID])
    VALUES (CAST(GETDATE() AS date), CAST(GETDATE() AS time), @reason, @admissionID, @fromBedID, @toBedID)

    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
    THROW
  END CATCH
END
GO