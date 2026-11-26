CREATE TABLE dbo.Employees
(
    EmployeeID INT PRIMARY KEY,
    EmployeeName NVARCHAR(50) NOT NULL,
    DepartmentID INT NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    PerformanceRating TINYINT NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IncrementApplied BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES HR.Departments(DepartmentID),

    CONSTRAINT CK_Employees_PerformanceRating
        CHECK (PerformanceRating BETWEEN 1 AND 5),

    CONSTRAINT CK_Employees_Salary
        CHECK (Salary > 0)
);

INSERT INTO dbo.Employees
(
    EmployeeID,
    EmployeeName,
    DepartmentID,
    Salary,
    PerformanceRating,
    IsActive,
    IncrementApplied
)
VALUES
(1, 'Areeba', 1, 80000, 5, 1, 0),
(2, 'Bilal', 1, 60000, 4, 1, 0),
(3, 'Hina', 6, 90000, 5, 1, 0),
(4, 'Kamran', 1, 50000, 3, 1, 0),
(5, 'Zoya', 1, 70000, 5, 0, 0);

/* SQLPracticeLab – Challenge 7
Employee Performance Increment Management

1. Business scenario
An organization wants to automate annual salary increments based on employee performance.

The HR department needs a stored procedure that:
- Selects eligible employees based on department and performance rating.
- Applies a salary increment.
- Prevents the same employee from receiving the increment twice.
- Returns the old and updated salary for every affected employee.*/


SELECT e.EmployeeName, e.Salary, d.DepartmentName FROM dbo.Employees e INNER JOIN HR.Departments d ON e.DepartmentID = d.DepartmentID;
SELECT * FROM dbo.Employees;

CREATE OR ALTER PROCEDURE DepartmentSalaryIncrementSystem
@DepartmentName VARCHAR,
@MinimumRating INT(2),
@IncrementPercent FLOAT(5, 2)

AS BEGIN

SET NOCOUNT ON;

IF @Department IS NULL OR LTRIM(RTRIM(@DepartmentName) = ''
BEGIN
THROW 50001, 'Department name cannot be null', 1;
END;

IF @MinimumRating IS NULL OR @MinimumRating NOT BETWEEN 1 AND 5
BEGIN
THROW 50002, 'Minimum Rating should be between 1 and 5', 1;
END;

IF @IncrementPercent IS NULL OR @IncrementPercent <= 0 OR @IncrementPercent > 20
BEGIN
THROW 50003, 'Increment Percentage should be between 1 and 20', 1;
END;