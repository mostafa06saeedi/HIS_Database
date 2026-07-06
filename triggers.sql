CREATE TRIGGER [trg_admission_bed_occupy] ON [admission]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON

  IF EXISTS (
    SELECT 1 FROM [inserted] AS [i]
    INNER JOIN [bed] AS [b] ON [b].[id] = [i].[bedID]
    WHERE [b].[status] <> N'Free'
  )
  BEGIN
    RAISERROR(N'Selected bed is not currently free.', 16, 1)
    RETURN
  END

  UPDATE [b]
  SET [b].[status] = N'Occupied'
  FROM [bed] AS [b]
  INNER JOIN [inserted] AS [i] ON [i].[bedID] = [b].[id]
END
GO

CREATE TRIGGER [trg_admission_bed_free] ON [admission]
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON

  IF UPDATE([exitdate])
  BEGIN
    UPDATE [b]
    SET [b].[status] = N'Free'
    FROM [bed] AS [b]
    INNER JOIN [inserted] AS [i] ON [i].[bedID] = [b].[id]
    INNER JOIN [deleted]  AS [d] ON [d].[id] = [i].[id]
    WHERE [i].[exitdate] IS NOT NULL AND [d].[exitdate] IS NULL
  END
END
GO

CREATE TRIGGER [trg_patienttransfer_bed_update] ON [patienttransfer]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON

  IF EXISTS (
    SELECT 1 FROM [inserted] AS [i]
    INNER JOIN [bed] AS [b] ON [b].[id] = [i].[toBedID]
    WHERE [b].[status] <> N'Free'
  )
  BEGIN
    RAISERROR(N'Destination bed is not free.', 16, 1)
    RETURN
  END

  UPDATE [b] SET [b].[status] = N'Free'
  FROM [bed] AS [b]
  INNER JOIN [inserted] AS [i] ON [i].[fromBedID] = [b].[id]

  UPDATE [b] SET [b].[status] = N'Occupied'
  FROM [bed] AS [b]
  INNER JOIN [inserted] AS [i] ON [i].[toBedID] = [b].[id]
END
GO

CREATE TRIGGER [trg_labresult_critical_alert] ON [labresult]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON

  ;WITH [ResultCheck] AS (
    SELECT
      [i].[id]                       AS [labResultID],
      TRY_CAST([i].[value] AS float) AS [numericValue],
      [ic].[referenceMin],
      [ic].[referenceMax],
      [lr].[employeeID]              AS [requestingEmployeeID]
    FROM [inserted] AS [i]
    LEFT JOIN [isCritical] AS [ic] ON [ic].[id] = [i].[isCritical]
    LEFT JOIN [Labimagingrequest] AS [lr] ON [lr].[id] = [i].[LabimagingrequestID]
  )
  INSERT INTO [labalert] ([doctorID], [labResultID], [severity], [status], [createdAt])
  SELECT
    CASE WHEN EXISTS (SELECT 1 FROM [doctor] AS [doc] WHERE [doc].[employeeID] = [rc].[requestingEmployeeID])
         THEN [rc].[requestingEmployeeID] ELSE NULL END,
    [rc].[labResultID],
    N'Critical',
    N'Unreviewed',
    GETDATE()
  FROM [ResultCheck] AS [rc]
  WHERE [rc].[numericValue] IS NOT NULL
    AND (
          ([rc].[referenceMin] IS NOT NULL AND [rc].[numericValue] < [rc].[referenceMin])
       OR ([rc].[referenceMax] IS NOT NULL AND [rc].[numericValue] > [rc].[referenceMax])
        )
END
GO
