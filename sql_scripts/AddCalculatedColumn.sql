USE [Company]
GO

-- Add NULL Attribute EmpCount
ALTER TABLE [dbo].Department
    ADD EmpCount INT NULL;
GO

-- Add EmpCount values
UPDATE [dbo].Department
SET EmpCount = (
    SELECT COUNT(*)
    FROM Employee
    WHERE Employee.Dno = Department.DNumber
)
GO

-- Make it NOT NULL
ALTER TABLE [dbo].Department
    ALTER COLUMN EmpCount INT NOT NULL;
GO


-- New stored procedure to fetch EmpCount
IF OBJECT_ID('usp_FetchEmpCount', 'P') IS NOT NULL
    DROP PROCEDURE usp_FetchEmpCount
GO

CREATE PROCEDURE usp_FetchEmpCount(
    @DNumber INT,
    @EmpCount INT OUTPUT
) AS
BEGIN
    SET @EmpCount = (
        SELECT COUNT(*) AS EmpCount
        FROM Department
             INNER JOIN Employee ON Department.DNumber = Employee.Dno
        WHERE Department.DNumber = @DNumber
    )
END
GO

-- Updated CreateDepartment procedure
IF OBJECT_ID('usp_CreateDepartment', 'P') IS NOT NULL
    DROP PROCEDURE usp_CreateDepartment
GO

CREATE PROCEDURE usp_CreateDepartment (
    @DName VARCHAR(50),
    @MgrSSN NUMERIC(9)
) AS
BEGIN
    DECLARE @DNumber INT
    DECLARE @MgrStartDate DATETIME
    DECLARE @EmpCount INT

    SET @DNumber = (SELECT ISNULL(MAX(DNumber), 0) + 1 FROM Department)

    IF EXISTS(SELECT * FROM Department WHERE DName = @DName)
        BEGIN
            THROW 51000, 'Department name already exists.', 1
        END

    IF EXISTS(SELECT * FROM Department WHERE MgrSSN = @MgrSSN)
        BEGIN
            THROW 51000, 'The manager is already a department manager.', 1
        END

    SET @MgrStartDate = GETDATE()

    EXECUTE usp_FetchEmpCount @DNumber,@EmpCount OUTPUT

    INSERT INTO Department (DName, DNumber, MgrSSN, MgrStartDate, EmpCount)
    VALUES (@DName, @DNumber, @MgrSSN, @MgrStartDate, @EmpCount)

    SELECT @DNumber AS 'DNumber'
END
GO

-- Updated UpdateDepartmentManager procedure
IF OBJECT_ID('usp_UpdateDepartmentManager', 'P') IS NOT NULL
    DROP PROCEDURE usp_UpdateDepartmentManager
GO

CREATE PROCEDURE [dbo].usp_UpdateDepartmentManager (
    @DNumber INT,
    @MgrSSN NUMERIC(9)
) AS
BEGIN
    IF EXISTS(SELECT * FROM Department WHERE DNumber = @DNumber)
        BEGIN
            IF EXISTS(SELECT * FROM Employee WHERE SSN = @MgrSSN)
                BEGIN
                    IF NOT EXISTS(SELECT * FROM Department WHERE MgrSSN = @MgrSSN)
                        BEGIN
                            UPDATE Department SET MgrSSN = @MgrSSN, MgrStartDate = GETDATE() WHERE DNumber = @DNumber
                            UPDATE Employee SET SuperSSN = @MgrSSN WHERE Dno = @DNumber AND SSN NOT IN (SELECT MgrSSN FROM Department)
                            DECLARE @EmpCount INT
                            EXECUTE usp_FetchEmpCount @DNumber, @EmpCount OUTPUT
                            UPDATE Department SET EmpCount = @EmpCount WHERE DNumber = @DNumber
                            SELECT 'Department Manager updated successfully! :)' AS 'Message'
                        END
                    ELSE
                        BEGIN
                            THROW 51000, 'Manager already manages another department.', 1
                        END
                END
            ELSE
                BEGIN
                    THROW 51000, 'Manager SSN does not exist in the Employee table.', 1
                END
        END
    ELSE
        BEGIN
            THROW 51000, 'Department number not found.', 1
        END
END
GO

-- Updated GetDepartment procedure
IF OBJECT_ID('usp_GetDepartment', 'P') IS NOT NULL
    DROP PROCEDURE usp_GetDepartment
GO

CREATE PROCEDURE usp_GetDepartment (
    @DNumber INT
) AS
BEGIN
    SELECT *
    FROM Department
    WHERE DNumber = @DNumber
END
GO

-- Updated GetAllDepartments procedure
IF OBJECT_ID('usp_GetAllDepartments', 'P') IS NOT NULL
    DROP PROCEDURE usp_GetAllDepartments
GO

CREATE PROCEDURE usp_GetAllDepartments AS
BEGIN
    SELECT *
    FROM Department
END
GO
