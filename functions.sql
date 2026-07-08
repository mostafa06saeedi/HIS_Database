-- PATIENT INFORMATION FUNCTIONS
-- Calculates the age of a patient based on their date of birth
-- Uses DATEADD with CASE to handle birthdays correctly (accounts for whether birthday has occurred this year)
-- Returns: integer age in years
-- Parameters: @nationalID - patient's unique identifier
CREATE FUNCTION [fn_CalculateAge] (@nationalID nvarchar(255))
RETURNS int
AS
BEGIN
  DECLARE @age int
  SELECT @age = DATEDIFF(YEAR, [datebirth], GETDATE())
               - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, [datebirth], GETDATE()), [datebirth]) > GETDATE()
                      THEN 1 ELSE 0 END  -- Subtract 1 if birthday hasn't occurred yet this year
  FROM [patient]
  WHERE [nationalID] = @nationalID

  RETURN @age
END
GO
-- BED MANAGEMENT FUNCTIONS
-- Checks if a specific bed is available (status = 'Free')
-- Returns: bit (1 if available, 0 if not)
-- Parameters: @bedID - bed identifier
CREATE FUNCTION [fn_IsBedAvailable] (@bedID int)
RETURNS bit
AS
BEGIN
  DECLARE @result bit = 0
  IF EXISTS (SELECT 1 FROM [bed] WHERE [id] = @bedID AND [status] = N'Free')
    SET @result = 1
  RETURN @result
END
GO

-- Returns a list of all available (free) beds
-- Optionally filters by department
-- Returns table with bed details including department name
-- Parameters: @departmentID - optional department filter (NULL = all departments)
CREATE FUNCTION [fn_GetAvailableBeds] (@departmentID int = NULL)
RETURNS TABLE
AS
RETURN
(
  SELECT [b].[id] AS bedID, [b].[room], [b].[departmentID], [d].[name] AS departmentName
  FROM [bed] AS [b]
  INNER JOIN [department] AS [d] ON [d].[id] = [b].[departmentID]
  WHERE [b].[status] = N'Free'
    AND (@departmentID IS NULL OR [b].[departmentID] = @departmentID)
)
GO

-- ADMISSION & PATIENT TRACKING FUNCTIONS
-- Gets the most recent active admission (no exit date) for a patient
-- Useful for determining if patient is currently hospitalized
-- Returns: admissionID or NULL if no active admission
-- Parameters: @patientID - patient's unique identifier
CREATE FUNCTION [fn_GetPatientActiveAdmission] (@patientID nvarchar(255))
RETURNS int
AS
BEGIN
  DECLARE @admissionID int
  SELECT TOP 1 @admissionID = [id]
  FROM [admission]
  WHERE [patientID] = @patientID AND [exitdate] IS NULL
  ORDER BY [entrydate] DESC  -- Gets the most recent active admission

  RETURN @admissionID
END
GO

-- Determines the current bed for a given admission
-- First checks patienttransfer table for the most recent transfer
-- Falls back to admission's initial bed if no transfers exist
-- Returns: bedID or NULL if no bed assigned
-- Parameters: @admissionID - admission identifier
CREATE FUNCTION [fn_GetPatientCurrentBed] (@admissionID int)
RETURNS int
AS
BEGIN
  DECLARE @bedID int

  -- First check if patient has been transferred
  SELECT TOP 1 @bedID = [toBedID]
  FROM [patienttransfer]
  WHERE [admissionID] = @admissionID
  ORDER BY [date] DESC, [time] DESC

  -- If no transfers, use the bed from the admission record
  IF @bedID IS NULL
    SELECT @bedID = [bedID] FROM [admission] WHERE [id] = @admissionID

  RETURN @bedID
END
GO
-- INVOICE & FINANCIAL FUNCTIONS
-- Calculates the total amount for an invoice by summing all invoice items
-- Returns: total amount as float (0 if no items)
-- Parameters: @invoiceID - invoice identifier
CREATE FUNCTION [fn_CalculateInvoiceTotal] (@invoiceID int)
RETURNS float
AS
BEGIN
  DECLARE @total float
  SELECT @total = ISNULL(SUM([amount]), 0)
  FROM [invoiceitem]
  WHERE [invoiceID] = @invoiceID

  RETURN @total
END
GO

-- Calculates insurance and patient portions of an invoice
-- Uses coverage percentage from patient's active insurance
-- Returns table with invoice details and calculated amounts
-- Parameters: @invoiceID - invoice identifier
CREATE FUNCTION [fn_CalculateInsuranceShare] (@invoiceID int)
RETURNS TABLE
AS
RETURN
(
  SELECT
    [inv].[id]                                                        AS invoiceID,
    [inv].[total_amount],
    ISNULL([ins].[coveragepercent], 0)                                AS coveragePercent,
    ROUND([inv].[total_amount] * ISNULL([ins].[coveragepercent], 0) / 100.0, 2) AS insuranceAmount,
    ROUND([inv].[total_amount] * (1 - ISNULL([ins].[coveragepercent], 0) / 100.0), 2) AS patientAmount
  FROM [invoice] AS [inv]
  INNER JOIN [patient] AS [p] ON [p].[nationalID] = [inv].[patientID]
  LEFT JOIN [insurance] AS [ins]
    ON [ins].[id] = [p].[insuranceID] AND [ins].[isActive] = 1  -- Only active insurance policies
  WHERE [inv].[id] = @invoiceID
)
GO
-- PRESCRIPTION & DRUG FUNCTIONS
-- Returns complete drug history for a patient including all prescriptions and items
-- Shows drug details, dosage, duration, and prescribing doctor
-- Returns table with comprehensive prescription history
-- Parameters: @patientID - patient's unique identifier
CREATE FUNCTION [fn_GetPatientDrugHistory] (@patientID nvarchar(255))
RETURNS TABLE
AS
RETURN
(
  SELECT
    [pr].[id]      AS prescriptionID,
    [pr].[date]    AS prescriptionDate,
    [d].[id]       AS drugID,
    [d].[name]     AS drugName,
    [pi].[dose],
    [pi].[duration],
    [pi].[quantity],
    [pr].[status]  AS prescriptionStatus,
    [e].[name]     AS prescribedBy
  FROM [prescription] AS [pr]
  INNER JOIN [prescriptionitem] AS [pi] ON [pi].[prescriptionID] = [pr].[id]
  INNER JOIN [drug] AS [d] ON [d].[id] = [pi].[drugID]
  LEFT JOIN [employee] AS [e] ON [e].[id] = [pr].[employeeID]
  WHERE [pr].[patientID] = @patientID
)
GO

-- Checks if two drugs interact with each other
-- Looks for interaction in either order (drugID1/drugID2 or drugID2/drugID1)
-- Returns: severity level (Minor/Moderate/Severe) or NULL if no interaction
-- Parameters: @drugID1, @drugID2 - drug identifiers
CREATE FUNCTION [fn_CheckDrugInteraction] (@drugID1 int, @drugID2 int)
RETURNS nvarchar(50)
AS
BEGIN
  DECLARE @severity nvarchar(50)
  SELECT @severity = [severity]
  FROM [druginteraction]
  WHERE ([drugID1] = @drugID1 AND [drugID2] = @drugID2)
     OR ([drugID1] = @drugID2 AND [drugID2] = @drugID1)  -- Check both ordering possibilities

  RETURN @severity
END
GO
-- IOT DEVICE FUNCTIONS
-- Gets the current location/assignment of an IoT device
-- Returns the most recent assignment that hasn't been unassigned
-- Returns table with device location details
-- Parameters: @iotdeviceID - device identifier
CREATE FUNCTION [fn_GetCurrentDeviceLocation] (@iotdeviceID int)
RETURNS TABLE
AS
RETURN
(
  SELECT TOP 1
    [dt].[iotdeviceID],
    [dt].[patientID],
    [dt].[admissionID],
    [dt].[departmentID],
    [dt].[bedID],
    [dt].[assignedAt]
  FROM [devicetransfer] AS [dt]
  WHERE [dt].[iotdeviceID] = @iotdeviceID AND [dt].[unassignedAt] IS NULL
  ORDER BY [dt].[assignedAt] DESC  -- Gets the most recent active assignment
)
GO
-- CRITICAL VALUE & ALERT FUNCTIONS
-- Determines if a measurement value is critical based on alert thresholds
-- Checks patient-specific thresholds first, then global thresholds
-- Uses priority: patient-specific > global
-- Returns: bit (1 if critical, 0 if normal)
-- Parameters: 
--   @measurementType - type of measurement (e.g., HeartRate, BloodPressure)
--   @value - measured value
--   @patientID - optional patient for patient-specific thresholds
CREATE FUNCTION [fn_IsValueCritical]
(
  @measurementType nvarchar(255),
  @value           float,
  @patientID       nvarchar(255) = NULL
)
RETURNS bit
AS
BEGIN
  DECLARE @minValue float, @maxValue float, @result bit = 0

  -- Get threshold, preferring patient-specific over global
  SELECT TOP 1 @minValue = [minValue], @maxValue = [maxValue]
  FROM [AlertThreshold]
  WHERE [measurementType] = @measurementType
    AND (
          (@patientID IS NOT NULL AND [patientID] = @patientID)  -- Patient-specific threshold
       OR [isGlobal] = 1                                        -- Or global threshold
        )
  ORDER BY
    CASE WHEN @patientID IS NOT NULL AND [patientID] = @patientID THEN 0 ELSE 1 END  -- Prioritize patient-specific

  -- Check if value falls outside the reference range
  IF @minValue IS NOT NULL AND @value < @minValue SET @result = 1
  IF @maxValue IS NOT NULL AND @value > @maxValue SET @result = 1

  RETURN @result
END
GO
-- DEPARTMENT STATISTICS FUNCTIONS
-- Provides comprehensive bed statistics per department
-- Calculates total beds, occupied, free, reserved, and occupancy percentage
-- Returns table with department stats
CREATE FUNCTION [fn_GetDepartmentBedStats] ()
RETURNS TABLE
AS
RETURN
(
  SELECT
    [d].[id]                                                       AS departmentID,
    [d].[name]                                                     AS departmentName,
    [d].[type]                                                     AS departmentType,
    COUNT([b].[id])                                                AS totalBeds,
    SUM(CASE WHEN [b].[status] = N'Occupied' THEN 1 ELSE 0 END)    AS occupiedBeds,
    SUM(CASE WHEN [b].[status] = N'Free'     THEN 1 ELSE 0 END)    AS freeBeds,
    SUM(CASE WHEN [b].[status] = N'Reserved' THEN 1 ELSE 0 END)    AS reservedBeds,
    CAST(ROUND(
        100.0 * SUM(CASE WHEN [b].[status] = N'Occupied' THEN 1 ELSE 0 END)
        / NULLIF(COUNT([b].[id]), 0)  -- Avoid division by zero
    , 2) AS float)                                                  AS occupancyPercent
  FROM [department] AS [d]
  LEFT JOIN [bed] AS [b] ON [b].[departmentID] = [d].[id]
  GROUP BY [d].[id], [d].[name], [d].[type]
)
GO

-- Counts active admissions (patients currently hospitalized)
-- Optionally filters by department
-- Returns: integer count
-- Parameters: @departmentID - optional department filter (NULL = all departments)
CREATE FUNCTION [fn_CountActiveAdmissions] (@departmentID int = NULL)
RETURNS int
AS
BEGIN
  DECLARE @cnt int

  SELECT @cnt = COUNT(*)
  FROM [admission] AS [a]
  INNER JOIN [bed] AS [b] ON [b].[id] = [a].[bedID]
  WHERE [a].[exitdate] IS NULL  -- Active admission (no exit date)
    AND (@departmentID IS NULL OR [b].[departmentID] = @departmentID)

  RETURN @cnt
END
GO
-- SESSION CONTEXT FUNCTIONS
-- Gets the role of the current user from session context
-- Used for Row-Level Security (RLS) and audit purposes
-- Returns: nvarchar(50) - role name (Patient/Doctor/Nurse/etc.)
CREATE FUNCTION [fn_CurrentSessionRole] ()
RETURNS nvarchar(50)
AS
BEGIN
  RETURN CAST(SESSION_CONTEXT(N'Role') AS nvarchar(50))
END
GO

-- Gets the patient ID of the current user from session context
-- Only meaningful when current user is a Patient role
-- Returns: nvarchar(255) - patient ID or NULL
CREATE FUNCTION [fn_CurrentSessionPatientID] ()
RETURNS nvarchar(255)
AS
BEGIN
  RETURN CAST(SESSION_CONTEXT(N'PatientID') AS nvarchar(255))
END
GO

-- Gets the employee ID of the current user from session context
-- Used for staff user authentication and authorization
-- Returns: int - employee ID or NULL
CREATE FUNCTION [fn_CurrentSessionEmployeeID] ()
RETURNS int
AS
BEGIN
  RETURN CAST(SESSION_CONTEXT(N'EmployeeID') AS int)
END
GO
