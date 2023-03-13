USE [Company]
GO

-- Procedure A:
CREATE PROCEDURE [dbo].usp_CreateDepartment (
    @DName VARCHAR(50),
    @MgrSSN NUMERIC(9)
) AS
BEGIN
    DECLARE @DNumber INT
    DECLARE @MgrStartDate DATETIME

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

    INSERT INTO Department (DName, DNumber, MgrSSN, MgrStartDate)
    VALUES (@DName, @DNumber, @MgrSSN, @MgrStartDate)

    SELECT @DNumber AS 'DNumber'
END
GO

-- Procedure B:
CREATE PROCEDURE [dbo].usp_UpdateDepartmentName (
    @DNumber INT,
    @DName VARCHAR(50)
) AS
BEGIN
    IF EXISTS(SELECT * FROM Department WHERE DNumber = @DNumber)
        BEGIN
            IF EXISTS(SELECT * FROM Department WHERE DName = @DName)
                BEGIN
                    THROW 51000, 'Department name already exists.', 1
                END
            ELSE
                BEGIN
                    UPDATE Department SET DName = @DName WHERE DNumber = @DNumber
                    SELECT 'Department name updated successfully! :)' AS 'Message'
                END
        END
    ELSE
        BEGIN
            THROW 51000, 'Department number not found.', 1
        END
END
GO

-- Procedure C:
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

-- Procedure D:
CREATE PROCEDURE [dbo].usp_DeleteDepartment (@DNumber INT) AS
BEGIN
    IF EXISTS(SELECT * FROM Department WHERE DNumber = @DNumber)
        BEGIN
            DELETE FROM Department WHERE DNumber = @DNumber
            DELETE FROM Dept_Locations WHERE DNUmber = @DNumber
            DELETE FROM Project WHERE DNum = @DNumber
            DELETE FROM Works_on WHERE Pno IN (SELECT PNumber FROM Project WHERE DNum = @DNumber)

            UPDATE Employee SET Dno = NULL WHERE Dno = @DNumber

            SELECT 'Department deleted successfully! :)' AS 'Message'
        END
    ELSE
        BEGIN
            THROW 51000, 'Department number not found.', 1
        END
END
GO

-- Procedure E:
CREATE PROCEDURE [dbo].usp_GetDepartment (@DNumber INT) AS
BEGIN
    SELECT Department.*, COUNT(*) AS EmpCount
    FROM Department
        INNER JOIN Employee ON Department.DNumber = Employee.Dno
    WHERE Department.DNumber = @DNumber
    GROUP BY Department.DNumber, Department.DName, Department.MgrSSN, Department.MgrStartDate
END
GO

-- Procedure F:
CREATE PROCEDURE [dbo].usp_GetAllDepartments
AS
BEGIN
    SELECT d.*, COUNT(*) AS EmpCount
    FROM Department d
    LEFT JOIN Employee e ON d.DNumber = e.Dno
    GROUP BY d.DNumber, d.DName, d.MgrSSN, d.MgrStartDate
END
GO

