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
