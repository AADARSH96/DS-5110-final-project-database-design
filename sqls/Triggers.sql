DELIMITER $$
CREATE TRIGGER after_place_order_update_order_history
AFTER INSERT ON orderdetails
FOR EACH ROW
BEGIN
    -- Insert a new record into the OrderStatusHistory table
    INSERT INTO OrderStatusHistory (OrderID, ProductID, Status, ChangeDate)
    VALUES (NEW.OrderID, NEW.ProductID, 'Pending', curdate());
END$$
DELIMITER ; 
