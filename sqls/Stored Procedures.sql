DELIMITER $$

CREATE PROCEDURE DeleteProduct(
    IN p_product_id INT,
    IN p_supplier_id INT,
    IN p_password INT
)
BEGIN
    DECLARE password_text VARCHAR(20);
    
    Select password INTO password_text from suppliers where SupplierID = p_supplier_id;

	IF p_password = password_text THEN
    
    -- Check if the product exists
		IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = p_product_id and SupplierID=p_supplier_id) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product ID does not exist';
		ELSE
			-- Delete the product
			DELETE FROM Products WHERE ProductID = p_product_id;
		END IF;
	ELSE
			-- Raise an error if the Supplier ID is wrong
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Given Supplier password is wrong';
	END IF;
	
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE AddProductQuantity(
    IN p_product_id INT,
    IN p_Quantity INT,
    IN p_supplier_id INT,
    IN p_password INT
    )
BEGIN
    DECLARE product_exists INT;
    DECLARE password_text VARCHAR(20);

    -- Check if the product already exists
    SELECT COUNT(*) INTO product_exists FROM Products
    WHERE ProductID = p_product_id AND SupplierID = p_supplier_id;
    
    Select password INTO password_text from suppliers where SupplierID = p_supplier_id;
    
    IF p_password = password_text THEN

		IF product_exists > 0 THEN
			-- Insert the product if it doesn't already exist
			INSERT INTO inventorylog (ProductID, QuantityChanged, LogDate)
			VALUES (p_product_id, p_Quantity, curdate());
		ELSE
			-- Raise an error if the product already exists
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product does not exists for the given supplier';
		END IF;
	ELSE
			-- Raise an error if the product already exists
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Given Supplier password is wrong';
	END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE AddProduct(
    IN p_name VARCHAR(255),
    IN p_description TEXT,
    IN p_price DECIMAL(10, 2),
    IN p_category_id INT,
    IN p_supplier_id INT,
    IN p_Quantity INT,
    IN p_password INT
    )
BEGIN
    DECLARE product_count INT;
    DECLARE password_text VARCHAR(20);

    -- Check if the product already exists
    SELECT COUNT(*) INTO product_count FROM Products
    WHERE Name = p_name AND SupplierID = p_supplier_id;
    
    Select password INTO password_text from suppliers where SupplierID = p_supplier_id;
    
    IF p_password = password_text THEN

		IF product_count = 0 THEN
			-- Insert the product if it doesn't already exist
			INSERT INTO Products (Name, Description, Price, CategoryID, SupplierID)
			VALUES (p_name, p_description, p_price, p_category_id, p_supplier_id);
			Insert into inventorylog (ProductID, QuantityChanged, LogDate)
			Values ((Select productID from products where name=p_name),p_Quantity,CURRENT_DATE());
		ELSE
			-- Raise an error if the product already exists
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product already exists for the given supplier';
		END IF;
	ELSE
			-- Raise an error if the product already exists
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Given Supplier password is wrong';
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
    IN p_supplier_id INT,
    IN p_password INT
)
BEGIN
    DECLARE old_name VARCHAR(255);
    DECLARE old_description TEXT;
    DECLARE old_price DECIMAL(10, 2);
    DECLARE old_category_id INT;
    DECLARE old_supplier_id INT;
    DECLARE password_text VARCHAR(20);

    -- Fetch existing values of the product
    SELECT Name, Description, Price, CategoryID, SupplierID
    INTO old_name, old_description, old_price, old_category_id, old_supplier_id
    FROM Products
    WHERE ProductID = p_id;
    
    Select password INTO password_text from suppliers where SupplierID = p_supplier_id;
    
    
	IF p_password = password_text THEN
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
	ELSE
			-- Raise an error if the product already exists
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Given Supplier password is wrong';
	END IF;
END$$
DELIMITER ;



DELIMITER $$


CREATE PROCEDURE ModifyOrAddDiscount(
    IN p_product_id INT,
    IN p_supplier_id INT,
    IN p_discount_amount DECIMAL(10, 2),
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_password INT
)
BEGIN
    DECLARE existing_discount_id INT;
    DECLARE product_exists INT;
    DECLARE password_text VARCHAR(20);

    -- Check if the product exists
    SELECT COUNT(*) INTO product_exists FROM Products WHERE ProductID = p_product_id and SupplierID=p_supplier_id;
    
    Select password INTO password_text from suppliers where SupplierID = p_supplier_id;
	
    
    IF p_password = password_text THEN
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
	ELSE
			-- Raise an error if the product already exists
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Given Supplier password is wrong';
	END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE UpdateOrderStatus(
    IN p_order_id INT,
    IN p_product_id INT,
    IN p_supplier_id INT,
    IN p_status VARCHAR(50),
    IN p_password INT
)
BEGIN
    DECLARE order_exists INT;
    DECLARE password_text VARCHAR(20);

    -- Check if the order exists in order status history
    SELECT COUNT(*) INTO order_exists FROM orderstatushistory as o join products as p on o.ProductID=p.ProductID 
    WHERE o.OrderID = p_order_id and p.supplierID=p_supplier_id and o.ProductID=p_product_id;
    
    Select password INTO password_text from suppliers where SupplierID = p_supplier_id;
    
    IF p_password = password_text THEN

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
	ELSE
			-- Raise an error if the product already exists
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Given Supplier password is wrong';
	END IF;
END$$

DELIMITER ;



DELIMITER $$
CREATE PROCEDURE PlaceOrder(
    IN customer_id INT,
    IN product_ids TEXT
)
BEGIN
    DECLARE total_amount DECIMAL(10, 2) DEFAULT 0;
    DECLARE p_product_id INT;
    DECLARE discount DECIMAL(10, 2) DEFAULT 0;
    DECLARE product_index INT DEFAULT 0;
    DECLARE date1 DATE;
    DECLARE quantity INT;

    -- Insert order record and get the generated OrderID
    INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
    VALUES (customer_id, CURDATE(), 0);
    SET @order_id = LAST_INSERT_ID();

    -- Loop through each order detail item using the provided lists
    WHILE product_index < LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 DO
        SET p_product_id = SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', product_index + 1), ',', -1);

        -- Process each product and update total amount
        SET date1 = CURDATE();
        set discount = (Select DiscountAmount from discounts where ProductID=p_product_id and date1 between StartDate and EndDate);
        
        
        
        IF p_product_id IN (Select productid from cart where customerID = customer_id ) THEN
        
			-- Get the quantity from cart
            Set quantity = (Select sum(CartQuantity) from cart where ProductID=p_product_id and CustomerID=customer_id);
            
            -- calculating the total amount
            SET total_amount = total_amount + (quantity * (
            SELECT price
            FROM Products
            WHERE ProductID = p_product_id
			)-(quantity*discount));
        
            -- Insert order detail record
            INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
			VALUES (@order_id, p_product_id, quantity);
            
            Delete from cart where productID=p_product_id and customerID=customer_id;
        
			INSERT INTO inventorylog (ProductID, QuantityChanged, LogDate)
			VALUES (p_product_id, quantity*-1, CURDATE());
            
        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product not available in cart. So first add the product to the cart';
        END IF;

        -- Insert order detail record

        SET product_index = product_index + 1;
    END WHILE;

    -- Update order total amount
    UPDATE Orders
    SET TotalAmount = total_amount
    WHERE OrderID = @order_id;

    INSERT INTO Rewards (CustomerID, Points, RewardDate)
        VALUES (customer_id, FLOOR(total_amount / 10), CURDATE());
        
	INSERT INTO payments (OrderID, Amount, PaymentDate)
        VALUES (@order_id, total_amount, CURDATE());
        
	-- INSERT INTO orderstatushistory (OrderID, Status, ChangeDate)
--         VALUES (@order_id, 'Pending', CURDATE());
        
	
END$$
DELIMITER ;

-- call PlaceOrder(19,'6,7,8','1,2,3');


DELIMITER $$



CREATE PROCEDURE AddtoCart(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
	DECLARE product_exists INT;
    DECLARE Available_quantity INT;
    DECLARE cart_quantity INT;

    -- Check if the order exists
    SELECT SUM(QuantityChanged) INTO Available_quantity FROM inventorylog WHERE ProductID = p_product_id;
    
    Select count(*) into product_exists from cart where customerID=p_customer_id and productID=p_product_id;
    
	IF product_exists > 0 THEN 
    
		Set cart_quantity = (Select CartQuantity from cart where customerID=p_customer_id and productID=p_product_id);
		IF cart_quantity+p_quantity <= Available_quantity THEN
			UPDATE cart
			SET CartQuantity = cart_quantity+p_quantity
			WHERE customerID=p_customer_id and productID=p_product_id;
            
		ELSE
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Selected Quantity exceed the available product Quantity';
		END IF;
        
    ELSE
		IF p_quantity <= Available_quantity THEN
			-- Add the products to the cart
			INSERT INTO cart (CustomerID, ProductID, CartQuantity)
			VALUES (p_customer_id, p_product_id, p_quantity);
        
        
		ELSE
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Selected Quantity exceed the available product Quantity';
		END IF;
	END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE Get_Product_Details(
    IN p_product_id INT,
    IN p_product_name text
)
BEGIN
    Select p.ProductID, p.name, p.description, p.price, p.supplierID,
    d.DiscountAmount, d.startDate as Discount_StartDate, d.EndDate as Discount_EndDate,
    r.rating, r.ReviewText, r.ReviewDate
    from Products as p Natural join Discounts as d
    Natural join reviews as r
    where p.ProductID=p_product_id and p.name=p_product_name limit 1;
	
END$$

DELIMITER ;

