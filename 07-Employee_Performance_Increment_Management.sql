/* SQLPracticeLab – Challenge 7
Employee Performance Increment Management

1. Business scenario
An organization wants to automate annual salary increments based on employee performance.

The HR department needs a stored procedure that:
- Selects eligible employees based on department and performance rating.
- Applies a salary increment.
- Prevents the same employee from receiving the increment twice.
- Returns the old and updated salary for every affected employee.*/

CREATE OR ALTER PROCEDURE pcd_EmployeePerformanceIncrementManagement
@DepartmentName VARCHAR (50),
@MinimumRating INT(3),
@IncrementPercent FLOAT(3, 2)

AS BEGIN
IF @MinimumRating < 0 OR @MinimumRating > 5 
BEGIN
THROW 50001, 'Minimum Rating number is invalid. It should be between 0 and 5', 1;
ELSE IF @IncrementPercent < 0 OR @IncrementPercent > 20
THROW 50002, 'Increment Percent value is invalid. It should be between 0 and 20;, 2';
END;

SELECT e.FirstName + ' ' + e.LastName AS Employee_Name,
d.DepartmentName,
e.JobTitle,
e.Salary * @IncrementPercent 

-- THis is the next code--
