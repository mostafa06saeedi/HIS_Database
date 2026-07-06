CREATE FUNCTION [fn_CalculateAge] (@nationalID nvarchar(255))
RETURNS int
AS
BEGIN
  DECLARE @age int
  SELECT @age = DATEDIFF(YEAR, [datebirth], GETDATE())
               - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, [datebirth], GETDATE()), [datebirth]) > GETDATE()
                      THEN 1 ELSE 0 END
  FROM [patient]
  WHERE [nationalID] = @nationalID

  RETURN @age
END

CREATE FUNCTION [fn_IsBedAvailable] (@bedID int)
RETURNS bit
AS
BEGIN
  DECLARE @result bit = 0
  IF EXISTS (SELECT 1 FROM [bed] WHERE [id] = @bedID AND [status] = N'Free')
    SET @result = 1
  RETURN @result
END

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

CREATE FUNCTION [fn_GetPatientActiveAdmission] (@patientID nvarchar(255))
RETURNS int
AS
BEGIN
  DECLARE @admissionID int
  SELECT TOP 1 @admissionID = [id]
  FROM [admission]
  WHERE [patientID] = @patientID AND [exitdate] IS NULL
  ORDER BY [entrydate] DESC

  RETURN @admissionID
END

CREATE FUNCTION [fn_GetPatientCurrentBed] (@admissionID int)
RETURNS int
AS
BEGIN
  DECLARE @bedID int

  SELECT TOP 1 @bedID = [toBedID]
  FROM [patienttransfer]
  WHERE [admissionID] = @admissionID
  ORDER BY [date] DESC, [time] DESC

  IF @bedID IS NULL
    SELECT @bedID = [bedID] FROM [admission] WHERE [id] = @admissionID

  RETURN @bedID
END

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
    ON [ins].[id] = [p].[insuranceID] AND [ins].[isActive] = 1
  WHERE [inv].[id] = @invoiceID
)

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

CREATE FUNCTION [fn_CheckDrugInteraction] (@drugID1 int, @drugID2 int)
RETURNS nvarchar(50)
AS
BEGIN
  DECLARE @severity nvarchar(50)
  SELECT @severity = [severity]
  FROM [druginteraction]
  WHERE ([drugID1] = @drugID1 AND [drugID2] = @drugID2)
     OR ([drugID1] = @drugID2 AND [drugID2] = @drugID1)

  RETURN @severity
END

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
  ORDER BY [dt].[assignedAt] DESC
)

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

  SELECT TOP 1 @minValue = [minValue], @maxValue = [maxValue]
  FROM [AlertThreshold]
  WHERE [measurementType] = @measurementType
    AND (
          (@patientID IS NOT NULL AND [patientID] = @patientID)
       OR [isGlobal] = 1
        )
  ORDER BY
    CASE WHEN @patientID IS NOT NULL AND [patientID] = @patientID THEN 0 ELSE 1 END

  IF @minValue IS NOT NULL AND @value < @minValue SET @result = 1
  IF @maxValue IS NOT NULL AND @value > @maxValue SET @result = 1

  RETURN @result
END
