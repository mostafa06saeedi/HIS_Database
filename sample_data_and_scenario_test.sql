CREATE PROCEDURE [sp_RegisterPatientLogin]
  @nationalID nvarchar(255),
  @username   nvarchar(100),
  @password   nvarchar(100)
AS
BEGIN
  SET NOCOUNT ON

  IF NOT EXISTS (SELECT 1 FROM [patient] WHERE [nationalID] = @nationalID)
  BEGIN
    RAISERROR(N'Patient with this national ID not found; register with sp_RegisterPatient first.', 16, 1)
    RETURN
  END

  IF EXISTS (SELECT 1 FROM [UserAccount] WHERE [username] = @username)
  BEGIN
    RAISERROR(N'This username is already taken.', 16, 1)
    RETURN
  END

  DECLARE @salt uniqueidentifier = NEWID()

  INSERT INTO [UserAccount] ([username], [passwordHash], [passwordSalt], [role], [patientID])
  VALUES (@username, HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt) + @password), @salt, N'Patient', @nationalID)
END
GO

CREATE PROCEDURE [sp_RegisterEmployeeLogin]
  @employeeID int,
  @username   nvarchar(100),
  @password   nvarchar(100),
  @role       nvarchar(50)
AS
BEGIN
  SET NOCOUNT ON

  IF NOT EXISTS (SELECT 1 FROM [employee] WHERE [id] = @employeeID)
  BEGIN
    RAISERROR(N'Employee with this ID not found.', 16, 1)
    RETURN
  END

  IF @role = N'Doctor' AND NOT EXISTS (SELECT 1 FROM [doctor] WHERE [employeeID] = @employeeID)
  BEGIN
    RAISERROR(N'This employee is not registered as a doctor; Doctor role is invalid.', 16, 1)
    RETURN
  END

  IF @role = N'Nurse' AND NOT EXISTS (SELECT 1 FROM [nurse] WHERE [employeeID] = @employeeID)
  BEGIN
    RAISERROR(N'This employee is not registered as a nurse; Nurse role is invalid.', 16, 1)
    RETURN
  END

  IF @role IN (N'Pharmacist', N'LabTech', N'Reception', N'Manager')
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM [adminstaff]
      WHERE [employeeID] = @employeeID
        AND LOWER([role]) = LOWER(CASE @role WHEN N'LabTech' THEN N'lab_tech' ELSE @role END)
    )
    BEGIN
      RAISERROR(N'Selected role does not match the employee role registered in adminstaff.', 16, 1)
      RETURN
    END
  END

  IF EXISTS (SELECT 1 FROM [UserAccount] WHERE [username] = @username)
  BEGIN
    RAISERROR(N'This username is already taken.', 16, 1)
    RETURN
  END

  DECLARE @salt uniqueidentifier = NEWID()

  INSERT INTO [UserAccount] ([username], [passwordHash], [passwordSalt], [role], [employeeID])
  VALUES (@username, HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt) + @password), @salt, @role, @employeeID)
END
GO
