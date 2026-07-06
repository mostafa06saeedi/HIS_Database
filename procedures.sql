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

CREATE PROCEDURE [sp_DischargePatient]
  @admissionID int,
  @exitdate    date = NULL
AS
BEGIN
  SET NOCOUNT ON

  UPDATE [admission]
  SET [exitdate] = ISNULL(@exitdate, GETDATE())
  WHERE [id] = @admissionID AND [exitdate] IS NULL
END
GO

CREATE PROCEDURE [sp_RequestLabImaging]
  @employeeID    int,
  @appointmentID int = NULL,
  @admissionID   int = NULL,
  @type          nvarchar(255),
  @newRequestID  int OUTPUT
AS
BEGIN
  SET NOCOUNT ON

  INSERT INTO [Labimagingrequest] ([employeeID], [appointmentID], [admissionID], [type], [date], [status])
  VALUES (@employeeID, @appointmentID, @admissionID, @type, GETDATE(), N'Requested')

  SET @newRequestID = SCOPE_IDENTITY()
END
GO

CREATE PROCEDURE [sp_RecordLabResult]
  @LabimagingrequestID  int,
  @reportedbyemployeeID int,
  @isCriticalID         int = NULL,
  @value                nvarchar(255),
  @description          nvarchar(255) = NULL,
  @newLabResultID       int OUTPUT
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  BEGIN TRY
    BEGIN TRANSACTION

    INSERT INTO [labresult] ([reportedbyemployeeID], [isCritical], [LabimagingrequestID], [value], [status], [date], [description])
    VALUES (@reportedbyemployeeID, @isCriticalID, @LabimagingrequestID, @value, N'Completed', GETDATE(), @description)

    SET @newLabResultID = SCOPE_IDENTITY()

    UPDATE [Labimagingrequest] SET [status] = N'Completed' WHERE [id] = @LabimagingrequestID

    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
    THROW
  END CATCH
END
GO

CREATE PROCEDURE [sp_AcknowledgeLabAlert]
  @labAlertID int
AS
BEGIN
  SET NOCOUNT ON
  UPDATE [labalert] SET [status] = N'ConfirmedByNurse' WHERE [id] = @labAlertID
END
GO

CREATE PROCEDURE [sp_ResolveLabAlert]
  @labAlertID int
AS
BEGIN
  SET NOCOUNT ON
  UPDATE [labalert] SET [status] = N'Resolved', [resolvedAt] = GETDATE() WHERE [id] = @labAlertID
END
GO

CREATE PROCEDURE [sp_IssuePrescription]
  @patientID          nvarchar(255),
  @employeeID         int,
  @appointmentID      int = NULL,
  @admissionID        int = NULL,
  @newPrescriptionID  int OUTPUT
AS
BEGIN
  SET NOCOUNT ON

  INSERT INTO [prescription] ([patientID], [employeeID], [appointmentID], [admissionID], [date], [status])
  VALUES (@patientID, @employeeID, @appointmentID, @admissionID, GETDATE(), N'Pending')

  SET @newPrescriptionID = SCOPE_IDENTITY()
END
GO

CREATE PROCEDURE [sp_AddPrescriptionItem]
  @prescriptionID int,
  @drugID         int,
  @dose           nvarchar(255),
  @duration       nvarchar(255),
  @quantity       int
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @conflictDrug nvarchar(255), @severity nvarchar(50)

  SELECT TOP 1 @conflictDrug = [d].[name], @severity = [dbo].[fn_CheckDrugInteraction](@drugID, [pi].[drugID])
  FROM [prescriptionitem] AS [pi]
  INNER JOIN [drug] AS [d] ON [d].[id] = [pi].[drugID]
  WHERE [pi].[prescriptionID] = @prescriptionID
    AND [dbo].[fn_CheckDrugInteraction](@drugID, [pi].[drugID]) IS NOT NULL

  IF @severity = N'Severe'
  BEGIN
    RAISERROR(N'Severe drug interaction detected with %s; prescription item rejected.', 16, 1, @conflictDrug)
    RETURN
  END
  ELSE IF @severity IS NOT NULL
  BEGIN
    RAISERROR(N'Warning: drug interaction (%s) detected with %s.', 5, 1, @severity, @conflictDrug) WITH NOWAIT
  END

  INSERT INTO [prescriptionitem] ([prescriptionID], [drugID], [dose], [duration], [quantity])
  VALUES (@prescriptionID, @drugID, @dose, @duration, @quantity)
END
GO

CREATE PROCEDURE [sp_DispenseMedication]
  @prescriptionID int,
  @storageID      int
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  BEGIN TRY
    BEGIN TRANSACTION

    INSERT INTO [storage_transaction] ([drugID], [storageID], [date], [type], [quantity], [reason])
    SELECT [drugID], @storageID, GETDATE(), N'OUT', [quantity], N'Dispense prescription #' + CAST(@prescriptionID AS nvarchar(20))
    FROM [prescriptionitem]
    WHERE [prescriptionID] = @prescriptionID

    UPDATE [prescription] SET [status] = N'Dispensed' WHERE [id] = @prescriptionID

    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
    THROW
  END CATCH
END
GO

CREATE PROCEDURE [sp_ReceiveStock]
  @drugID    int,
  @storageID int,
  @quantity  int,
  @reason    nvarchar(255) = N'Restock'
AS
BEGIN
  SET NOCOUNT ON

  INSERT INTO [storage_transaction] ([drugID], [storageID], [date], [type], [quantity], [reason])
  VALUES (@drugID, @storageID, GETDATE(), N'IN', @quantity, @reason)
END
GO

CREATE PROCEDURE [sp_AddDrugInteraction]
  @drugID1      int,
  @drugID2      int,
  @severity     nvarchar(50),
  @description  nvarchar(255) = NULL
AS
BEGIN
  SET NOCOUNT ON

  IF @drugID1 = @drugID2
  BEGIN
    RAISERROR(N'A drug cannot interact with itself.', 16, 1)
    RETURN
  END

  IF EXISTS (
    SELECT 1 FROM [druginteraction]
    WHERE ([drugID1] = @drugID1 AND [drugID2] = @drugID2)
       OR ([drugID1] = @drugID2 AND [drugID2] = @drugID1)
  )
  BEGIN
    RAISERROR(N'This drug interaction has already been recorded.', 16, 1)
    RETURN
  END

  INSERT INTO [druginteraction] ([drugID1], [drugID2], [severity], [description])
  VALUES (@drugID1, @drugID2, @severity, @description)
END
GO
  
CREATE PROCEDURE [sp_AddInventoryItem]
  @name      nvarchar(255),
  @type      nvarchar(255),
  @inventory int = 0
AS
BEGIN
  SET NOCOUNT ON
  INSERT INTO [storage] ([name], [inventory], [type])
  VALUES (@name, @inventory, @type)
END
GO

CREATE PROCEDURE [sp_CreateInvoice]
  @patientID       nvarchar(255),
  @admissionID     int = NULL,
  @appointmentID   int = NULL,
  @insuranceId     int = NULL,
  @paymentmethodID int = NULL,
  @newInvoiceID    int OUTPUT
AS
BEGIN
  SET NOCOUNT ON

  INSERT INTO [invoice] ([patientID], [admissionID], [appointmentID], [insuranceId], [paymentmethodID], [total_amount], [status], [date])
  VALUES (@patientID, @admissionID, @appointmentID, @insuranceId, @paymentmethodID, 0, N'Unpaid', GETDATE())

  SET @newInvoiceID = SCOPE_IDENTITY()
END
GO

CREATE PROCEDURE [sp_AddInvoiceItem]
  @invoiceID   int,
  @item        nvarchar(255),
  @type        nvarchar(255),
  @description nvarchar(255) = NULL,
  @amount      float
AS
BEGIN
  SET NOCOUNT ON

  INSERT INTO [invoiceitem] ([invoiceID], [item], [type], [description], [amount])
  VALUES (@invoiceID, @item, @type, @description, @amount)
END
GO

CREATE PROCEDURE [sp_RecordPayment]
  @invoiceID       int,
  @patientID       nvarchar(255),
  @amount          float,
  @paymentmethodID int = NULL,
  @type            nvarchar(50) = N'Payment'
AS
BEGIN
  SET NOCOUNT ON

  INSERT INTO [payment] ([invoiceID], [patientID], [paymentmethodID], [amount], [type], [date])
  VALUES (@invoiceID, @patientID, @paymentmethodID, @amount, @type, GETDATE())
END
GO

CREATE PROCEDURE [sp_RegisterIoTDevice]
  @macaddress     nvarchar(255),
  @type           nvarchar(255),
  @newDeviceID    int OUTPUT
AS
BEGIN
  SET NOCOUNT ON

  INSERT INTO [iotdevice] ([macaddress], [type], [status], [installationdate])
  VALUES (@macaddress, @type, N'Active', GETDATE())

  SET @newDeviceID = SCOPE_IDENTITY()
END
GO

CREATE PROCEDURE [sp_AssignDeviceToPatient]
  @iotdeviceID   int,
  @patientID     nvarchar(255),
  @admissionID   int = NULL,
  @departmentID  int,
  @bedID         int
AS
BEGIN
  SET NOCOUNT ON

  INSERT INTO [devicetransfer] ([patientID], [admissionID], [departmentID], [bedID], [iotdeviceID], [assignedAt])
  VALUES (@patientID, @admissionID, @departmentID, @bedID, @iotdeviceID, GETDATE())
END
GO

CREATE PROCEDURE [sp_UnassignDevice]
  @iotdeviceID int
AS
BEGIN
  SET NOCOUNT ON

  UPDATE [devicetransfer]
  SET [unassignedAt] = GETDATE()
  WHERE [iotdeviceID] = @iotdeviceID AND [unassignedAt] IS NULL
END
GO

CREATE PROCEDURE [sp_RecordDeviceLog]
  @deviceID  int,
  @type      nvarchar(255),
  @value     float,
  @unit      nvarchar(255) = NULL,
  @timestamp datetime = NULL
AS
BEGIN
  SET NOCOUNT ON

  INSERT INTO [logs] ([deviceID], [timestamp], [type], [value], [unit])
  VALUES (@deviceID, ISNULL(@timestamp, GETDATE()), @type, @value, @unit)
END
GO

CREATE PROCEDURE [sp_SetAlertThreshold]
  @measurementType nvarchar(255),
  @minValue        float = NULL,
  @maxValue        float = NULL,
  @severity        nvarchar(255) = N'Critical',
  @isGlobal        bit = 1,
  @employeeID      int = NULL,
  @patientID       nvarchar(255) = NULL
AS
BEGIN
  SET NOCOUNT ON

  INSERT INTO [AlertThreshold] ([measurementType], [minValue], [maxValue], [severity], [isGlobal], [employeeID], [patientID], [createdate])
  VALUES (@measurementType, @minValue, @maxValue, @severity, @isGlobal, @employeeID, @patientID, GETDATE())
END
GO

CREATE PROCEDURE [sp_AcknowledgeAlert]
  @alertID    int,
  @employeeID int
AS
BEGIN
  SET NOCOUNT ON

  UPDATE [alert]
  SET [status] = N'ConfirmedByNurse', [acknowledgedbyemployeeID] = @employeeID
  WHERE [id] = @alertID
END
GO

CREATE PROCEDURE [sp_ResolveAlert]
  @alertID int
AS
BEGIN
  SET NOCOUNT ON

  UPDATE [alert]
  SET [status] = N'Resolved', [resolvedtime] = GETDATE()
  WHERE [id] = @alertID
END
GO

CREATE PROCEDURE [sp_AssignShift]
  @employeeID int,
  @shiftID    int
AS
BEGIN
  SET NOCOUNT ON

  IF NOT EXISTS (SELECT 1 FROM [employeeshift] WHERE [employeeID] = @employeeID AND [shiftID] = @shiftID)
    INSERT INTO [employeeshift] ([employeeID], [shiftID]) VALUES (@employeeID, @shiftID)
END
GO
