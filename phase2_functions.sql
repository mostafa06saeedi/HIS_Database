-- ================================================================
-- PHASE 2 FUNCTIONS
-- Derived-value calculators and reusable checks, in the same spirit as functions.sql:
-- computed on demand rather than stored, and reused by triggers/procedures/views.
-- Run AFTER phase2_schemas.sql.
-- ================================================================

-- ===================== LENGTH OF STAY & READMISSION =====================
-- Calculates length of stay in days for an admission (derived attribute, not stored)
-- Uses exitdate if discharged, otherwise GETDATE() for an ongoing stay
-- Parameters: @admissionID
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

-- Flags whether an admission is a 30-day readmission: same patient had a previous
-- admission that was discharged within 30 days before this admission's entry date
-- Returns: bit (1 = readmission within 30 days, 0 = not)
-- Parameters: @admissionID
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
      AND DATEDIFF(DAY, [exitdate], @entrydate) <= 30  -- Discharged within the prior 30 days
  )
    SET @result = 1

  RETURN @result
END
GO

-- ===================== APPOINTMENT WAIT-TIME =====================
-- Calculates patient waiting time in minutes: from check-in to when the doctor
-- actually started seeing them. Returns NULL if either timestamp wasn't recorded.
-- Parameters: @appointmentID
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
-- Checks whether a patient has a recorded allergy to a specific catalogued drug
-- Mirrors fn_CheckDrugInteraction's shape so both can be used the same way by
-- trg_prescriptionitem_safety_check
-- Returns: severity (Mild/Moderate/Severe) if an allergy exists, NULL otherwise
-- Parameters: @patientID, @drugID
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
-- Calculates operating room utilization percentage over a date range:
-- (total booked minutes) / (total available minutes in the range) * 100
-- Assumes 24/7 availability as the denominator (a simplifying assumption worth
-- revisiting if the team later models OR opening hours)
-- Parameters: @operatingRoomID, @fromDate, @toDate
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
