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

CREATE TRIGGER [trg_invoiceitem_recalculate_total] ON [invoiceitem]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
  SET NOCOUNT ON

  ;WITH [AffectedInvoices] AS (
    SELECT [invoiceID] FROM [inserted]
    UNION
    SELECT [invoiceID] FROM [deleted]
  ),
  [InvoiceTotals] AS (
    SELECT [ai].[invoiceID], ISNULL(SUM([ii].[amount]), 0) AS [newTotal]
    FROM [AffectedInvoices] AS [ai]
    LEFT JOIN [invoiceitem] AS [ii] ON [ii].[invoiceID] = [ai].[invoiceID]
    GROUP BY [ai].[invoiceID]
  )
  UPDATE [inv]
  SET [inv].[total_amount]    = [it].[newTotal],
      [inv].[insuranceAmount] = ROUND([it].[newTotal] * ISNULL([ins].[coveragepercent], 0) / 100.0, 2),
      [inv].[patientAmount]   = ROUND([it].[newTotal] * (1 - ISNULL([ins].[coveragepercent], 0) / 100.0), 2)
  FROM [invoice] AS [inv]
  INNER JOIN [InvoiceTotals] AS [it] ON [it].[invoiceID] = [inv].[id]
  INNER JOIN [patient] AS [p] ON [p].[nationalID] = [inv].[patientID]
  LEFT JOIN [insurance] AS [ins] ON [ins].[id] = [p].[insuranceID] AND [ins].[isActive] = 1
END
GO

CREATE TRIGGER [trg_payment_update_invoice] ON [payment]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON

  UPDATE [inv]
  SET [inv].[paidAmount] = [inv].[paidAmount] + [paid].[amountSum]
  FROM [invoice] AS [inv]
  INNER JOIN (
    SELECT [invoiceID], SUM([amount]) AS [amountSum] FROM [inserted] GROUP BY [invoiceID]
  ) AS [paid] ON [paid].[invoiceID] = [inv].[id]

  UPDATE [invoice]
  SET [status] = CASE
                   WHEN [total_amount] > 0 AND [paidAmount] >= [total_amount] THEN N'Paid'
                   WHEN [paidAmount] > 0 THEN N'PartiallyPaid'
                   ELSE N'Unpaid'
                 END
  WHERE [id] IN (SELECT DISTINCT [invoiceID] FROM [inserted])
END
GO

CREATE TRIGGER [trg_appointment_prevent_conflict] ON [appointment]
INSTEAD OF INSERT
AS
BEGIN
  SET NOCOUNT ON

  IF EXISTS (
    SELECT 1
    FROM [inserted] AS [i]
    INNER JOIN [appointment] AS [a]
      ON [a].[employeeID] = [i].[employeeID]
     AND [a].[date]       = [i].[date]
     AND [a].[time]       = [i].[time]
     AND [a].[status] <> N'Cancelled'
  )
  BEGIN
    RAISERROR(N'The selected doctor already has an appointment at this date and time.', 16, 1)
    RETURN
  END

  INSERT INTO [appointment] ([employeeID], [patientID], [departmentID], [date], [time], [status], [appointment_type])
  SELECT [employeeID], [patientID], [departmentID], [date], [time], ISNULL([status], N'Scheduled'), [appointment_type]
  FROM [inserted]
END
GO