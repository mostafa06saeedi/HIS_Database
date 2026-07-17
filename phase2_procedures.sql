
-- PHASE 2 PROCEDURES

-- ===================== TREATMENT OUTCOME =====================

CREATE PROCEDURE [sp_RecordTreatmentOutcome]
  @doctordiagnosisID     int,
  @outcomeStatus         nvarchar(255),
  @complicationICD_ID    int = NULL,
  @complicationNote      nvarchar(255) = NULL,
  @evaluatedbyemployeeID int = NULL
AS
BEGIN
  SET NOCOUNT ON

  INSERT INTO [treatmentoutcome]
    ([doctordiagnosisID], [outcomeStatus], [complicationICD_ID], [complicationNote], [evaluatedDate], [evaluatedbyemployeeID])
  VALUES
    (@doctordiagnosisID, @outcomeStatus, @complicationICD_ID, @complicationNote, GETDATE(), @evaluatedbyemployeeID)
END
GO

-- ===================== FOLLOW-UP =====================

CREATE PROCEDURE [sp_AddFollowUp]
  @patientID          nvarchar(255),
  @employeeID         int,
  @followUpDate       date,
  @doctordiagnosisID  int = NULL,
  @appointmentID      int = NULL,
  @newSymptoms        nvarchar(255) = NULL,
  @progressStatus     nvarchar(255) = NULL,
  @treatmentChanged   bit = 0,
  @changeDescription  nvarchar(255) = NULL,
  @nextFollowUpDate   date = NULL
AS
BEGIN
  SET NOCOUNT ON

  IF @treatmentChanged = 1 AND @changeDescription IS NULL
  BEGIN
    RAISERROR(N'changeDescription is required when treatmentChanged = 1.', 16, 1)
    RETURN
  END

  INSERT INTO [followup]
    ([patientID], [doctordiagnosisID], [appointmentID], [employeeID], [followUpDate],
     [newSymptoms], [progressStatus], [treatmentChanged], [changeDescription], [nextFollowUpDate])
  VALUES
    (@patientID, @doctordiagnosisID, @appointmentID, @employeeID, @followUpDate,
     @newSymptoms, @progressStatus, @treatmentChanged, @changeDescription, @nextFollowUpDate)
END
GO

-- ===================== PATIENT ALLERGY =====================

CREATE PROCEDURE [sp_RecordPatientAllergy]
  @patientID     nvarchar(255),
  @severity      nvarchar(255),
  @drugID        int = NULL,
  @substanceName nvarchar(255) = NULL,
  @reaction      nvarchar(255) = NULL
AS
BEGIN
  SET NOCOUNT ON

  IF @drugID IS NULL AND @substanceName IS NULL
  BEGIN
    RAISERROR(N'Either drugID or substanceName must be provided.', 16, 1)
    RETURN
  END

  INSERT INTO [patientallergy] ([patientID], [drugID], [substanceName], [severity], [reaction], [recordedDate])
  VALUES (@patientID, @drugID, @substanceName, @severity, @reaction, GETDATE())
END
GO

-- ===================== SURGERY / OPERATING ROOM =====================

CREATE PROCEDURE [sp_ScheduleSurgery]
  @operatingRoomID int,
  @patientID       nvarchar(255),
  @scheduledStart  datetime,
  @admissionID     int = NULL,
  @surgeonID       int = NULL,
  @procedureName   nvarchar(255) = NULL,
  @newSurgeryID    int OUTPUT
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  BEGIN TRY
    BEGIN TRANSACTION

    INSERT INTO [surgeryrecord]
      ([operatingRoomID], [patientID], [admissionID], [surgeonID], [procedureName], [scheduledStart], [status])
    VALUES
      (@operatingRoomID, @patientID, @admissionID, @surgeonID, @procedureName, @scheduledStart, N'Scheduled')

    SET @newSurgeryID = SCOPE_IDENTITY()

    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
    THROW
  END CATCH
END
GO

CREATE PROCEDURE [sp_StartSurgery]
  @surgeryID int
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @operatingRoomID int, @orStatus nvarchar(255)
  SELECT @operatingRoomID = [operatingRoomID] FROM [surgeryrecord] WHERE [id] = @surgeryID
  SELECT @orStatus = [status] FROM [operatingroom] WHERE [id] = @operatingRoomID

  IF @orStatus <> N'Free'
  BEGIN
    RAISERROR(N'Operating room is not currently free.', 16, 1)
    RETURN
  END

  UPDATE [surgeryrecord]
  SET [actualStart] = GETDATE(), [status] = N'InProgress'
  WHERE [id] = @surgeryID
END
GO

CREATE PROCEDURE [sp_CompleteSurgery]
  @surgeryID int
AS
BEGIN
  SET NOCOUNT ON

  UPDATE [surgeryrecord]
  SET [actualEnd] = GETDATE(), [status] = N'Completed'
  WHERE [id] = @surgeryID
END
GO

-- ===================== APPOINTMENT TIMING (wait-time KPI) =====================

CREATE PROCEDURE [sp_CheckInAppointment]
  @appointmentID int
AS
BEGIN
  SET NOCOUNT ON
  UPDATE [appointment] SET [checkInTime] = GETDATE() WHERE [id] = @appointmentID
END
GO

CREATE PROCEDURE [sp_StartAppointmentService]
  @appointmentID int
AS
BEGIN
  SET NOCOUNT ON
  UPDATE [appointment] SET [serviceStartTime] = GETDATE() WHERE [id] = @appointmentID
END
GO

CREATE PROCEDURE [sp_CheckOutAppointment]
  @appointmentID int
AS
BEGIN
  SET NOCOUNT ON
  UPDATE [appointment]
  SET [checkOutTime] = GETDATE(), [status] = N'Completed'
  WHERE [id] = @appointmentID
END
GO

-- ===================== MANAGEMENT REPORTING =====================

CREATE PROCEDURE [sp_RefreshDailyDepartmentStats]
  @statDate date = NULL
AS
BEGIN
  SET NOCOUNT ON
  SET @statDate = ISNULL(@statDate, CAST(GETDATE() AS date))

  DELETE FROM [dailydepartmentstats] WHERE [statDate] = @statDate

  INSERT INTO [dailydepartmentstats]
    ([statDate], [departmentID], [totalBeds], [occupiedBeds], [occupancyPercent],
     [newAdmissions], [discharges], [appointmentsCount], [avgWaitMinutes])
  SELECT
    @statDate,
    [d].[id],
    COUNT(DISTINCT [b].[id]),
    SUM(CASE WHEN [b].[status] = N'Occupied' THEN 1 ELSE 0 END),
    CAST(ROUND(100.0 * SUM(CASE WHEN [b].[status] = N'Occupied' THEN 1 ELSE 0 END)
         / NULLIF(COUNT(DISTINCT [b].[id]), 0), 2) AS float),
    (SELECT COUNT(*) FROM [admission] AS [a]
       WHERE [a].[bedID] IN (SELECT [id] FROM [bed] WHERE [departmentID] = [d].[id])
         AND CAST([a].[entrydate] AS date) = @statDate),
    (SELECT COUNT(*) FROM [admission] AS [a]
       WHERE [a].[bedID] IN (SELECT [id] FROM [bed] WHERE [departmentID] = [d].[id])
         AND CAST([a].[exitdate] AS date) = @statDate),
    (SELECT COUNT(*) FROM [appointment] AS [ap]
       WHERE [ap].[departmentID] = [d].[id] AND [ap].[date] = @statDate),
    (SELECT AVG(CAST([dbo].[fn_CalculateWaitMinutes]([ap].[id]) AS float)) FROM [appointment] AS [ap]
       WHERE [ap].[departmentID] = [d].[id] AND [ap].[date] = @statDate)
  FROM [department] AS [d]
  LEFT JOIN [bed] AS [b] ON [b].[departmentID] = [d].[id]
  GROUP BY [d].[id]
END
GO
