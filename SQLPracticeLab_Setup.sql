/*
================================================================================
SQLPracticeLab - SQL Server Practice Database
Version: 1.0
Purpose: Reusable dataset for daily SQL Server challenges.
Compatibility: SQL Server 2016+ (uses DROP/CREATE, DATEFROMPARTS-compatible syntax,
               window functions, and standard T-SQL).
IMPORTANT:
  - This is synthetic training data, not real banking/customer information.
  - Run the entire script in SSMS using SQLCMD mode OFF.
  - The script creates/recreates SQLPracticeLab. Existing database of that name
    will be dropped. Back up anything important before running.
================================================================================
*/

USE master;
GO

IF DB_ID(N'SQLPracticeLab') IS NOT NULL
BEGIN
    ALTER DATABASE SQLPracticeLab SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SQLPracticeLab;
END;
GO

CREATE DATABASE SQLPracticeLab;
GO

USE SQLPracticeLab;
GO

/*==============================================================================
  1. SCHEMAS
==============================================================================*/
CREATE SCHEMA Sales;
GO
CREATE SCHEMA Finance;
GO
CREATE SCHEMA HR;
GO
CREATE SCHEMA Inventory;
GO
CREATE SCHEMA ChallengeData;
GO

/*==============================================================================
  2. ORGANIZATION TABLES
==============================================================================*/
CREATE TABLE dbo.Branches
(
    BranchID       INT           NOT NULL CONSTRAINT PK_Branches PRIMARY KEY,
    BranchName     VARCHAR(100)  NOT NULL,
    City           VARCHAR(60)   NOT NULL,
    Province       VARCHAR(60)   NOT NULL,
    OpenDate       DATE          NOT NULL,
    IsActive       BIT           NOT NULL CONSTRAINT DF_Branches_IsActive DEFAULT (1),
    CONSTRAINT UQ_Branches_BranchName UNIQUE (BranchName)
);

CREATE TABLE HR.Departments
(
    DepartmentID   INT           NOT NULL CONSTRAINT PK_Departments PRIMARY KEY,
    DepartmentName VARCHAR(80)   NOT NULL CONSTRAINT UQ_Departments_Name UNIQUE
);

CREATE TABLE HR.Employees
(
    EmployeeID     INT            NOT NULL CONSTRAINT PK_Employees PRIMARY KEY,
    FirstName      VARCHAR(50)    NOT NULL,
    LastName       VARCHAR(50)    NOT NULL,
    Gender         VARCHAR(15)    NOT NULL,
    HireDate       DATE           NOT NULL,
    JobTitle       VARCHAR(80)    NOT NULL,
    Salary         DECIMAL(12,2)  NOT NULL,
    BranchID       INT            NOT NULL,
    DepartmentID   INT            NOT NULL,
    ManagerID      INT            NULL,
    EmploymentStatus VARCHAR(20)  NOT NULL,
    CONSTRAINT FK_Employees_Branches FOREIGN KEY (BranchID) REFERENCES dbo.Branches(BranchID),
    CONSTRAINT FK_Employees_Departments FOREIGN KEY (DepartmentID) REFERENCES HR.Departments(DepartmentID),
    CONSTRAINT FK_Employees_Manager FOREIGN KEY (ManagerID) REFERENCES HR.Employees(EmployeeID),
    CONSTRAINT CK_Employees_Gender CHECK (Gender IN ('Female','Male','Other')),
    CONSTRAINT CK_Employees_Salary CHECK (Salary > 0),
    CONSTRAINT CK_Employees_Status CHECK (EmploymentStatus IN ('Active','On Leave','Resigned'))
);

/*==============================================================================
  3. CUSTOMER AND FINANCE TABLES
==============================================================================*/
CREATE TABLE Sales.Customers
(
    CustomerID       INT            NOT NULL CONSTRAINT PK_Customers PRIMARY KEY,
    FirstName        VARCHAR(50)    NOT NULL,
    LastName         VARCHAR(50)    NOT NULL,
    Email            VARCHAR(150)   NOT NULL,
    Phone            VARCHAR(25)    NOT NULL,
    Gender           VARCHAR(15)    NOT NULL,
    DateOfBirth      DATE           NOT NULL,
    CustomerSince    DATE           NOT NULL,
    CustomerSegment  VARCHAR(30)    NOT NULL,
    City             VARCHAR(60)    NOT NULL,
    Province         VARCHAR(60)    NOT NULL,
    IsActive         BIT            NOT NULL,
    CONSTRAINT UQ_Customers_Email UNIQUE (Email),
    CONSTRAINT CK_Customers_Gender CHECK (Gender IN ('Female','Male','Other')),
    CONSTRAINT CK_Customers_Segment CHECK (CustomerSegment IN ('Retail','Small Business','Corporate','Premium'))
);

CREATE TABLE Sales.CustomerAddresses
(
    AddressID       INT            NOT NULL CONSTRAINT PK_CustomerAddresses PRIMARY KEY,
    CustomerID      INT            NOT NULL,
    AddressType     VARCHAR(20)    NOT NULL,
    StreetAddress   VARCHAR(200)   NOT NULL,
    City            VARCHAR(60)    NOT NULL,
    Province        VARCHAR(60)    NOT NULL,
    IsPrimary       BIT            NOT NULL,
    CONSTRAINT FK_CustomerAddresses_Customers FOREIGN KEY (CustomerID) REFERENCES Sales.Customers(CustomerID),
    CONSTRAINT CK_CustomerAddresses_Type CHECK (AddressType IN ('Home','Billing','Shipping','Office'))
);

CREATE TABLE Finance.Accounts
(
    AccountID       INT            NOT NULL CONSTRAINT PK_Accounts PRIMARY KEY,
    CustomerID      INT            NOT NULL,
    BranchID        INT            NOT NULL,
    AccountNumber   VARCHAR(24)    NOT NULL,
    AccountType     VARCHAR(25)    NOT NULL,
    OpenDate        DATE           NOT NULL,
    AccountStatus   VARCHAR(20)    NOT NULL,
    CurrentBalance  DECIMAL(15,2)  NOT NULL,
    CONSTRAINT UQ_Accounts_AccountNumber UNIQUE (AccountNumber),
    CONSTRAINT FK_Accounts_Customers FOREIGN KEY (CustomerID) REFERENCES Sales.Customers(CustomerID),
    CONSTRAINT FK_Accounts_Branches FOREIGN KEY (BranchID) REFERENCES dbo.Branches(BranchID),
    CONSTRAINT CK_Accounts_Type CHECK (AccountType IN ('Current','Savings','Business','Payroll')),
    CONSTRAINT CK_Accounts_Status CHECK (AccountStatus IN ('Active','Dormant','Frozen','Closed')),
    CONSTRAINT CK_Accounts_Balance CHECK (CurrentBalance >= 0)
);

CREATE TABLE Finance.Transactions
(
    TransactionID       INT            NOT NULL CONSTRAINT PK_Transactions PRIMARY KEY,
    AccountID           INT            NOT NULL,
    RelatedAccountID    INT            NULL,
    BranchID            INT            NOT NULL,
    TransactionType     VARCHAR(20)    NOT NULL,
    Amount              DECIMAL(15,2)  NOT NULL,
    TransactionDate     DATETIME2(0)   NOT NULL,
    TransactionStatus   VARCHAR(20)    NOT NULL,
    TransactionChannel  VARCHAR(20)    NOT NULL,
    ReferenceNumber     VARCHAR(30)    NOT NULL,
    CONSTRAINT FK_Transactions_Accounts FOREIGN KEY (AccountID) REFERENCES Finance.Accounts(AccountID),
    CONSTRAINT FK_Transactions_RelatedAccount FOREIGN KEY (RelatedAccountID) REFERENCES Finance.Accounts(AccountID),
    CONSTRAINT FK_Transactions_Branches FOREIGN KEY (BranchID) REFERENCES dbo.Branches(BranchID),
    CONSTRAINT CK_Transactions_Type CHECK (TransactionType IN ('DEPOSIT','WITHDRAWAL','TRANSFER_IN','TRANSFER_OUT','FEE','INTEREST')),
    CONSTRAINT CK_Transactions_Amount CHECK (Amount > 0),
    CONSTRAINT CK_Transactions_Status CHECK (TransactionStatus IN ('SUCCESS','FAILED','REVERSED','PENDING')),
    CONSTRAINT CK_Transactions_Channel CHECK (TransactionChannel IN ('Branch','ATM','Online','Mobile','POS'))
);

/*==============================================================================
  4. PRODUCT, SALES, SUPPLIER AND INVENTORY TABLES
==============================================================================*/
CREATE TABLE Inventory.Categories
(
    CategoryID      INT           NOT NULL CONSTRAINT PK_Categories PRIMARY KEY,
    CategoryName    VARCHAR(80)   NOT NULL CONSTRAINT UQ_Categories_Name UNIQUE
);

CREATE TABLE Inventory.Suppliers
(
    SupplierID      INT           NOT NULL CONSTRAINT PK_Suppliers PRIMARY KEY,
    SupplierName    VARCHAR(120)  NOT NULL,
    City            VARCHAR(60)   NOT NULL,
    Province        VARCHAR(60)   NOT NULL,
    ContactEmail    VARCHAR(150)  NOT NULL,
    IsActive        BIT           NOT NULL,
    CONSTRAINT UQ_Suppliers_Email UNIQUE (ContactEmail)
);

CREATE TABLE Inventory.Products
(
    ProductID       INT            NOT NULL CONSTRAINT PK_Products PRIMARY KEY,
    ProductName     VARCHAR(120)   NOT NULL,
    CategoryID      INT            NOT NULL,
    SupplierID      INT            NOT NULL,
    UnitPrice       DECIMAL(12,2)  NOT NULL,
    UnitCost        DECIMAL(12,2)  NOT NULL,
    ProductStatus   VARCHAR(20)    NOT NULL,
    CreatedDate     DATE           NOT NULL,
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID) REFERENCES Inventory.Categories(CategoryID),
    CONSTRAINT FK_Products_Suppliers FOREIGN KEY (SupplierID) REFERENCES Inventory.Suppliers(SupplierID),
    CONSTRAINT CK_Products_Price CHECK (UnitPrice > 0),
    CONSTRAINT CK_Products_Cost CHECK (UnitCost >= 0),
    CONSTRAINT CK_Products_Status CHECK (ProductStatus IN ('Active','Discontinued'))
);

CREATE TABLE Sales.Orders
(
    OrderID         INT            NOT NULL CONSTRAINT PK_Orders PRIMARY KEY,
    CustomerID      INT            NOT NULL,
    BranchID        INT            NOT NULL,
    EmployeeID      INT            NOT NULL,
    OrderDate       DATETIME2(0)   NOT NULL,
    OrderStatus     VARCHAR(20)    NOT NULL,
    OrderTotal      DECIMAL(14,2)  NOT NULL,
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES Sales.Customers(CustomerID),
    CONSTRAINT FK_Orders_Branches FOREIGN KEY (BranchID) REFERENCES dbo.Branches(BranchID),
    CONSTRAINT FK_Orders_Employees FOREIGN KEY (EmployeeID) REFERENCES HR.Employees(EmployeeID),
    CONSTRAINT CK_Orders_Status CHECK (OrderStatus IN ('Completed','Pending','Cancelled','Returned','Processing')),
    CONSTRAINT CK_Orders_Total CHECK (OrderTotal >= 0)
);

CREATE TABLE Sales.OrderItems
(
    OrderItemID     INT            NOT NULL CONSTRAINT PK_OrderItems PRIMARY KEY,
    OrderID         INT            NOT NULL,
    ProductID       INT            NOT NULL,
    Quantity        INT            NOT NULL,
    UnitPrice       DECIMAL(12,2)  NOT NULL,
    DiscountPct     DECIMAL(5,2)   NOT NULL CONSTRAINT DF_OrderItems_Discount DEFAULT (0),
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderID) REFERENCES Sales.Orders(OrderID),
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductID) REFERENCES Inventory.Products(ProductID),
    CONSTRAINT CK_OrderItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_OrderItems_UnitPrice CHECK (UnitPrice > 0),
    CONSTRAINT CK_OrderItems_Discount CHECK (DiscountPct >= 0 AND DiscountPct <= 100)
);

CREATE TABLE Sales.Payments
(
    PaymentID       INT            NOT NULL CONSTRAINT PK_Payments PRIMARY KEY,
    OrderID         INT            NOT NULL,
    PaymentDate     DATETIME2(0)   NOT NULL,
    PaymentAmount   DECIMAL(14,2)  NOT NULL,
    PaymentMethod   VARCHAR(25)    NOT NULL,
    PaymentStatus   VARCHAR(20)    NOT NULL,
    TransactionRef VARCHAR(40)    NOT NULL,
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (OrderID) REFERENCES Sales.Orders(OrderID),
    CONSTRAINT CK_Payments_Amount CHECK (PaymentAmount >= 0),
    CONSTRAINT CK_Payments_Method CHECK (PaymentMethod IN ('Cash','Card','Bank Transfer','Mobile Wallet')),
    CONSTRAINT CK_Payments_Status CHECK (PaymentStatus IN ('Successful','Failed','Refunded','Pending')),
    CONSTRAINT UQ_Payments_Reference UNIQUE (TransactionRef)
);

CREATE TABLE Inventory.Inventory
(
    BranchID        INT NOT NULL,
    ProductID       INT NOT NULL,
    QuantityOnHand  INT NOT NULL,
    ReorderLevel    INT NOT NULL,
    LastUpdated     DATE NOT NULL,
    CONSTRAINT PK_Inventory PRIMARY KEY (BranchID, ProductID),
    CONSTRAINT FK_Inventory_Branches FOREIGN KEY (BranchID) REFERENCES dbo.Branches(BranchID),
    CONSTRAINT FK_Inventory_Products FOREIGN KEY (ProductID) REFERENCES Inventory.Products(ProductID),
    CONSTRAINT CK_Inventory_Quantity CHECK (QuantityOnHand >= 0),
    CONSTRAINT CK_Inventory_Reorder CHECK (ReorderLevel >= 0)
);

CREATE TABLE Inventory.StockMovements
(
    StockMovementID INT           NOT NULL CONSTRAINT PK_StockMovements PRIMARY KEY,
    BranchID        INT           NOT NULL,
    ProductID       INT           NOT NULL,
    MovementType    VARCHAR(20)   NOT NULL,
    Quantity        INT           NOT NULL,
    MovementDate    DATETIME2(0)  NOT NULL,
    ReferenceNo     VARCHAR(30)   NOT NULL,
    CONSTRAINT FK_StockMovements_Branches FOREIGN KEY (BranchID) REFERENCES dbo.Branches(BranchID),
    CONSTRAINT FK_StockMovements_Products FOREIGN KEY (ProductID) REFERENCES Inventory.Products(ProductID),
    CONSTRAINT CK_StockMovements_Type CHECK (MovementType IN ('IN','OUT','ADJUSTMENT','TRANSFER_IN','TRANSFER_OUT')),
    CONSTRAINT CK_StockMovements_Quantity CHECK (Quantity > 0)
);

/*==============================================================================
  5. SEED REFERENCE DATA
==============================================================================*/
INSERT INTO dbo.Branches (BranchID, BranchName, City, Province, OpenDate, IsActive)
VALUES
(1,'Karachi Main','Karachi','Sindh','2010-01-15',1),
(2,'Lahore Central','Lahore','Punjab','2011-03-10',1),
(3,'Islamabad Blue Area','Islamabad','ICT','2012-06-01',1),
(4,'Karachi Clifton','Karachi','Sindh','2013-02-20',1),
(5,'Rawalpindi Saddar','Rawalpindi','Punjab','2014-08-12',1),
(6,'Faisalabad Center','Faisalabad','Punjab','2015-04-18',1),
(7,'Multan Cantt','Multan','Punjab','2016-09-05',1),
(8,'Peshawar University Road','Peshawar','Khyber Pakhtunkhwa','2017-01-22',1),
(9,'Quetta City','Quetta','Balochistan','2018-05-14',1),
(10,'Hyderabad Main','Hyderabad','Sindh','2019-07-30',1),
(11,'Sialkot Business','Sialkot','Punjab','2020-02-11',1),
(12,'Gujranwala City','Gujranwala','Punjab','2021-11-01',0);

INSERT INTO HR.Departments (DepartmentID, DepartmentName)
VALUES
(1,'Sales'),(2,'Finance'),(3,'Customer Service'),(4,'Operations'),
(5,'Human Resources'),(6,'Information Technology'),(7,'Inventory'),(8,'Management');

INSERT INTO Inventory.Categories (CategoryID, CategoryName)
VALUES
(1,'Electronics'),(2,'Home Appliances'),(3,'Furniture'),(4,'Clothing'),(5,'Footwear'),
(6,'Groceries'),(7,'Personal Care'),(8,'Sports'),(9,'Books'),(10,'Stationery'),
(11,'Accessories'),(12,'Kitchenware'),(13,'Toys'),(14,'Automotive'),(15,'Office Equipment');

/*==============================================================================
  6. GENERATE SYNTHETIC DATA
  All generated data is deterministic and uses fixed date ranges.
==============================================================================*/

-- 50 suppliers
;WITH N AS
(
    SELECT TOP (50) CONVERT(INT, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO Inventory.Suppliers
    (SupplierID, SupplierName, City, Province, ContactEmail, IsActive)
SELECT
    n,
    CONCAT('Supplier ', RIGHT(CONCAT('000',n),3)),
    CASE n % 8
        WHEN 0 THEN 'Karachi' WHEN 1 THEN 'Lahore' WHEN 2 THEN 'Islamabad'
        WHEN 3 THEN 'Rawalpindi' WHEN 4 THEN 'Faisalabad' WHEN 5 THEN 'Multan'
        WHEN 6 THEN 'Peshawar' ELSE 'Hyderabad' END,
    CASE n % 8
        WHEN 0 THEN 'Sindh' WHEN 1 THEN 'Punjab' WHEN 2 THEN 'ICT'
        WHEN 3 THEN 'Punjab' WHEN 4 THEN 'Punjab' WHEN 5 THEN 'Punjab'
        WHEN 6 THEN 'Khyber Pakhtunkhwa' ELSE 'Sindh' END,
    CONCAT('supplier',n,'@example.com'),
    CASE WHEN n % 13 = 0 THEN 0 ELSE 1 END
FROM N;

-- 120 employees
;WITH N AS
(
    SELECT TOP (120) CONVERT(INT, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO HR.Employees
    (EmployeeID, FirstName, LastName, Gender, HireDate, JobTitle, Salary,
     BranchID, DepartmentID, ManagerID, EmploymentStatus)
SELECT
    n,
    CONCAT('Employee',n),
    CONCAT('Surname',((n * 7) % 97) + 1),
    CASE WHEN n % 2 = 0 THEN 'Female' ELSE 'Male' END,
    DATEADD(DAY, -(n * 11) % 2500, CAST('2026-12-31' AS DATE)),
    CASE n % 6 WHEN 0 THEN 'Branch Manager' WHEN 1 THEN 'Analyst'
        WHEN 2 THEN 'Sales Officer' WHEN 3 THEN 'Customer Officer'
        WHEN 4 THEN 'Operations Officer' ELSE 'Associate' END,
    CAST(45000 + ((n * 1733) % 155000) AS DECIMAL(12,2)),
    ((n - 1) % 12) + 1,
    ((n - 1) % 8) + 1,
    NULL,
    CASE WHEN n % 19 = 0 THEN 'Resigned'
         WHEN n % 17 = 0 THEN 'On Leave' ELSE 'Active' END
FROM N;

UPDATE HR.Employees
SET ManagerID = CASE WHEN EmployeeID > 10 THEN ((EmployeeID - 1) % 10) + 1 ELSE NULL END;

-- 2,000 customers
;WITH N AS
(
    SELECT TOP (2000) CONVERT(INT, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO Sales.Customers
    (CustomerID, FirstName, LastName, Email, Phone, Gender, DateOfBirth,
     CustomerSince, CustomerSegment, City, Province, IsActive)
SELECT
    n,
    CONCAT('Customer',n),
    CONCAT('Family',((n * 13) % 499) + 1),
    CONCAT('customer',n,'@example.com'),
    CONCAT('03',RIGHT(CONCAT('000000000',n),9)),
    CASE n % 2 WHEN 0 THEN 'Female' ELSE 'Male' END,
    DATEADD(DAY, -(7000 + ((n * 19) % 18000)), CAST('2026-12-31' AS DATE)),
    DATEADD(DAY, -((n * 17) % 1400), CAST('2026-12-31' AS DATE)),
    CASE n % 20 WHEN 0 THEN 'Corporate' WHEN 1 THEN 'Small Business'
        WHEN 2 THEN 'Premium' ELSE 'Retail' END,
    CASE n % 8 WHEN 0 THEN 'Karachi' WHEN 1 THEN 'Lahore'
        WHEN 2 THEN 'Islamabad' WHEN 3 THEN 'Rawalpindi'
        WHEN 4 THEN 'Faisalabad' WHEN 5 THEN 'Multan'
        WHEN 6 THEN 'Peshawar' ELSE 'Hyderabad' END,
    CASE n % 8 WHEN 0 THEN 'Sindh' WHEN 1 THEN 'Punjab'
        WHEN 2 THEN 'ICT' WHEN 3 THEN 'Punjab'
        WHEN 4 THEN 'Punjab' WHEN 5 THEN 'Punjab'
        WHEN 6 THEN 'Khyber Pakhtunkhwa' ELSE 'Sindh' END,
    CASE WHEN n % 23 = 0 THEN 0 ELSE 1 END
FROM N;

-- 2,500 customer addresses (some customers have more than one)
;WITH N AS
(
    SELECT TOP (2500) CONVERT(INT, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO Sales.CustomerAddresses
    (AddressID, CustomerID, AddressType, StreetAddress, City, Province, IsPrimary)
SELECT
    n,
    ((n - 1) % 2000) + 1,
    CASE WHEN n % 3 = 0 THEN 'Billing' WHEN n % 3 = 1 THEN 'Home' ELSE 'Office' END,
    CONCAT('House ',n,', Street ',(n % 40) + 1),
    CASE n % 8 WHEN 0 THEN 'Karachi' WHEN 1 THEN 'Lahore'
        WHEN 2 THEN 'Islamabad' WHEN 3 THEN 'Rawalpindi'
        WHEN 4 THEN 'Faisalabad' WHEN 5 THEN 'Multan'
        WHEN 6 THEN 'Peshawar' ELSE 'Hyderabad' END,
    CASE n % 8 WHEN 0 THEN 'Sindh' WHEN 1 THEN 'Punjab'
        WHEN 2 THEN 'ICT' WHEN 3 THEN 'Punjab'
        WHEN 4 THEN 'Punjab' WHEN 5 THEN 'Punjab'
        WHEN 6 THEN 'Khyber Pakhtunkhwa' ELSE 'Sindh' END,
    CASE WHEN n <= 2000 THEN 1 ELSE 0 END
FROM N;

-- 250 products
;WITH N AS
(
    SELECT TOP (250) CONVERT(INT, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO Inventory.Products
    (ProductID, ProductName, CategoryID, SupplierID, UnitPrice, UnitCost, ProductStatus, CreatedDate)
SELECT
    n,
    CONCAT('Product ',RIGHT(CONCAT('000',n),3)),
    ((n - 1) % 15) + 1,
    ((n - 1) % 50) + 1,
    CAST(500 + ((n * 379) % 45000) AS DECIMAL(12,2)),
    CAST(250 + ((n * 211) % 30000) AS DECIMAL(12,2)),
    CASE WHEN n % 29 = 0 THEN 'Discontinued' ELSE 'Active' END,
    DATEADD(DAY, -(n * 5) % 1200, CAST('2026-12-31' AS DATE))
FROM N;

-- 2,500 accounts
;WITH N AS
(
    SELECT TOP (2500) CONVERT(INT, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO Finance.Accounts
    (AccountID, CustomerID, BranchID, AccountNumber, AccountType, OpenDate, AccountStatus, CurrentBalance)
SELECT
    n,
    ((n - 1) % 2000) + 1,
    ((n - 1) % 12) + 1,
    CONCAT('AC',RIGHT(CONCAT('00000000',n),8)),
    CASE n % 4 WHEN 0 THEN 'Current' WHEN 1 THEN 'Savings'
        WHEN 2 THEN 'Business' ELSE 'Payroll' END,
    DATEADD(DAY, -(n * 7) % 1400, CAST('2026-12-31' AS DATE)),
    CASE WHEN n % 37 = 0 THEN 'Frozen'
         WHEN n % 31 = 0 THEN 'Dormant'
         WHEN n % 41 = 0 THEN 'Closed' ELSE 'Active' END,
    CAST((n * 791) % 900000 AS DECIMAL(15,2))
FROM N;

-- 15,000 financial transactions
;WITH N AS
(
    SELECT TOP (15000) CONVERT(INT, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO Finance.Transactions
    (TransactionID, AccountID, RelatedAccountID, BranchID, TransactionType,
     Amount, TransactionDate, TransactionStatus, TransactionChannel, ReferenceNumber)
SELECT
    n,
    ((n - 1) % 2500) + 1,
    CASE WHEN n % 5 = 0 THEN ((n + 16) % 2500) + 1 ELSE NULL END,
    ((n - 1) % 12) + 1,
    CASE n % 6 WHEN 0 THEN 'DEPOSIT' WHEN 1 THEN 'WITHDRAWAL'
        WHEN 2 THEN 'TRANSFER_IN' WHEN 3 THEN 'TRANSFER_OUT'
        WHEN 4 THEN 'FEE' ELSE 'INTEREST' END,
    CAST(100 + ((n * 137) % 150000) AS DECIMAL(15,2)),
    DATEADD(MINUTE, (n * 37) % 1440, DATEADD(DAY, n % 1095, CAST('2024-01-01' AS DATETIME2(0)))),
    CASE WHEN n % 29 = 0 THEN 'FAILED'
         WHEN n % 43 = 0 THEN 'REVERSED'
         WHEN n % 47 = 0 THEN 'PENDING' ELSE 'SUCCESS' END,
    CASE n % 5 WHEN 0 THEN 'Branch' WHEN 1 THEN 'ATM'
        WHEN 2 THEN 'Online' WHEN 3 THEN 'Mobile' ELSE 'POS' END,
    CONCAT('TXN-',RIGHT(CONCAT('00000000',n),8))
FROM N;

-- 5,000 orders
;WITH N AS
(
    SELECT TOP (5000) CONVERT(INT, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO Sales.Orders
    (OrderID, CustomerID, BranchID, EmployeeID, OrderDate, OrderStatus, OrderTotal)
SELECT
    n,
    ((n - 1) % 2000) + 1,
    ((n - 1) % 12) + 1,
    ((n - 1) % 120) + 1,
    DATEADD(MINUTE, (n * 53) % 1440, DATEADD(DAY, n % 1095, CAST('2024-01-01' AS DATETIME2(0)))),
    CASE WHEN n % 23 = 0 THEN 'Cancelled'
         WHEN n % 19 = 0 THEN 'Returned'
         WHEN n % 13 = 0 THEN 'Pending'
         WHEN n % 11 = 0 THEN 'Processing'
         ELSE 'Completed' END,
    CAST(1500 + ((n * 887) % 95000) AS DECIMAL(14,2))
FROM N;

-- 12,000 order items
;WITH N AS
(
    SELECT TOP (12000) CONVERT(INT, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO Sales.OrderItems
    (OrderItemID, OrderID, ProductID, Quantity, UnitPrice, DiscountPct)
SELECT
    n,
    ((n - 1) % 5000) + 1,
    p.ProductID,
    (n % 5) + 1,
    p.UnitPrice,
    CAST((n % 6) * 2.5 AS DECIMAL(5,2))
FROM N
JOIN Inventory.Products p
  ON p.ProductID = ((n * 7 - 1) % 250) + 1;

-- 5,000 payments, one payment record per order
INSERT INTO Sales.Payments
    (PaymentID, OrderID, PaymentDate, PaymentAmount, PaymentMethod, PaymentStatus, TransactionRef)
SELECT
    o.OrderID,
    o.OrderID,
    DATEADD(DAY, 1 + (o.OrderID % 5), o.OrderDate),
    o.OrderTotal,
    CASE o.OrderID % 4 WHEN 0 THEN 'Cash' WHEN 1 THEN 'Card'
        WHEN 2 THEN 'Bank Transfer' ELSE 'Mobile Wallet' END,
    CASE WHEN o.OrderID % 31 = 0 THEN 'Failed'
         WHEN o.OrderID % 37 = 0 THEN 'Pending'
         WHEN o.OrderID % 41 = 0 THEN 'Refunded'
         ELSE 'Successful' END,
    CONCAT('PAY-',RIGHT(CONCAT('00000000',o.OrderID),8))
FROM Sales.Orders o;

-- 3,000 inventory rows (12 branches x 250 products)
INSERT INTO Inventory.Inventory
    (BranchID, ProductID, QuantityOnHand, ReorderLevel, LastUpdated)
SELECT
    b.BranchID,
    p.ProductID,
    (b.BranchID * 17 + p.ProductID * 11) % 250,
    15 + (p.ProductID % 35),
    CAST('2026-12-31' AS DATE)
FROM dbo.Branches b
CROSS JOIN Inventory.Products p;

-- 8,000 stock movements
;WITH N AS
(
    SELECT TOP (8000) CONVERT(INT, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO Inventory.StockMovements
    (StockMovementID, BranchID, ProductID, MovementType, Quantity, MovementDate, ReferenceNo)
SELECT
    n,
    ((n - 1) % 12) + 1,
    ((n * 13 - 1) % 250) + 1,
    CASE n % 5 WHEN 0 THEN 'IN' WHEN 1 THEN 'OUT'
        WHEN 2 THEN 'ADJUSTMENT' WHEN 3 THEN 'TRANSFER_IN' ELSE 'TRANSFER_OUT' END,
    (n % 40) + 1,
    DATEADD(HOUR, n * 5, CAST('2024-01-01' AS DATETIME2(0))),
    CONCAT('STK-',RIGHT(CONCAT('00000000',n),8))
FROM N;

/*==============================================================================
  7. ISOLATED DATASET FOR DAILY CHALLENGE #01
  This preserves the exact three-branch scenario and expected answer already
  provided. Use ChallengeData schema for Challenge #01.
==============================================================================*/
CREATE TABLE ChallengeData.Branches
(
    BranchID INT NOT NULL PRIMARY KEY,
    BranchName VARCHAR(100) NOT NULL
);

CREATE TABLE ChallengeData.Accounts
(
    AccountID INT NOT NULL PRIMARY KEY,
    BranchID INT NOT NULL,
    CONSTRAINT FK_ChallengeAccounts_Branches FOREIGN KEY (BranchID)
        REFERENCES ChallengeData.Branches(BranchID)
);

CREATE TABLE ChallengeData.Transactions
(
    TransactionID INT NOT NULL PRIMARY KEY,
    AccountID INT NOT NULL,
    TransactionType VARCHAR(20) NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
    TransactionDate DATE NOT NULL,
    Status VARCHAR(20) NOT NULL,
    CONSTRAINT FK_ChallengeTransactions_Accounts FOREIGN KEY (AccountID)
        REFERENCES ChallengeData.Accounts(AccountID)
);

INSERT INTO ChallengeData.Branches VALUES
(1,'Karachi Main'),
(2,'Lahore Central'),
(3,'Islamabad Blue Area');

INSERT INTO ChallengeData.Accounts VALUES
(101,1),
(102,1),
(201,2),
(301,3);

INSERT INTO ChallengeData.Transactions VALUES
(1,101,'DEPOSIT',10000,'2026-10-02','SUCCESS'),
(2,101,'WITHDRAWAL',2500,'2026-10-03','SUCCESS'),
(3,102,'DEPOSIT',20000,'2026-10-10','SUCCESS'),
(4,102,'DEPOSIT',5000,'2026-10-11','FAILED'),
(5,201,'DEPOSIT',15000,'2026-10-12','SUCCESS'),
(6,201,'WITHDRAWAL',4000,'2026-10-13','REVERSED'),
(7,201,'WITHDRAWAL',3000,'2026-10-14','SUCCESS'),
(8,301,'DEPOSIT',7000,'2026-09-30','SUCCESS'),
(9,101,'DEPOSIT',6000,'2026-10-31','SUCCESS');

/*==============================================================================
  8. INDEXES
  A few useful baseline indexes are included. More will be added as exercises.
==============================================================================*/
CREATE INDEX IX_Employees_Branch_Department
    ON HR.Employees(BranchID, DepartmentID);

CREATE INDEX IX_Customers_City_Segment
    ON Sales.Customers(City, CustomerSegment);

CREATE INDEX IX_Accounts_Customer_Status
    ON Finance.Accounts(CustomerID, AccountStatus);

CREATE INDEX IX_Transactions_Account_Date
    ON Finance.Transactions(AccountID, TransactionDate)
    INCLUDE (TransactionType, Amount, TransactionStatus);

CREATE INDEX IX_Transactions_Status_Date
    ON Finance.Transactions(TransactionStatus, TransactionDate);

CREATE INDEX IX_Orders_Customer_Date
    ON Sales.Orders(CustomerID, OrderDate)
    INCLUDE (OrderStatus, OrderTotal);

CREATE INDEX IX_Orders_Branch_Date
    ON Sales.Orders(BranchID, OrderDate);

CREATE INDEX IX_OrderItems_Order
    ON Sales.OrderItems(OrderID)
    INCLUDE (ProductID, Quantity, UnitPrice, DiscountPct);

CREATE INDEX IX_Payments_Order_Status
    ON Sales.Payments(OrderID, PaymentStatus);

/*==============================================================================
  9. VALIDATION QUERIES
  Run these after successful execution to verify row counts and relationships.
==============================================================================*/
SELECT 'Branches' AS TableName, COUNT_BIG(*) AS RowCount FROM dbo.Branches
UNION ALL SELECT 'Departments', COUNT_BIG(*) FROM HR.Departments
UNION ALL SELECT 'Employees', COUNT_BIG(*) FROM HR.Employees
UNION ALL SELECT 'Customers', COUNT_BIG(*) FROM Sales.Customers
UNION ALL SELECT 'CustomerAddresses', COUNT_BIG(*) FROM Sales.CustomerAddresses
UNION ALL SELECT 'Accounts', COUNT_BIG(*) FROM Finance.Accounts
UNION ALL SELECT 'Transactions', COUNT_BIG(*) FROM Finance.Transactions
UNION ALL SELECT 'Categories', COUNT_BIG(*) FROM Inventory.Categories
UNION ALL SELECT 'Suppliers', COUNT_BIG(*) FROM Inventory.Suppliers
UNION ALL SELECT 'Products', COUNT_BIG(*) FROM Inventory.Products
UNION ALL SELECT 'Orders', COUNT_BIG(*) FROM Sales.Orders
UNION ALL SELECT 'OrderItems', COUNT_BIG(*) FROM Sales.OrderItems
UNION ALL SELECT 'Payments', COUNT_BIG(*) FROM Sales.Payments
UNION ALL SELECT 'Inventory', COUNT_BIG(*) FROM Inventory.Inventory
UNION ALL SELECT 'StockMovements', COUNT_BIG(*) FROM Inventory.StockMovements
UNION ALL SELECT 'ChallengeData.Branches', COUNT_BIG(*) FROM ChallengeData.Branches
UNION ALL SELECT 'ChallengeData.Accounts', COUNT_BIG(*) FROM ChallengeData.Accounts
UNION ALL SELECT 'ChallengeData.Transactions', COUNT_BIG(*) FROM ChallengeData.Transactions
ORDER BY TableName;

-- Basic orphan checks: each query should return zero.
SELECT COUNT(*) AS OrphanTransactions
FROM Finance.Transactions t
LEFT JOIN Finance.Accounts a ON a.AccountID = t.AccountID
WHERE a.AccountID IS NULL;

SELECT COUNT(*) AS OrphanOrderItems
FROM Sales.OrderItems oi
LEFT JOIN Sales.Orders o ON o.OrderID = oi.OrderID
WHERE o.OrderID IS NULL;

PRINT 'SQLPracticeLab setup and seed data completed.';
GO
