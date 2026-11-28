/* SQLPracticeLab – Challenge 8
Regional Sales Performance Analysis

Business scenario
A company wants to identify customers who have placed unusually high-value orders compared with the average 
completed order value in their respective regions.

The sales manager needs a report showing orders whose amounts exceed their regional average.

Your task is to write a query using a correlated subquery.*/
--Subquery--
SELECT 
o.OrderID,
c.FirstName + ' ' + c.LastName AS Customer_Name,
c.Province AS Region,
AVG(o.OrderTotal) AS Regional_Average,
o.OrderTotal AS OrderAmount
FROM Sales.Customers c 
INNER JOIN Sales.Orders o ON c.CustomerID = o.CustomerID 
WHERE o.OrderStatus = 'Completed'
GROUP BY o.OrderID, c.FirstName + ' ' + c.LastName, c.Province, o.OrderTotal
HAVING o.OrderTotal > (SELECT AVG(o2.OrderTotal) FROM Sales.Orders o2);

--Using CTE--
WITH HighValueCustomers AS (
SELECT 
o.OrderID,
c.FirstName + ' ' + c.LastName AS Customer_Name,
c.Province AS Region,
c.Gender,
AVG(o.OrderTotal) AS Avg_Order_Total,
o.OrderTotal
FROM Sales.Customers c 
INNER JOIN Sales.Orders o ON c.CustomerID = o.CustomerID 
GROUP BY o.OrderID, c.FirstName + ' ' + c.LastName, c.Province, c.Gender, o.OrderTotal)

SELECT * FROM HighValueCustomers WHERE OrderTotal > (SELECT AVG(o2.OrderTotal) FROM Sales.Orders o2);