-- ============================================================
-- Clients and Orders: JOINs (MySQL)
-- Shows the difference between INNER JOIN and LEFT JOIN.
-- All data is made-up sample data.
-- ============================================================

DROP DATABASE IF EXISTS stock;
CREATE DATABASE stock;
USE stock;

CREATE TABLE Client (
    ClientID      INT PRIMARY KEY,
    ClientName    VARCHAR(50),
    ClientSurname VARCHAR(50),
    Address1      VARCHAR(100),
    City          VARCHAR(50),
    PostalCode    VARCHAR(10)
);

INSERT INTO Client (ClientID, ClientName, ClientSurname, Address1, City, PostalCode)
VALUES
(1, 'Peter',  'Pan',   '10 Green St',        'Cape Town',    '8001'),
(2, 'Mickey', 'Mouse', '15 Castle Rd',       'Durban',       '4001'),
(3, 'Bruce',  'Wayne', '100 Gotham Ave',     'Johannesburg', '2000'),
(4, 'Clark',  'Kent',  '12 Daily Planet St', 'Cape Town',    '8001');

CREATE TABLE Orders (
    OrderID   INT PRIMARY KEY,
    OrderDate DATE,
    ClientID  INT,
    FOREIGN KEY (ClientID) REFERENCES Client(ClientID)
);

INSERT INTO Orders (OrderID, OrderDate, ClientID)
VALUES
(10, '2024-03-10', 1),
(11, '2024-03-02', 2),
(12, '2024-03-03', 1);

-- INNER JOIN: only clients who have placed an order
SELECT Client.ClientName,
       Client.ClientSurname,
       Orders.OrderID,
       Orders.OrderDate
FROM Client
INNER JOIN Orders
    ON Client.ClientID = Orders.ClientID;

-- LEFT JOIN: every client, including those with no orders
-- (Bruce and Clark appear with NULL order details)
SELECT Client.ClientName,
       Client.ClientSurname,
       Orders.OrderID,
       Orders.OrderDate
FROM Client
LEFT JOIN Orders
    ON Client.ClientID = Orders.ClientID;
