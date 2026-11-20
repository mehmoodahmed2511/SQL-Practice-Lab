-- SQL Challenge #05 — Monthly Invoice & Collection Reporting

-- Business scenario:
-- A company wants to generate monthly invoice and payment collection reports.

-- The finance team needs a reusable database procedure that can:
-- Generate reports for any selected date range.
-- Calculate total invoices and collected amounts.
-- Identify outstanding payments.
-- Optionally generate a report for a specific customer.
-- Instead of rewriting the same SQL query every month, management wants one reusable stored procedure.

CREATE TABLE dbo.SQLChallenge05_Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

CREATE TABLE dbo.SQLChallenge05_Invoices
(
    InvoiceID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY
        REFERENCES dbo.SQLChallenge05_Customers(CustomerID),
    InvoiceDate DATE,
    Amount DECIMAL(12,2),
    InvoiceStatus VARCHAR(20)
);

INSERT INTO dbo.SQLChallenge05_Customers
VALUES
(101, 'Aster Supplies'),
(102, 'BluePeak Retail'),
(103, 'Cedar Logistics'),
(104, 'Delta Services');

INSERT INTO dbo.SQLChallenge05_Invoices
VALUES
(5001, 101, '2026-01-05', 1000, 'Paid'),
(5002, 101, '2026-01-20', 500, 'Pending'),
(5003, 102, '2026-01-10', 750, 'Paid'),
(5004, 102, '2026-02-02', 900, 'Paid'),
(5005, 103, '2026-01-15', 300, 'Overdue'),
(5006, 104, '2026-01-25', 1200, 'Paid'),
(5007, 104, '2026-02-05', 400, 'Pending');

-- Below is the stored procedure
