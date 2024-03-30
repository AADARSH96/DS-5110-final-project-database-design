SET GLOBAL local_infile = 1;
SET SQL_SAFE_UPDATES = 0;
SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'C:/Users/Raghu Ram/Desktop/Spring 2024/IDMP/Project/Excel/Categories.csv' 
INTO TABLE categories 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- delete from suppliers;
LOAD DATA LOCAL INFILE 'C:/Users/Raghu Ram/Desktop/Spring 2024/IDMP/Project/Excel/Suppliers.csv' 
INTO TABLE suppliers 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- delete from products;
LOAD DATA LOCAL INFILE 'C:/Users/Raghu Ram/Desktop/Spring 2024/IDMP/Project/Excel/Products.csv' 
INTO TABLE products 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- DELETE FROM discounts;
LOAD DATA LOCAL INFILE 'C:/Users/Raghu Ram/Desktop/Spring 2024/IDMP/Project/Excel/Discounts.csv' 
INTO TABLE discounts 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- DELETE FROM customers;
LOAD DATA LOCAL INFILE 'C:/Users/Raghu Ram/Desktop/Spring 2024/IDMP/Project/Excel/Customers.csv' 
INTO TABLE customers 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- DELETE FROM inventorylog;
LOAD DATA LOCAL INFILE 'C:/Users/Raghu Ram/Desktop/Spring 2024/IDMP/Project/Excel/InventoryLog.csv' 
INTO TABLE inventorylog 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- DELETE FROM orders;
LOAD DATA LOCAL INFILE 'C:/Users/Raghu Ram/Desktop/Spring 2024/IDMP/Project/Excel/Orders.csv' 
INTO TABLE orders 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- DELETE FROM orderdetails;
LOAD DATA LOCAL INFILE 'C:/Users/Raghu Ram/Desktop/Spring 2024/IDMP/Project/Excel/OrderDetails.csv' 
INTO TABLE orderdetails
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- DELETE FROM orderstatushistory;
LOAD DATA LOCAL INFILE 'C:/Users/Raghu Ram/Desktop/Spring 2024/IDMP/Project/Excel/Orderstatushistory.csv' 
INTO TABLE orderstatushistory
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- DELETE FROM payments;
LOAD DATA LOCAL INFILE 'C:/Users/Raghu Ram/Desktop/Spring 2024/IDMP/Project/Excel/Payments.csv' 
INTO TABLE payments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- DELETE FROM reviews;
LOAD DATA LOCAL INFILE 'C:/Users/Raghu Ram/Desktop/Spring 2024/IDMP/Project/Excel/Reviews.csv' 
INTO TABLE reviews
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- DELETE FROM rewards;
LOAD DATA LOCAL INFILE 'C:/Users/Raghu Ram/Desktop/Spring 2024/IDMP/Project/Excel/Rewards.csv' 
INTO TABLE rewards
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/Raghu Ram/Desktop/Spring 2024/IDMP/Project/Excel/Cart.csv' 
INTO TABLE cart
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
