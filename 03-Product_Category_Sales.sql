-- Day 3- Product Category Sales
-- Business scenario: A retail company wants to evaluate the performance of its product categories during 2025.   Management wants to understand which product categories generated the highest net revenue, how many products were sold, and how much discount was given to customers.
-- Task: Your job is to develop a category-wise sales performance report.
SELECT   c.CategoryName,
         COUNT(o.OrderStatus) AS CompletedOrders,
         ROUND (
             SUM (oi.UnitPrice * oi.Quantity),
             2
         ) AS GrossSales,
         SUM(oi.Quantity) AS ProductsSold,
         CAST (SUM((oi.UnitPrice * oi.Quantity) * oi.DiscountPct) / 100 AS DECIMAL (20, 2)) AS DiscountAmount,
         ROUND (
             SUM (o.OrderTotal),
             2
         ) AS NetSales
FROM     Sales.Orders AS o
         INNER JOIN
         Sales.OrderItems AS oi
         ON o.OrderID = oi.OrderID
         INNER JOIN
         Inventory.Products AS p
         ON oi.ProductiD = p.ProductID
         INNER JOIN
         Inventory.Categories AS c
         ON p.CategoryID = c.CategoryID
WHERE    o.OrderDate >= '20250101'
         AND o.OrderDate < '20260101'
         AND o.OrderStatus = 'Completed'
GROUP BY c.CategoryName
ORDER BY ROUND (
             SUM (oi.UnitPrice * oi.Quantity),
             2
         ) DESC;

