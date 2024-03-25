CREATE TRIGGER after_place_order_update_order_history
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    -- Insert a new record into the OrderStatusHistory table
    INSERT INTO OrderStatusHistory (OrderID, Status, ChangeDate)
    VALUES (NEW.OrderID, 'Placed', NEW.OrderDate);
END$$
DELIMITER ; 