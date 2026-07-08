-- BED MANAGEMENT TRIGGERS
-- Trigger: Automatically marks a bed as 'Occupied' when a new admission is created
-- Validates that the bed is 'Free' before allowing admission
-- Prevents double-booking of beds
CREATE TRIGGER [trg_admission_bed_occupy] ON [admission]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON

  -- Check if any bed being assigned is not currently free
  IF EXISTS (
    SELECT 1 FROM [inserted] AS [i]
    INNER JOIN [bed] AS [b] ON [b].[id] = [i].[bedID]
    WHERE [b].[status] <> N'Free'
  )
  BEGIN
    RAISERROR(N'Selected bed is not currently free.', 16, 1)
    RETURN
  END
  -- Update the bed status to 'Occupied'
  UPDATE [b]
  SET [b].[status] = N'Occupied'
  FROM [bed] AS [b]
  INNER JOIN [inserted] AS [i] ON [i].[bedID] = [b].[id]
END
GO
-- Trigger: Automatically marks a bed as 'Free' when a patient is discharged
-- Only triggers when the exitdate column is updated from NULL to a value
-- Ensures beds become available immediately after patient discharge
CREATE TRIGGER [trg_admission_bed_free] ON [admission]
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON

  -- Only proceed if the exitdate was updated
  IF UPDATE([exitdate])
  BEGIN
    UPDATE [b]
    SET [b].[status] = N'Free'
    FROM [bed] AS [b]
    INNER JOIN [inserted] AS [i] ON [i].[bedID] = [b].[id]
    INNER JOIN [deleted]  AS [d] ON [d].[id] = [i].[id]
    WHERE [i].[exitdate] IS NOT NULL AND [d].[exitdate] IS NULL  -- Exit date changed from NULL to a value
  END
END
GO

-- Trigger: Handles bed changes during patient transfers
-- Frees the source bed and occupies the destination bed
-- Validates that the destination bed is free before transfer
CREATE TRIGGER [trg_patienttransfer_bed_update] ON [patienttransfer]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON

  -- Validate that the destination bed is free
  IF EXISTS (
    SELECT 1 FROM [inserted] AS [i]
    INNER JOIN [bed] AS [b] ON [b].[id] = [i].[toBedID]
    WHERE [b].[status] <> N'Free'
  )
  BEGIN
    RAISERROR(N'Destination bed is not free.', 16, 1)
    RETURN
  END

  -- Free up the source bed
  UPDATE [b] SET [b].[status] = N'Free'
  FROM [bed] AS [b]
  INNER JOIN [inserted] AS [i] ON [i].[fromBedID] = [b].[id]

  -- Occupy the destination bed
  UPDATE [b] SET [b].[status] = N'Occupied'
  FROM [bed] AS [b]
  INNER JOIN [inserted] AS [i] ON [i].[toBedID] = [b].[id]
END
GO
-- LAB RESULT CRITICAL ALERT TRIGGER
-- Trigger: Automatically creates critical alerts when lab results fall outside reference ranges
-- Uses the isCritical table for reference values (min/max)
-- Attempts to associate the alert with the requesting doctor
-- Alert severity is set to 'Critical' with status 'Unreviewed'
CREATE TRIGGER [trg_labresult_critical_alert] ON [labresult]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON

  ;WITH [ResultCheck] AS (
    SELECT
      [i].[id]                       AS [labResultID],
      TRY_CAST([i].[value] AS float) AS [numericValue],  -- Safely convert value to numeric
      [ic].[referenceMin],
      [ic].[referenceMax],
      [lr].[employeeID]              AS [requestingEmployeeID]  -- Doctor who requested the lab
    FROM [inserted] AS [i]
    LEFT JOIN [isCritical] AS [ic] ON [ic].[id] = [i].[isCritical]
    LEFT JOIN [Labimagingrequest] AS [lr] ON [lr].[id] = [i].[LabimagingrequestID]
  )
  -- Insert alert if value is outside reference range
  INSERT INTO [labalert] ([doctorID], [labResultID], [severity], [status], [createdAt])
  SELECT
    CASE WHEN EXISTS (SELECT 1 FROM [doctor] AS [doc] WHERE [doc].[employeeID] = [rc].[requestingEmployeeID])
         THEN [rc].[requestingEmployeeID] ELSE NULL END,  -- Only assign if employee is a doctor
    [rc].[labResultID],
    N'Critical',  -- All out-of-range lab results are considered critical
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
-- IOT DEVICE ALERT TRIGGER
-- Trigger: Monitors IoT device readings and creates alerts when values exceed thresholds
-- Checks both global thresholds and patient-specific thresholds
-- Priorities patient-specific thresholds over global ones
-- Links alerts to the currently assigned patient for the device
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
      [dt].[patientID]  -- Get the patient currently assigned to this device
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
                      ELSE 1 END  -- Give priority to patient-specific thresholds
      ) AS [rn]
    FROM [DeviceContext] AS [dc]
    INNER JOIN [AlertThreshold] AS [at]
      ON [at].[measurementType] = [dc].[type]
     AND ( ([dc].[patientID] IS NOT NULL AND [at].[patientID] = [dc].[patientID]) OR [at].[isGlobal] = 1 )
  )
  -- Insert alerts for values outside threshold ranges
  INSERT INTO [alert] ([logID], [alertThresholdID], [severity], [status], [createdtime])
  SELECT [mt].[logID], [mt].[thresholdID], [mt].[severity], N'Unreviewed', GETDATE()
  FROM [MatchedThreshold] AS [mt]
  WHERE [mt].[rn] = 1  -- Only use the highest priority threshold
    AND (
          ([mt].[minValue] IS NOT NULL AND [mt].[value] < [mt].[minValue])
       OR ([mt].[maxValue] IS NOT NULL AND [mt].[value] > [mt].[maxValue])
        )
END
GO
-- DEVICE TRANSFER TRIGGER
-- Trigger: Automatically closes previous device assignments when a new one is created
-- Sets unassignedAt for the previous assignment to the new assignment time
-- Maintains history of device assignments without orphaned records
CREATE TRIGGER [trg_devicetransfer_close_previous] ON [devicetransfer]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON

  -- Close any open (unassignedAt is NULL) assignment for the same device
  UPDATE [dt]
  SET [dt].[unassignedAt] = [i].[assignedAt]
  FROM [devicetransfer] AS [dt]
  INNER JOIN [inserted] AS [i] ON [i].[iotdeviceID] = [dt].[iotdeviceID]
  WHERE [dt].[unassignedAt] IS NULL AND [dt].[id] <> [i].[id]  -- Don't close the new assignment itself
END
GO
-- INVENTORY MANAGEMENT TRIGGER
-- Trigger: Automatically updates inventory quantities when transactions are recorded
-- Adds quantity for 'IN' transactions, subtracts for 'OUT' transactions
-- Validates that inventory doesn't go negative for 'OUT' transactions
-- Prevents dispensing more than available stock
CREATE TRIGGER [trg_storagetransaction_update_inventory] ON [storage_transaction]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON

  -- Add inventory for 'IN' transactions (receiving stock)
  UPDATE [s] SET [s].[inventory] = [s].[inventory] + [i].[quantity]
  FROM [storage] AS [s]
  INNER JOIN [inserted] AS [i] ON [i].[storageID] = [s].[id]
  WHERE [i].[type] = N'IN'

  -- Subtract inventory for 'OUT' transactions (dispensing stock)
  UPDATE [s] SET [s].[inventory] = [s].[inventory] - [i].[quantity]
  FROM [storage] AS [s]
  INNER JOIN [inserted] AS [i] ON [i].[storageID] = [s].[id]
  WHERE [i].[type] = N'OUT'

  -- Check if any storage location has negative inventory
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
-- FINANCIAL TRIGGERS
-- Trigger: Automatically recalculates invoice totals when items are added, updated, or deleted
-- Updates total_amount, insuranceAmount, and patientAmount
-- Uses the patient's active insurance coverage percentage for calculations
CREATE TRIGGER [trg_invoiceitem_recalculate_total] ON [invoiceitem]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
  SET NOCOUNT ON

  ;WITH [AffectedInvoices] AS (
    SELECT [invoiceID] FROM [inserted]   -- Invoices with new/updated items
    UNION
    SELECT [invoiceID] FROM [deleted]    -- Invoices with deleted items
  ),
  [InvoiceTotals] AS (
    SELECT [ai].[invoiceID], ISNULL(SUM([ii].[amount]), 0) AS [newTotal]
    FROM [AffectedInvoices] AS [ai]
    LEFT JOIN [invoiceitem] AS [ii] ON [ii].[invoiceID] = [ai].[invoiceID]
    GROUP BY [ai].[invoiceID]
  )
  -- Update the invoice with recalculated amounts
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
-- Trigger: Updates invoice paid amount and status when a payment is made
-- Adds the payment amount to the invoice's paidAmount
-- Updates invoice status based on paidAmount vs total_amount:
--   - Paid: paidAmount >= total_amount
--   - PartiallyPaid: paidAmount > 0 and < total_amount
--   - Unpaid: paidAmount = 0
CREATE TRIGGER [trg_payment_update_invoice] ON [payment]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON
  -- Add payment amounts to invoice paidAmount
  UPDATE [inv]
  SET [inv].[paidAmount] = [inv].[paidAmount] + [paid].[amountSum]
  FROM [invoice] AS [inv]
  INNER JOIN (
    SELECT [invoiceID], SUM([amount]) AS [amountSum] FROM [inserted] GROUP BY [invoiceID]
  ) AS [paid] ON [paid].[invoiceID] = [inv].[id]

  -- Update invoice status based on payment progress
  UPDATE [invoice]
  SET [status] = CASE
                   WHEN [total_amount] > 0 AND [paidAmount] >= [total_amount] THEN N'Paid'
                   WHEN [paidAmount] > 0 THEN N'PartiallyPaid'
                   ELSE N'Unpaid'
                 END
  WHERE [id] IN (SELECT DISTINCT [invoiceID] FROM [inserted])
END
GO
-- APPOINTMENT CONFLICT PREVENTION TRIGGER
-- Trigger: Prevents double-booking of doctors for appointments
-- Uses INSTEAD OF INSERT to validate before inserting
-- Checks for existing non-cancelled appointments at the same date/time for the same doctor
-- Allows the insert only if no conflict exists
CREATE TRIGGER [trg_appointment_prevent_conflict] ON [appointment]
INSTEAD OF INSERT
AS
BEGIN
  SET NOCOUNT ON

  -- Check for conflicting appointments
  IF EXISTS (
    SELECT 1
    FROM [inserted] AS [i]
    INNER JOIN [appointment] AS [a]
      ON [a].[employeeID] = [i].[employeeID]
     AND [a].[date]       = [i].[date]
     AND [a].[time]       = [i].[time]
     AND [a].[status] <> N'Cancelled'  -- Ignore cancelled appointments
  )
  BEGIN
    RAISERROR(N'The selected doctor already has an appointment at this date and time.', 16, 1)
    RETURN
  END

  -- No conflict found, proceed with insert
  INSERT INTO [appointment] ([employeeID], [patientID], [departmentID], [date], [time], [status], [appointment_type])
  SELECT [employeeID], [patientID], [departmentID], [date], [time], ISNULL([status], N'Scheduled'), [appointment_type]
  FROM [inserted]
END
GO