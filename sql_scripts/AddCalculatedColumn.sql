USE [Company]
GO

-- Remove foreign key constraints
ALTER TABLE [dbo].Department DROP CONSTRAINT FK_Department_Employee
ALTER TABLE [dbo].Dept_Locations DROP CONSTRAINT FK_Dept_Locations_Department
ALTER TABLE [dbo].Project DROP CONSTRAINT FK_Project_Department
ALTER TABLE [dbo].Employee DROP CONSTRAINT FK_Employee_Department
GO

-- Drop Department table
DROP TABLE [dbo].Department
GO

-- Create new Department table with EmpCount column
CREATE TABLE [dbo].Department(
    DName VARCHAR(50) UNIQUE NOT NULL,
    DNumber INT NOT NULL PRIMARY KEY,
    MgrSSN NUMERIC(9) NOT NULL,
    MgrStartDate DATETIME NOT NULL,
    EmpCount INT NOT NULL,
    CONSTRAINT FK_Department_Employee
        FOREIGN KEY(MgrSSN) REFERENCES [dbo].Employee (SSN),
)
GO

-- Populate Department table again
INSERT [dbo].Department (DName, DNumber, MgrSSN, MgrStartDate, EmpCount) VALUES (N'Headquarters', 1, CAST(888665555 AS Numeric(9, 0)), CAST(N'1971-06-19 00:00:00.000' AS DateTime), 0)
INSERT [dbo].Department (DName, DNumber, MgrSSN, MgrStartDate, EmpCount) VALUES (N'Administration', 4, CAST(123456789 AS Numeric(9, 0)), CAST(N'1986-01-01 00:00:00.000' AS DateTime), 0)
INSERT [dbo].Department (DName, DNumber, MgrSSN, MgrStartDate, EmpCount) VALUES (N'Research', 5, CAST(987654321 AS Numeric(9, 0)), CAST(N'1978-05-22 00:00:00.000' AS DateTime), 0)
GO

-- Add EmpCount values
UPDATE Department
SET EmpCount = (
    SELECT COUNT(*)
    FROM Employee
    WHERE Employee.Dno = Department.DNumber
)
GO

ALTER TABLE [dbo].Dept_Locations ADD CONSTRAINT FK_Dept_Locations_Department FOREIGN KEY (DNUmber) REFERENCES [dbo].Department (DNumber)
ALTER TABLE [dbo].Project ADD CONSTRAINT FK_Project_Department FOREIGN KEY (DNum) REFERENCES [dbo].Department (DNumber)
ALTER TABLE [dbo].Employee ADD CONSTRAINT FK_Employee_Department FOREIGN KEY (Dno) REFERENCES [dbo].Department (DNumber)
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
