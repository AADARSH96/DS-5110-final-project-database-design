DROP DATABASE IF EXISTS inventory_db_new;
create database `inventory_db_new`;
use inventory_db_new;
-- Categories Table
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL
);

-- Suppliers Table
CREATE TABLE Suppliers (
    SupplierID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(100),
    Address TEXT,
    Email VARCHAR(255),
    CHECK (LENGTH(Name) > 0)
);

-- Customers Table
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(100),
    Address TEXT,
    Email VARCHAR(255),
    CHECK (LENGTH(Name) > 0)
);

-- Products Table
CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Description TEXT,
    Price DECIMAL(10, 2) NOT NULL,
    CategoryID INT,
    SupplierID INT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID) ON UPDATE CASCADE ON DELETE SET NULL,
    CHECK (Price >= 0)
);

-- Orders Table
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON UPDATE CASCADE ON DELETE SET NULL
);

-- OrderDetails Table
CREATE TABLE OrderDetails (
    OrderDetailID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE SET NULL
);

-- Payments Table
CREATE TABLE Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    Amount DECIMAL(10, 2) NOT NULL,
    PaymentDate DATE,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    CHECK (Amount >= 0)
);

-- Discounts Table
CREATE TABLE Discounts (
    DiscountID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT,
    DiscountAmount DECIMAL(10, 2) NOT NULL,
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    CHECK (DiscountAmount >= 0)
);

-- OrderStatusHistory Table
CREATE TABLE OrderStatusHistory (
    HistoryID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    Status VARCHAR(50) NOT NULL,
    ChangeDate DATE,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE
);

-- InventoryLog Table
CREATE TABLE InventoryLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT,
    QuantityChanged INT NOT NULL,
    LogDate DATE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
);


-- Reviews Table
CREATE TABLE Reviews (
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT,
    CustomerID INT,
    Rating INT NOT NULL,
    ReviewText TEXT,
    ReviewDate DATE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE SET NULL,
    CHECK (Rating >= 1 AND Rating <= 5)
);

-- Rewards Table
CREATE TABLE Rewards (
    RewardID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    Points INT NOT NULL,
    RewardDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON UPDATE CASCADE ON DELETE CASCADE,
    CHECK (Points >= 0)
);

-- CartDetails Table
CREATE TABLE Cart (
    CartID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    ProductID INT NOT NULL,
    Quantity INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES products(ProductID) ON UPDATE CASCADE ON DELETE CASCADE,
    CHECK (Quantity > 0)
);
