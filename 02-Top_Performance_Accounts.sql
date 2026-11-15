-- Business scenario: 
-- A bank wants to identify its most active accounts during 2025. Management wants to see the top three accounts within each account type based on their successful transaction amounts. For example, the bank wants to know which three Savings accounts generated the highest transaction amounts, which three Current accounts performed best, and so on.

-- Your task: Write a SQL query to identify the top 3 accounts within each AccountType based on their total successful transaction amount during 2025.

WITH high_transactions AS (
SELECT 
a.AccountID,
a.AccountNumber,
a.AccountType,
b.BranchName,
COUNT(DISTINCT t.TransactionID) AS TotalTransactions,
c.FirstName + ' ' + c.LastName AS CustomerName,
ROUND(SUM(t.Amount), 2) AS TransactionsAmount,
RANK() OVER (PARTITION BY a.AccountType ORDER BY ROUND(SUM(t.Amount), 2) DESC, a.AccountID) AS AccountRank
FROM Sales.Customers c JOIN Finance.Accounts a ON c.CustomerID=a.CustomerID JOIN Finance.Transactions t ON a.AccountID=t.AccountID JOIN dbo.Branches b ON t.BranchID=b.BranchID WHERE t.TransactionDate >= '20250101' AND t.TransactionDate < '20260101' AND TransactionStatus='SUCCESS' GROUP BY a.AccountID, a.AccountNumber, a.AccountType, b.BranchName, c.FirstName + ' ' + c.LastName)

SELECT AccountID, AccountNumber, AccountType, AccountRank, TotalTransactions, CustomerName, BranchName, TransactionsAmount FROM high_transactions WHERE AccountRank<=3 ORDER BY AccountType, TransactionsAmount DESC;

