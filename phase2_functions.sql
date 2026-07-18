
-- ===================== LENGTH OF STAY & READMISSION =====================

CREATE FUNCTION [fn_CalculateLengthOfStay] (@admissionID int)
RETURNS int
AS
BEGIN
  DECLARE @los int
  SELECT @los = DATEDIFF(DAY, [entrydate], ISNULL([exitdate], GETDATE()))
  FROM [admission]
  WHERE [id] = @admissionID
  RETURN @los
END
GO

CREATE FUNCTION [fn_IsReadmission30Day] (@admissionID int)
RETURNS bit
AS
BEGIN
  DECLARE @result bit = 0
  DECLARE @patientID nvarchar(255), @entrydate date

  SELECT @patientID = [patientID], @entrydate = [entrydate]
  FROM [admission] WHERE [id] = @admissionID

  IF EXISTS (
    SELECT 1 FROM [admission]
    WHERE [patientID] = @patientID
      AND [id] <> @admissionID
      AND [exitdate] IS NOT NULL
      AND [exitdate] < @entrydate
      AND DATEDIFF(DAY, [exitdate], @entrydate) <= 30  
  )
    SET @result = 1

  RETURN @result
END
GO

-- ===================== APPOINTMENT WAIT-TIME =====================

CREATE FUNCTION [fn_CalculateWaitMinutes] (@appointmentID int)
RETURNS int
AS
BEGIN
  DECLARE @wait int
  SELECT @wait = DATEDIFF(MINUTE, [checkInTime], [serviceStartTime])
  FROM [appointment]
  WHERE [id] = @appointmentID
  RETURN @wait
END
GO

-- ===================== DRUG SAFETY (allergy check) =====================

CREATE FUNCTION [fn_CheckPatientAllergy] (@patientID nvarchar(255), @drugID int)
RETURNS nvarchar(255)
AS
BEGIN
  DECLARE @severity nvarchar(255)
  SELECT TOP 1 @severity = [severity]
  FROM [patientallergy]
  WHERE [patientID] = @patientID AND [drugID] = @drugID
  RETURN @severity
END
GO

-- ===================== OPERATING ROOM UTILIZATION =====================

CREATE FUNCTION [fn_GetORUtilizationPercent] (@operatingRoomID int, @fromDate date, @toDate date)
RETURNS float
AS
BEGIN
  DECLARE @bookedMinutes float, @totalMinutes float, @result float

  SELECT @bookedMinutes = ISNULL(SUM(DATEDIFF(MINUTE, [actualStart], [actualEnd])), 0)
  FROM [surgeryrecord]
  WHERE [operatingRoomID] = @operatingRoomID
    AND [actualStart] IS NOT NULL AND [actualEnd] IS NOT NULL
    AND CAST([actualStart] AS date) BETWEEN @fromDate AND @toDate

  SET @totalMinutes = DATEDIFF(DAY, @fromDate, @toDate) * 24 * 60

  SET @result = CASE WHEN @totalMinutes > 0 THEN ROUND(100.0 * @bookedMinutes / @totalMinutes, 2) ELSE NULL END
  RETURN @result
END
GO
