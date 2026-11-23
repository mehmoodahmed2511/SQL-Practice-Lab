CREATE TABLE Finance.ExpenseClaims (

ClaimID INT NOT NULL CONSTRAINT PK_ExpenseClaims PRIMARY KEY,
DepartmentID INT NOT NULL,
ExpenseDate DATE NOT NULL,
ClaimAmount DECIMAL(12, 2) NOT NULL,
Status VARCHAR(20) NOT NULL,

CONSTRAINT FK_ExpenseClaims_Departments FOREIGN KEY(DepartmentID) REFERENCES HR.Departments (DepartmentID),
CONSTRAINT CK_ExpenseClaims_Amount CHECK(ClaimAmount > 0),
CONSTRAINT CK_ExpenseClaims_Status CHECK(Status IN('Approved', 'Pending', 'Rejected'))
);

INSERT INTO Finance.ExpenseClaims
(ClaimID, DepartmentID, ExpenseDate, ClaimAmount, Status)
VALUES
(1001, 1, '20260105', 12000, 'Approved'),
(1002, 1, '20260122', 8000, 'Approved'),
(1003, 1, '20260210', 5000, 'Pending'),
(1004, 2, '20260115', 25000, 'Approved'),
(1005, 2, '20260203', 10000, 'Approved'),
(1006, 2, '20260218', 5000, 'Rejected'),
(1007, 3, '20260211', 7000, 'Approved'),
(1008, 3, '20260220', 3000, 'Approved');


/* Challenge 6 – Department Expense Reporting System
Business scenario:
A company wants to monitor its monthly expenses across its departments. The finance team wants a reusable SQL 
view that displays approved expenses, total claims, and average claim amounts for each department, month by month.

Instead of writing the same aggregation query repeatedly, you need to create a database view. */

CREATE OR ALTER VIEW vw_DepartmentExpenseReportingSystem AS
SELECT 
d.DepartmentName,
DATENAME(MONTH, e.ExpenseDate) AS Month,
DATENAME(YEAR, e.ExpenseDate) AS Year,
COUNT(DISTINCT e.ClaimID) AS Total_Claims,
COUNT(e.Status) AS ApprovedExpenses,
AVG(e.ClaimAmount) AS Avg_Claim_Amount
FROM Finance.ExpenseClaims e LEFT JOIN HR.Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentID, d.DepartmentName, DATENAME(MONTH, e.ExpenseDate), DATENAME(YEAR, e.ExpenseDate);

SELECT * FROM vw_DepartmentExpenseReportingSystem ORDER BY Month DESC;