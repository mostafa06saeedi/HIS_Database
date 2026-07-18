-- Trigger for prescription item safety checks
-- This trigger performs two safety checks after each new prescription item is inserted:
-- 1. Drug interaction with other active prescriptions of the patient
-- 2. Patient drug allergy verification
CREATE TRIGGER [trg_prescriptionitem_safety_check] ON [prescriptionitem]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON
  -- Part 1: Drug Interaction Check
  -- Finds all active prescription items for the same patient and
  -- checks for drug interactions between the new drug and each existing one
  INSERT INTO [prescriptionsafetyalert] ([prescriptionItemID], [alertType], [relatedDrugID], [severity], [message])
  SELECT [i].[id], N'DrugInteraction', [pi2].[drugID],
         [dbo].[fn_CheckDrugInteraction]([i].[drugID], [pi2].[drugID]),
         N'Interaction detected with another active prescription for this patient.'
  FROM [inserted] AS [i]
  INNER JOIN [prescription] AS [pr] ON [pr].[id] = [i].[prescriptionID]
  INNER JOIN [prescriptionitem] AS [pi2]
    ON [pi2].[prescriptionID] IN (SELECT [id] FROM [prescription] WHERE [patientID] = [pr].[patientID] AND [status] <> N'Cancelled')
   AND [pi2].[id] <> [i].[id]
   AND [pi2].[drugID] <> [i].[drugID]
  WHERE [dbo].[fn_CheckDrugInteraction]([i].[drugID], [pi2].[drugID]) IS NOT NULL
  -- Part 2: Allergy Check
  -- Verifies whether the patient has any recorded allergy to the new drug
  INSERT INTO [prescriptionsafetyalert] ([prescriptionItemID], [alertType], [relatedDrugID], [severity], [message])
  SELECT [i].[id], N'Allergy', [i].[drugID],
         [dbo].[fn_CheckPatientAllergy]([pr].[patientID], [i].[drugID]),
         N'Patient has a recorded allergy to this drug.'
  FROM [inserted] AS [i]
  INNER JOIN [prescription] AS [pr] ON [pr].[id] = [i].[prescriptionID]
  WHERE [dbo].[fn_CheckPatientAllergy]([pr].[patientID], [i].[drugID]) IS NOT NULL
END
GO
-- Trigger for updating operating room status
-- This trigger updates the operating room status after surgery records
-- are inserted or updated, based on surgery start and end times
CREATE TRIGGER [trg_surgeryrecord_or_status] ON [surgeryrecord]
AFTER INSERT, UPDATE
AS
BEGIN
  SET NOCOUNT ON
  -- Update operating room status to "Occupied"
  -- When surgery has started (actualStart has value) but not yet ended (actualEnd is null)
  UPDATE [o] SET [o].[status] = N'Occupied'
  FROM [operatingroom] AS [o]
  INNER JOIN [inserted] AS [i] ON [i].[operatingRoomID] = [o].[id]
  WHERE [i].[actualStart] IS NOT NULL AND [i].[actualEnd] IS NULL
  -- Update operating room status to "Free"
  -- When surgery has ended (actualEnd has value) or has been cancelled (status = Cancelled)
  UPDATE [o] SET [o].[status] = N'Free'
  FROM [operatingroom] AS [o]
  INNER JOIN [inserted] AS [i] ON [i].[operatingRoomID] = [o].[id]
  WHERE [i].[actualEnd] IS NOT NULL OR [i].[status] = N'Cancelled'
END
GO