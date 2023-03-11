-- EXAMPLE PROCEDURE
CREATE PROCEDURE USP_Example
(
    @Dnumber INT,
    @EmpCount INT OUTPUT
)
    AS
BEGIN
SELECT @EmpCount = COUNT(*)
FROM Employee
WHERE Dno= @Dnumber;
END

-- PROCEDURES TODO: following
-- CREATE PROCEDURE usp_CreateDepartment(DName, MgrSSN)
-- CREATE PROCEDURE usp_UpdateDepartmentName(DNumber, DName)
-- CREATE PROCEDURE usp_UpdateDepartmentManager(DNumber, MgrSSN)
-- CREATE PROCEDURE usp_DeleteDepartment(DNumber)
-- CREATE PROCEDURE usp_GetDepartment(DNumber)
-- CREATE PROCEDURE usp_GetAllDepartments


