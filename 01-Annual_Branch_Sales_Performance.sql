-- SQL  - Day 1 --

-- Business scenario: Annual Branch Sales Performance
-- A company wants to evaluate the sales performance of all its branches during 2025. The management team wants to identify how many completed orders each branch received, how many unique customers purchased from each branch, and how much revenue each branch generated.

-- Your task: Write a SQL query to generate an annual branch performance report. --

SELECT b.BranchID, b.BranchName, COUNT(o.OrderStatus) AS CompletedOrders, SUM(o.OrderTotal) AS Revenue, COUNT(DISTINCT o.CustomerID) AS UniqueCustomers, AVG(o.OrderTotal) AS Avg_Order_Value FROM dbo.Branches b LEFT JOIN Sales.Orders o ON b.BranchID = o.BranchID WHERE o.OrderStatus = 'Completed' AND o.OrderDate BETWEEN '2025-01-01' AND '2025-12-31' GROUP BY b.BranchName, b.BranchID ORDER BY b.BranchID; 
