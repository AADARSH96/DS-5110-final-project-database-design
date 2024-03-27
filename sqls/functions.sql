-- Create a function to calculate total rewards points for a customer
DELIMITER $$

CREATE FUNCTION total_customer_rewards(customer_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_points INT;

    SELECT SUM(Points)
    INTO total_points
    FROM Rewards
    WHERE CustomerID = customer_id;

    RETURN total_points;
END$$

DELIMITER ;


-- Create a function to get customer category based on total reward points
DELIMITER $$

CREATE FUNCTION get_customer_status(customer_id INT) RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE total_points INT;
    DECLARE category VARCHAR(50);

    -- Calculate total reward points for the customer
    SET total_points = total_customer_rewards(customer_id);

    -- Determine customer category based on total reward points
    IF total_points >= 1000 THEN
        SET category = 'Gold';
    ELSEIF total_points >= 500 THEN
        SET category = 'Silver';
    ELSE
        SET category = 'Bronze';
    END IF;

    RETURN category;
END$$

DELIMITER ;

-- Create a function to calculate total amount with discounts based on order ID
DELIMITER $$

CREATE FUNCTION total_order_amount(order_id INT) RETURNS DECIMAL(10, 2)
READS SQL DATA
BEGIN
    DECLARE total_amount DECIMAL(10, 2);

    SELECT SUM(od.Quantity * (p.Price - IFNULL(d.DiscountAmount, 0)))
    INTO total_amount
    FROM OrderDetails od
    JOIN Products p ON od.ProductID = p.ProductID
    JOIN Orders o ON od.OrderID = o.OrderID
    LEFT JOIN Discounts d ON p.ProductID = d.ProductID AND o.OrderDate BETWEEN d.StartDate AND d.EndDate
    WHERE od.OrderID = order_id;

    RETURN total_amount;
END$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION highest_selling_product_category(supplier_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE highest_selling_product_id INT;

    SELECT p.ProductID INTO highest_selling_product_id
    FROM Products p
    JOIN OrderDetails od ON p.ProductID = od.ProductID
    JOIN Orders o ON od.OrderID = o.OrderID
    JOIN Suppliers s ON p.SupplierID = s.SupplierID
    WHERE s.SupplierID = supplier_id
    GROUP BY p.ProductID
    ORDER BY SUM(od.Quantity) DESC
    LIMIT 1;

    RETURN highest_selling_product_id;
END$$

DELIMITER ;


DELIMITER $$

CREATE FUNCTION highest_selling_supplier_category(supplier_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE highest_selling_category_id INT;

    SELECT p.CategoryID INTO highest_selling_category_id
    FROM Products p
    JOIN OrderDetails od ON p.ProductID = od.ProductID
    JOIN Orders o ON od.OrderID = o.OrderID
    JOIN Suppliers s ON p.SupplierID = s.SupplierID
    WHERE s.SupplierID = supplier_id
    GROUP BY p.CategoryID
    ORDER BY SUM(od.Quantity) DESC
    LIMIT 1;

    RETURN highest_selling_category_id;
END$$

DELIMITER ;