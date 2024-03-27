DELIMITER $$

CREATE PROCEDURE DeleteProduct(
    IN p_product_id INT
)
BEGIN
    -- Check if the product exists
    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = p_product_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product ID does not exist';
	ELSE
		-- Delete the product
		DELETE FROM Products WHERE ProductID = p_product_id;
	END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE AddProduct(
    IN p_name VARCHAR(255),
    IN p_description TEXT,
    IN p_price DECIMAL(10, 2),
    IN p_category_id INT,
    IN p_supplier_id INT
    )
BEGIN
    DECLARE product_count INT;

    -- Check if the product already exists
    SELECT COUNT(*) INTO product_count FROM Products
    WHERE Name = p_name AND SupplierID = p_supplier_id;

    IF product_count = 0 THEN
        -- Insert the product if it doesn't already exist
        INSERT INTO Products (Name, Description, Price, CategoryID, SupplierID)
        VALUES (p_name, p_description, p_price, p_category_id, p_supplier_id);
    ELSE
        -- Raise an error if the product already exists
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product already exists for the given supplier';
    END IF;
END$$

DELIMITER ;


DELIMITER $$
CREATE PROCEDURE ModifyProduct(
    IN p_id INT,
    IN p_name VARCHAR(255),
    IN p_description TEXT,
    IN p_price DECIMAL(10, 2),
    IN p_category_id INT,
    IN p_supplier_id INT
)
BEGIN
    DECLARE old_name VARCHAR(255);
    DECLARE old_description TEXT;
    DECLARE old_price DECIMAL(10, 2);
    DECLARE old_category_id INT;
    DECLARE old_supplier_id INT;

    -- Fetch existing values of the product
    SELECT Name, Description, Price, CategoryID, SupplierID
    INTO old_name, old_description, old_price, old_category_id, old_supplier_id
    FROM Products
    WHERE ProductID = p_id;

    -- Update only the provided values
    IF p_name IS NOT NULL THEN
        SET old_name = p_name;
    END IF;

    IF p_description IS NOT NULL THEN
        SET old_description = p_description;
    END IF;

    IF p_price IS NOT NULL THEN
        SET old_price = p_price;
    END IF;


    IF p_category_id IS NOT NULL THEN
        SET old_category_id = p_category_id;
    END IF;

    IF p_supplier_id IS NOT NULL THEN
        SET old_supplier_id = p_supplier_id;
    END IF;
    -- Check if the product exists
    IF EXISTS (SELECT * FROM Products WHERE ProductID = p_id) THEN

		-- Update the product with the modified values
		UPDATE Products
			SET
				Name = old_name,
				Description = old_description,
				Price = old_price,
				CategoryID = old_category_id,
				SupplierID = old_supplier_id
				WHERE ProductID = p_id;
	ELSE
        -- Product does not exist, return error or handle as needed
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product does not exist.';
    END IF;
END$$
DELIMITER ;

DELIMITER $$

CREATE PROCEDURE ModifyOrAddDiscount(
    IN p_product_id INT,
    IN p_discount_amount DECIMAL(10, 2),
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    DECLARE existing_discount_id INT;
    DECLARE product_exists INT;

    -- Check if the product exists
    SELECT COUNT(*) INTO product_exists FROM Products WHERE ProductID = p_product_id;

    IF product_exists > 0 THEN
        -- Check if a discount already exists for the product within the specified date range
        SELECT DiscountID INTO existing_discount_id
        FROM Discounts
        WHERE ProductID = p_product_id
        AND ((p_start_date BETWEEN StartDate AND EndDate)
        OR (p_end_date BETWEEN StartDate AND EndDate)
        OR (StartDate BETWEEN p_start_date AND p_end_date)
        OR (EndDate BETWEEN p_start_date AND p_end_date));

        IF existing_discount_id IS NOT NULL THEN
            -- Update the existing discount
            UPDATE Discounts
            SET DiscountAmount = p_discount_amount,
                StartDate = p_start_date,
                EndDate = p_end_date
            WHERE DiscountID = existing_discount_id;
        ELSE
            -- Add a new discount
            INSERT INTO Discounts (ProductID, DiscountAmount, StartDate, EndDate)
            VALUES (p_product_id, p_discount_amount, p_start_date, p_end_date);
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product does not exist.';
    END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE DeleteDiscountsForProduct(
    IN p_product_id INT
)
BEGIN
    DECLARE product_exists INT;

    -- Check if the product ID exists
    SELECT COUNT(*) INTO product_exists FROM Products WHERE ProductID = p_product_id;

    IF product_exists > 0 THEN
        -- Delete associated discounts
        DELETE FROM Discounts WHERE ProductID = p_product_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product ID does not exist or has no associated discounts.';
    END IF;
END$$

DELIMITER ;




DELIMITER $$

CREATE PROCEDURE UpdateOrderStatus(
    IN p_order_id INT,
    IN p_status VARCHAR(50)
)
BEGIN
    DECLARE order_exists INT;

    -- Check if the order exists
    SELECT COUNT(*) INTO order_exists FROM Orders WHERE OrderID = p_order_id;

    IF order_exists > 0 THEN
        -- Check if the provided status is valid
        IF p_status IN ('Pending', 'Processing', 'Shipped', 'Delivered') THEN
            -- Update the order status
            UPDATE OrderStatusHistory
            SET Status = p_status,
                ChangeDate = CURRENT_DATE()
            WHERE OrderID = p_order_id;
        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid order status provided. Status should be one of ["Pending", "Processing", "Shipped", "Delivered"].';
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order does not exist.';
    END IF;
END$$

DELIMITER ;

DELIMITER $$
CREATE PROCEDURE PlaceOrder(
    IN customer_id INT,
    IN product_ids TEXT,
    IN quantities TEXT
)
BEGIN
    DECLARE total_amount DECIMAL(10, 2) DEFAULT 0;
    DECLARE product_id INT;
    DECLARE quantity INT;
    DECLARE product_index INT DEFAULT 0;
    DECLARE quantity_index INT DEFAULT 0;

    -- Insert order record and get the generated OrderID
    INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
    VALUES (customer_id, CURDATE(), 0);
    SET @order_id = LAST_INSERT_ID();

    -- Loop through each order detail item using the provided lists
    WHILE product_index < LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 DO
        SET product_id = SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', product_index + 1), ',', -1);
        SET quantity_index = product_index + 1;
        SET quantity = SUBSTRING_INDEX(SUBSTRING_INDEX(quantities, ',', quantity_index), ',', -1);

        -- Process each product and update total amount
        SET total_amount = total_amount + (quantity * (
            SELECT price
            FROM Products
            WHERE ProductID = product_id
        ));

        -- Insert order detail record
        INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
        VALUES (@order_id, product_id, quantity);

        SET product_index = product_index + 1;
    END WHILE;

    -- Update order total amount
    UPDATE Orders
    SET TotalAmount = total_amount
    WHERE OrderID = @order_id;

    INSERT INTO Rewards (CustomerID, Points, RewardDate)
        VALUES (customer_id, FLOOR(total_amount / 10), CURDATE());
END$$
DELIMITER ;