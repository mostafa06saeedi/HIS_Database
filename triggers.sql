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

CREATE TRIGGER [trg_iotlog_alert] ON [logs]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON

  ;WITH [DeviceContext] AS (
    SELECT
      [i].[id]        AS [logID],
      [i].[deviceID],
      [i].[type],
      [i].[value],
      [dt].[patientID]
    FROM [inserted] AS [i]
    OUTER APPLY (
      SELECT TOP 1 [dt2].[patientID]
      FROM [devicetransfer] AS [dt2]
      WHERE [dt2].[iotdeviceID] = [i].[deviceID] AND [dt2].[unassignedAt] IS NULL
      ORDER BY [dt2].[assignedAt] DESC
    ) AS [dt]
  ),
  [MatchedThreshold] AS (
    SELECT
      [dc].[logID],
      [dc].[value],
      [at].[id]       AS [thresholdID],
      [at].[minValue],
      [at].[maxValue],
      [at].[severity],
      ROW_NUMBER() OVER (
        PARTITION BY [dc].[logID]
        ORDER BY CASE WHEN [dc].[patientID] IS NOT NULL AND [at].[patientID] = [dc].[patientID] THEN 0
                      ELSE 1 END
      ) AS [rn]
    FROM [DeviceContext] AS [dc]
    INNER JOIN [AlertThreshold] AS [at]
      ON [at].[measurementType] = [dc].[type]
     AND ( ([dc].[patientID] IS NOT NULL AND [at].[patientID] = [dc].[patientID]) OR [at].[isGlobal] = 1 )
  )
  INSERT INTO [alert] ([logID], [alertThresholdID], [severity], [status], [createdtime])
  SELECT [mt].[logID], [mt].[thresholdID], [mt].[severity], N'Unreviewed', GETDATE()
  FROM [MatchedThreshold] AS [mt]
  WHERE [mt].[rn] = 1
    AND (
          ([mt].[minValue] IS NOT NULL AND [mt].[value] < [mt].[minValue])
       OR ([mt].[maxValue] IS NOT NULL AND [mt].[value] > [mt].[maxValue])
        )
END
GO

CREATE TRIGGER [trg_devicetransfer_close_previous] ON [devicetransfer]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON

  UPDATE [dt]
  SET [dt].[unassignedAt] = [i].[assignedAt]
  FROM [devicetransfer] AS [dt]
  INNER JOIN [inserted] AS [i] ON [i].[iotdeviceID] = [dt].[iotdeviceID]
  WHERE [dt].[unassignedAt] IS NULL AND [dt].[id] <> [i].[id]
END
GO

CREATE TRIGGER [trg_storagetransaction_update_inventory] ON [storage_transaction]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON

  UPDATE [s] SET [s].[inventory] = [s].[inventory] + [i].[quantity]
  FROM [storage] AS [s]
  INNER JOIN [inserted] AS [i] ON [i].[storageID] = [s].[id]
  WHERE [i].[type] = N'IN'

  UPDATE [s] SET [s].[inventory] = [s].[inventory] - [i].[quantity]
  FROM [storage] AS [s]
  INNER JOIN [inserted] AS [i] ON [i].[storageID] = [s].[id]
  WHERE [i].[type] = N'OUT'

  IF EXISTS (
    SELECT 1
    FROM [storage] AS [s]
    WHERE [s].[inventory] < 0
      AND [s].[id] IN (SELECT DISTINCT [storageID] FROM [inserted])
  )
  BEGIN
    RAISERROR(N'Insufficient inventory for this transaction.', 16, 1)
    RETURN
  END
END
GO
