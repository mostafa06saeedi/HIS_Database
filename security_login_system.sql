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

CREATE PROCEDURE [sp_Login]
  @username nvarchar(100),
  @password nvarchar(100),
  @success  bit OUTPUT,
  @message  nvarchar(255) OUTPUT
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @id int, @hash varbinary(64), @salt uniqueidentifier,
          @role nvarchar(50), @patientID nvarchar(255), @employeeID int, @isActive bit

  SELECT @id = [id], @hash = [passwordHash], @salt = [passwordSalt], @role = [role],
         @patientID = [patientID], @employeeID = [employeeID], @isActive = [isActive]
  FROM [UserAccount]
  WHERE [username] = @username

  IF @id IS NULL
  BEGIN
    SET @success = 0
    SET @message = N'Username not found.'
    RETURN
  END

  IF @isActive = 0
  BEGIN
    SET @success = 0
    SET @message = N'This account has been deactivated.'
    RETURN
  END

  IF HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt) + @password) <> @hash
  BEGIN
    SET @success = 0
    SET @message = N'Incorrect password.'
    RETURN
  END

  EXEC [sys].[sp_set_session_context] @key = N'UserID',     @value = @id
  EXEC [sys].[sp_set_session_context] @key = N'Role',       @value = @role
  EXEC [sys].[sp_set_session_context] @key = N'PatientID',  @value = @patientID
  EXEC [sys].[sp_set_session_context] @key = N'EmployeeID', @value = @employeeID

  UPDATE [UserAccount] SET [lastLoginAt] = GETDATE() WHERE [id] = @id

  SET @success = 1
  SET @message = N'Login successful - Role: ' + @role
END
GO

CREATE PROCEDURE [sp_Logout]
AS
BEGIN
  SET NOCOUNT ON

  EXEC [sys].[sp_set_session_context] @key = N'UserID',     @value = NULL
  EXEC [sys].[sp_set_session_context] @key = N'Role',       @value = NULL
  EXEC [sys].[sp_set_session_context] @key = N'PatientID',  @value = NULL
  EXEC [sys].[sp_set_session_context] @key = N'EmployeeID', @value = NULL
END
GO

CREATE PROCEDURE [sp_ChangePassword]
  @username     nvarchar(100),
  @oldPassword  nvarchar(100),
  @newPassword  nvarchar(100)
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @hash varbinary(64), @salt uniqueidentifier
  SELECT @hash = [passwordHash], @salt = [passwordSalt] FROM [UserAccount] WHERE [username] = @username

  IF @hash IS NULL OR HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt) + @oldPassword) <> @hash
  BEGIN
    RAISERROR(N'Incorrect username or current password.', 16, 1)
    RETURN
  END

  DECLARE @newSalt uniqueidentifier = NEWID()
  UPDATE [UserAccount]
  SET [passwordHash] = HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @newSalt) + @newPassword),
      [passwordSalt] = @newSalt
  WHERE [username] = @username
END
GO
