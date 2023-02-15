--Los diez mas vendidos
USE Northwind
GO

SELECT TOP 10 p.ProductName, sum(od.Quantity) AS [Units Sold]
FROM [Order Details] od
INNER JOIN [Products] p ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY [Units Sold] DESC
--Producto segundo mas caro

SELECT ProductName, UnitPrice
FROM [Products] p1
WHERE 1 = (SELECT COUNT(DISTINCT UnitPrice)
FROM Products p2
WHERE p2.UnitPrice > p1.UnitPrice)


--Ranking de mas vendidos por ciudad


SELECT p.ProductName, c.City, od.Quantity,
DENSE_RANK () OVER (PARTITION BY c.City ORDER BY od.Quantity DESC) AS RANK
FROM [Customers] c
INNER JOIN [Orders] o on (c.CustomerID = o.CustomerID)
INNER JOIN [Order Details] od on (o.OrderID = od.OrderID)
INNER JOIN [Products] p on (od.ProductID = p.ProductID)
--AND c.City = 'Boise'
ORDER BY RANK ASC

--Ordenes de mas de 2 dias y con mas de 10.000
--Mostrar numero de dias, fecha, customerID, pais de envio


SELECT o.OrderID, o.CustomerID, o.OrderDate, o.ShippedDate, o.ShipCountry,
DATEDIFF(DAY, OrderDate, ShippedDate) AS Duration_to_Ship,
SUM(od.Quantity*od.UnitPrice) as [Total Sale Amount]
FROM [Orders] o
INNER JOIN [Order Details] od on o.OrderID = od.OrderID
WHERE DATEDIFF(Day, OrderDate, ShippedDate) >2
GROUP BY o.OrderID, o.CustomerID, o.OrderDate, o.ShippedDate, o.ShipCountry
HAVING SUM(od.Quantity*od.UnitPrice)> 10000

--Ventas mayores a 70k


SELECT c.CompanyName, c.City, c.Country,
SUM(od.Quantity*od.UnitPrice) as TOTAL

FROM [Customers] c
INNER JOIN [Orders] o ON (c.CustomerID = o.CustomerID)
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = '2018'
GROUP BY c.CompanyName, c.City, c.Country
HAVING SUM(od.Quantity*od.UnitPrice) > (SELECT AVG(Quantity*UnitPrice) FROM [Order Details]) 
ORDER BY TOTAL DESC;



--Clientes sin compras 20 meses


SELECT c.Companyname, MAX(o.OrderDate),
DATEDIFF(MONTH,MAX(o.OrderDate), GETDATE()) AS [Months Since Last Order]

FROM [Customers] c
INNER JOIN [Orders] o ON c.CustomerID=o.CustomerID
GROUP BY c.CompanyName
HAVING DATEDIFF(MONTH,MAX(o.OrderDate), GETDATE()) > 20;



-- Numero ordenes por clientes


SELECT c.CompanyName,
(SELECT COUNT(OrderID) FROM [Orders] o
WHERE c.CustomerID = o.CustomerID) as [Number of Orders]
FROM [Customers] c
ORDER BY [Number of Orders] DESC;



--Duracion dias entre ordenes de cada cliente


SELECT a.CustomerID, a.OrderDate, b.OrderDate,
DATEDIFF(DAY, a.OrderDate, b.OrderDate) as [Days Between two orders]
FROM [Orders] a
INNER JOIN [Orders] b ON a.OrderID=b.OrderID-1;



--Empleados con mas ventas + bono del 2%


SELECT TOP 3 e.FirstName + ' ' + e.LastName as [Full Name],
SUM(od.Quantity*od.UnitPrice) as [Total Sale],
SUM(od.Quantity*od.UnitPrice)*0.02 as Bonus
FROM [Employees] e
INNER JOIN [Orders] o ON e.EmployeeID=o.EmployeeID
INNER JOIN [Order Details] od ON o.OrderID=od.OrderID
WHERE YEAR(o.OrderDate) = '2018'
GROUP BY e.FirstName + ' ' + e.LastName



--Empleados por posicion y ciudad


SELECT title, city, COUNT(EmployeeID)
FROM [Employees]
GROUP BY title, city;

--Años trabajados

SELECT LastName, firstName, Title,
DATEDIFF(YEAR, HireDate, GETDATE()) AS [Work years in company]
FROM [Employees];

--Mayores a 70

SELECT FirstName, LastName, Title,
DATEDIFF(YEAR, BirthDate, GETDATE()) AS AGE
FROM [Employees]
WHERE DATEDIFF(YEAR, BirthDate, GETDATE()) >= 70;

