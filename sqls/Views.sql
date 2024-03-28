-- View to show customer information and reward points
CREATE VIEW user_info AS
SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    c.PhoneNumber,
    c.Address,
    c.Email,
    total_customer_rewards(c.CustomerID) AS RewardPoints,
    get_customer_status(c.CustomerID) AS Category
FROM
    Customers c;

-- Create a view to show order history, status, and amount with discount
CREATE VIEW user_orders AS
SELECT
    o.OrderID,
    o.CustomerID,
    o.OrderDate,
    os.Status AS OrderStatus ,
    total_order_amount(o.OrderID) AS Amount
FROM
    Orders o
JOIN
    OrderDetails od ON o.OrderID = od.OrderID
JOIN
    Products p ON od.ProductID = p.ProductID
JOIN
    OrderStatusHistory os ON o.OrderId = os.OrderId
GROUP BY
    o.OrderID,
    o.CustomerID,
    o.OrderDate,
    os.Status;


-- View to show top selling products
CREATE VIEW top_selling_products AS
SELECT p.ProductID, p.Name AS ProductName, SUM(od.Quantity) AS TotalQuantitySold
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductID
ORDER BY TotalQuantitySold DESC
LIMIT 10;

-- View to show top rated products with more than 5 reviews
CREATE VIEW top_rated_products AS
SELECT
    p.ProductID,
    p.Name AS ProductName,
    AVG(r.Rating) AS AvgRating,
    COUNT(r.ReviewID) AS TotalReviews
FROM
    Products p
LEFT JOIN
    Reviews r ON p.ProductID = r.ProductID
GROUP BY
    p.ProductID,
    p.Name
HAVING
    TotalReviews > 0  -- More than 5 reviews
ORDER BY
    AvgRating DESC
LIMIT 10;

CREATE VIEW supplier_info AS
SELECT s.SupplierID, s.Name AS SupplierName, s.PhoneNumber AS SupplierPhoneNumber,
       s.Address AS SupplierAddress, s.Email AS SupplierEmail,
       COUNT(p.ProductID) AS NumberOfProductsSupplied,
       COALESCE(SUM(od.Quantity * p.Price),0) AS SupplierRevenue,
       COUNT(DISTINCT o.OrderID) AS NumberOfOrders,
       highest_selling_supplier_category(s.SupplierID) as HighestSellingProduct,
       highest_selling_product_category(s.SupplierID) as HighestSellingCategory
FROM Suppliers s
LEFT JOIN Products p ON s.SupplierID = p.SupplierID
LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
LEFT JOIN Orders o ON od.OrderID = o.OrderID
GROUP BY s.SupplierID;

CREATE VIEW admin_stats AS
SELECT
    (SELECT COUNT(*) FROM Customers) AS TotalCustomers,
    (SELECT COUNT(*) FROM Orders) AS TotalOrders,
    (SELECT COUNT(*) FROM Products) AS TotalProducts,
    (SELECT COUNT(*) FROM Suppliers) AS TotalSuppliers,
    (SELECT COUNT(*) FROM Categories) AS TotalCategories,
    (SELECT COUNT(*) FROM Discounts) AS TotalDiscounts,
    (SELECT COUNT(*) FROM Reviews) AS TotalReviews,
    (SELECT COUNT(*) FROM Rewards) AS TotalRewards,
    (SELECT SUM(Amount) FROM Payments) AS TotalTransactions;

CREATE VIEW products_info AS
SELECT p.ProductID, p.Name AS ProductName, p.Description, p.Price,
       c.Name AS Category, s.Name AS Supplier, s.PhoneNumber AS SupplierPhoneNumber,
       s.Address AS SupplierAddress, s.Email AS SupplierEmail,
       SUM(od.Quantity * p.Price) AS ProductRevenue,
       AVG(r.Rating) AS AverageRating,
       COUNT(DISTINCT o.OrderID) AS NumberOfOrders,
       SUM(od.Quantity) AS TotalQuantitySold
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
JOIN Suppliers s ON p.SupplierID = s.SupplierID
LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
LEFT JOIN Orders o ON od.OrderID = o.OrderID
LEFT JOIN Reviews r ON p.ProductID = r.ProductID
GROUP BY p.ProductID;

CREATE VIEW order_status_counts AS
SELECT
    os.Status,
    COUNT(*) AS StatusCount
FROM
    OrderStatusHistory os
GROUP BY
    os.Status;