CREATE PROCEDURE [sp_RegisterPatient]
  @nationalID  nvarchar(255),
  @insuranceID int = NULL,
  @name        nvarchar(255),
  @datebirth   date = NULL,
  @gender      nvarchar(255) = NULL,
  @phone       nvarchar(255) = NULL,
  @address     nvarchar(255) = NULL
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  BEGIN TRY
    BEGIN TRANSACTION

    INSERT INTO [patient] ([nationalID], [insuranceID], [name], [datebirth], [gender], [phone], [address])
    VALUES (@nationalID, @insuranceID, @name, @datebirth, @gender, @phone, @address)

    INSERT INTO [medicalrecord] ([patientID])
    VALUES (@nationalID)

    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
    THROW
  END CATCH
END
GO

CREATE PROCEDURE [sp_UpdateMedicalRecord]
  @patientID          nvarchar(255),
  @preMedicalRecord   nvarchar(255) = NULL,
  @predrugconsumption nvarchar(255) = NULL,
  @smokingHistory     nvarchar(255) = NULL,
  @weight             float = NULL,
  @height             float = NULL,
  @bloodpressure      nvarchar(255) = NULL
AS
BEGIN
  SET NOCOUNT ON

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

CREATE PROCEDURE [sp_AddDoctorDiagnosis]
  @appointmentID int = NULL,
  @admissionID   int = NULL,
  @icdID         int,
  @description   nvarchar(255) = NULL
AS
BEGIN
  SET NOCOUNT ON

  INSERT INTO [doctordiagnosis] ([appointmentID], [admissionID], [icdID], [description])
  VALUES (@appointmentID, @admissionID, @icdID, @description)
END
GO

CREATE PROCEDURE [sp_BookAppointment]
  @employeeID       int,
  @patientID        nvarchar(255),
  @departmentID     int,
  @date             date,
  @time             time,
  @appointment_type nvarchar(255) = N'InPerson',
  @newAppointmentID int OUTPUT
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  BEGIN TRY
    BEGIN TRANSACTION

    INSERT INTO [appointment] ([employeeID], [patientID], [departmentID], [date], [time], [status], [appointment_type])
    VALUES (@employeeID, @patientID, @departmentID, @date, @time, N'Scheduled', @appointment_type)

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

CREATE PROCEDURE [sp_RescheduleAppointment]
  @appointmentID int,
  @newDate       date,
  @newTime       time
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @employeeID int
  SELECT @employeeID = [employeeID] FROM [appointment] WHERE [id] = @appointmentID

  IF EXISTS (
    SELECT 1 FROM [appointment]
    WHERE [employeeID] = @employeeID AND [date] = @newDate AND [time] = @newTime
      AND [status] <> N'Cancelled' AND [id] <> @appointmentID
  )
  BEGIN
    RAISERROR(N'The doctor already has an appointment at this new date and time.', 16, 1)
    RETURN
  END

  UPDATE [appointment]
  SET [date] = @newDate, [time] = @newTime, [status] = N'Rescheduled'
  WHERE [id] = @appointmentID
END
GO

CREATE PROCEDURE [sp_AdmitPatient]
  @patientID      nvarchar(255),
  @bedID          int,
  @employeeID     int,
  @appointmentID  int = NULL,
  @reason         nvarchar(255) = NULL,
  @newAdmissionID int OUTPUT
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  BEGIN TRY
    BEGIN TRANSACTION

    INSERT INTO [admission] ([patientID], [bedID], [employeeID], [appointmentID], [entrydate], [reason])
    VALUES (@patientID, @bedID, @employeeID, @appointmentID, GETDATE(), @reason)

    SET @newAdmissionID = SCOPE_IDENTITY()

    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
    THROW
  END CATCH

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

CREATE PROCEDURE [sp_TransferPatient]
  @admissionID int,
  @toBedID     int,
  @reason      nvarchar(255) = NULL
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  DECLARE @fromBedID int = dbo.fn_GetPatientCurrentBed(@admissionID)

  BEGIN TRY
    BEGIN TRANSACTION

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
