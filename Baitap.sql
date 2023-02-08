CREATE DATABASE AZBank;
go
USE AZBank;
go
--2
CREATE TABLE Customer (
    CustomerId INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(50) NOT NULL,
	City VARCHAR(50) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Email VARCHAR(50) NOT NULL
);

CREATE TABLE CustomerAccount (
    AccountNumber VARCHAR(20) PRIMARY KEY,
    CustomerId INT FOREIGN KEY REFERENCES Customer(CustomerId),
    Balance DECIMAL(18,2) NOT NULL,
	MinAcount DECIMAL (18) NOT NULL
);

CREATE TABLE CustomerTransaction (
    TransactionId INT PRIMARY KEY IDENTITY(1,1),
    AccountNumber VARCHAR(20) FOREIGN KEY REFERENCES CustomerAccount(AccountNumber),
    TransactionDate DATETIME NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    DepositorWithdraw VARCHAR(10) NOT NULL
);
--3
INSERT INTO Customer (Name,City, Country, Phone, Email)
VALUES 
    ('John Doe','HaNoi', 'Vietnam', '+84 123 456 789', 'johndoe@email.com'),
    ('Jane Doe','ThanhHoa', 'Vietnam', '+84 987 654 321', 'janedoe@email.com'),
    ('Bob Smith','NewYork', 'USA', '+1 123 456 789', 'bobsmith@email.com');

INSERT INTO CustomerAccount (AccountNumber, CustomerId, Balance, MinAcount)
VALUES
    ('A00000001', 1, 10000, 100),
    ('A00000002', 2, 20000, 400),
    ('A00000003', 3, 30000, 600);

INSERT INTO CustomerTransaction (AccountNumber, TransactionDate, Amount, DepositorWithdraw)
VALUES
    ('A00000001', '2022-01-01', 5000, 'deposit'),
    ('A00000002', '2022-02-01', 6000, 'withdraw'),
    ('A00000003', '2022-03-01', 7000, 'deposit');
--4
SELECT *
FROM Customer
WHERE Country = 'Hanoi';
--5
SELECT Name, Phone, Email, CustomerAccount.AccountNumber, Balance
FROM Customer
JOIN CustomerAccount
ON Customer.CustomerId = CustomerAccount.CustomerId;
--6
ALTER TABLE CustomerTransaction
ADD CONSTRAINT CK_Amount
CHECK (Amount > 0 AND Amount <= 1000000);
--7
CREATE NONCLUSTERED INDEX IX_Customer_Name
ON Customer (Name);
--8
Create view vCustomerTransactions 
as 
select Name, Balance, TransactionDate, Amount, DepositorWithdraw 
from Customer c
join CustomerAccount ca
on c.CustomerId = ca.CustomerId
join CustomerTransaction ct
on ct.AccountNumber= ca.AccountNumber

select * from vCustomerTransactions,
--9

CREATE PROCEDURE spAddCustomer (@CustomerId INT, @CustomerName VARCHAR(50), @Country VARCHAR(50), @Phone VARCHAR(50), @Email VARCHAR(50))
AS
BEGIN
    INSERT INTO Customer (CustomerId, Name, Country, Phone, Email)
    VALUES (@CustomerId, @CustomerName, @Country, @Phone, @Email)
END

EXEC spAddCustomer 1, 'John Doe', 'Hanoi', '123 456 789', 'johndoe@email.com'
EXEC spAddCustomer 2, 'Jane Doe', 'Hanoi', '0987 654 321', 'janedoe@email.com'
EXEC spAddCustomer 3, 'Jim Smith', 'USA', '+1 123 456 789', 'jimsmith@email.com'
--10
CREATE PROCEDURE spGetTransactions (@AccountNumber INT, @FromDate DATE, @ToDate DATE)
AS
BEGIN
    SELECT Customer.Name, CustomerAccount.AccountNumber, CustomerTransaction.TransactionDate, CustomerTransaction.Amount, CustomerTransaction.DepositorWithdraw
    FROM Customer
    INNER JOIN CustomerAccount ON Customer.CustomerId = CustomerAccount.CustomerId
    INNER JOIN CustomerTransaction ON CustomerAccount.AccountNumber = CustomerTransaction.AccountNumber
    WHERE CustomerAccount.AccountNumber = @AccountNumber
      AND CustomerTransaction.TransactionDate BETWEEN @FromDate AND @ToDate
END