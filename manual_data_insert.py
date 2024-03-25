import decimal
import random

import mysql.connector
from faker import Faker
from mysql.connector import errorcode

# Connect to MySQL server
try:
    conn = mysql.connector.connect(host='127.0.0.1',
                                   database='inventory_db_new',
                                   user='root',
                                   password='')
    cursor = conn.cursor()

except mysql.connector.Error as err:
    if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
        print("Something is wrong with your username or password")
    elif err.errno == errorcode.ER_BAD_DB_ERROR:
        print("Database does not exist")
    else:
        print(err)

# Create Faker instance for generating fake data
fake = Faker()

# Insert data into Categories table
categories = ["Electronics", "Clothing", "Books", "Toys", "Furniture"]
for category in categories:
    cursor.execute("INSERT INTO Categories (Name) VALUES (%s)", (category,))
conn.commit()

# Insert data into Suppliers table
for _ in range(40):
    supplier_name = fake.company()
    phone_number = fake.phone_number()
    address = fake.address()
    email = fake.email()
    cursor.execute("INSERT INTO Suppliers (Name, PhoneNumber, Address, Email) VALUES (%s, %s, %s, %s)",
                   (supplier_name, phone_number, address, email))
conn.commit()

# Insert data into Customers table
for _ in range(40):
    customer_name = fake.name()
    phone_number = fake.phone_number()
    address = fake.address()
    email = fake.email()
    cursor.execute("INSERT INTO Customers (Name, PhoneNumber, Address, Email) VALUES (%s, %s, %s, %s)",
                   (customer_name, phone_number, address, email))
conn.commit()

# Insert data into Products table
for _ in range(40):
    product_name = fake.word().capitalize() + " " + fake.word().capitalize()
    description = fake.sentence()
    price = round(random.uniform(10, 1000), 2)
    category_id = random.randint(1, len(categories))
    supplier_id = random.randint(1, 40)
    cursor.execute(
        "INSERT INTO Products (Name, Description, Price, CategoryID, SupplierID) VALUES (%s, %s, %s, %s, %s)",
        (product_name, description, price, category_id, supplier_id))
conn.commit()

# Insert data into Orders table
for _ in range(40):
    customer_id = random.randint(1, 40)
    order_date = fake.date_between(start_date='-1y', end_date='today')
    total_amount = 0
    cursor.execute("INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES (%s, %s, %s)",
                   (customer_id, order_date, total_amount))
    order_id = cursor.lastrowid
    for _ in range(random.randint(1, 5)):
        product_id = random.randint(1, 40)
        quantity = random.randint(1, 10)
        cursor.execute("SELECT Price FROM Products WHERE ProductID = %s", (product_id,))
        price = cursor.fetchone()[0]  # Fetch the price from the database
        total_amount += price * quantity
        cursor.execute("INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES (%s, %s, %s)",
                       (order_id, product_id, quantity))
    cursor.execute("UPDATE Orders SET TotalAmount = %s WHERE OrderID = %s",
                   (total_amount, order_id))
    # Fetch the total amount for the order
    cursor.execute("SELECT TotalAmount FROM Orders WHERE OrderID = %s", (order_id,))
    amount = cursor.fetchone()[0]  # Fetch the amount from the database
    payment_date = fake.date_between(start_date='-1y', end_date='today')
    cursor.execute("INSERT INTO Payments (OrderID, Amount, PaymentDate) VALUES (%s, %s, %s)",
                   (order_id, amount, payment_date))
    conn.commit()

# Insert data into Payments table
for order_id in range(1, 41):
    # Fetch total amount for the order
    cursor.execute(
        "SELECT SUM(Price * Quantity) FROM OrderDetails JOIN Products ON OrderDetails.ProductID = Products.ProductID WHERE OrderDetails.OrderID = %s",
        (order_id,))
    total_amount_result = cursor.fetchone()
    if total_amount_result[0] is not None:
        total_amount = total_amount_result[0]

        # Fetch total quantity for the order
        cursor.execute("SELECT SUM(Quantity) FROM OrderDetails WHERE OrderID = %s", (order_id,))
        total_quantity_result = cursor.fetchone()
        if total_quantity_result[0] is not None:
            total_quantity = total_quantity_result[0]

            # Insert payment record
            payment_date = fake.date_between(start_date='-1y', end_date='today')
            cursor.execute("INSERT INTO Payments (OrderID, Amount, PaymentDate) VALUES (%s, %s, %s)",
                           (order_id, total_amount, payment_date))
    conn.commit()

# Insert data into OrderStatusHistory table
for order_id in range(1, 41):
    status = random.choice(["Pending", "Processing", "Shipped", "Delivered"])
    change_date = fake.date_between(start_date='-1y', end_date='today')

    cursor.execute("INSERT INTO OrderStatusHistory (OrderID, Status, ChangeDate) VALUES (%s, %s, %s)",
                   (order_id, status, change_date))

conn.commit()

# Fetch valid OrderIDs and corresponding order dates from Orders table
cursor.execute("SELECT OrderID FROM Orders")
order_ids = [row[0] for row in cursor.fetchall()]

# Insert data into InventoryLog table with valid OrderID, matching quantity, and corresponding order date
for order_id in order_ids:
    # Fetch product IDs and quantities from OrderDetails for the current order
    cursor.execute("SELECT ProductID, Quantity FROM OrderDetails WHERE OrderID = %s", (order_id,))
    order_details = cursor.fetchall()

    # Insert inventory log for each product in the order
    for product_id, quantity in order_details:
        # Set QuantityChanged to negative of the quantity in OrderDetails
        quantity_changed = -quantity

        # Fetch order date from Orders table
        cursor.execute("SELECT OrderDate FROM Orders WHERE OrderID = %s", (order_id,))
        order_date = cursor.fetchone()[0]

        # Generate log date within the range of the order date
        log_date = fake.date_between(start_date='-1y', end_date=order_date)

        cursor.execute(
            "INSERT INTO InventoryLog (ProductID, QuantityChanged, OrderID, LogDate) VALUES (%s, %s, %s, %s)",
            (product_id, quantity_changed, order_id, log_date))

conn.commit()


# Function to insert reviews for a product
def insert_reviews(product_id, num_reviews):
    for _ in range(num_reviews):
        rating = random.randint(1, 5)  # Random rating between 1 and 5
        review_text = fake.paragraph()  # Generate random review text
        cursor.execute("INSERT INTO Reviews (ProductID, Rating, ReviewText) VALUES (%s, %s, %s)",
                       (product_id, rating, review_text))
    conn.commit()


# Retrieve list of product IDs from the database
cursor.execute("SELECT ProductID FROM Products")
product_ids = [row[0] for row in cursor.fetchall()]

# Insert reviews for each product
for product_id in product_ids:
    # Determine the number of reviews needed to reach the minimum of 5
    cursor.execute("SELECT COUNT(*) FROM Reviews WHERE ProductID = %s", (product_id,))
    existing_reviews = cursor.fetchone()[0]
    remaining_reviews = max(0, 5 - existing_reviews)  # Calculate remaining reviews needed
    if remaining_reviews > 0:
        insert_reviews(product_id, remaining_reviews)

# Calculate and insert data into Rewards table
for customer_id in range(1, 41):
    cursor.execute(
        "SELECT SUM(Price * Quantity) FROM OrderDetails JOIN Products ON OrderDetails.ProductID = Products.ProductID JOIN Orders ON OrderDetails.OrderID = Orders.OrderID WHERE Orders.CustomerID = %s",
        (customer_id,))
    result = cursor.fetchone()
    total_amount = decimal.Decimal(result[0]) if result[0] is not None else decimal.Decimal(0)
    points = round(float(total_amount) * 0.1)  # Assuming 1 point for every $10 spent
    reward_date = fake.date_between(start_date='-1y', end_date='today')
    cursor.execute("INSERT INTO Rewards (CustomerID, Points, RewardDate) VALUES (%s, %s, %s)",
                   (customer_id, points, reward_date))
conn.commit()

# Fetch product IDs from the Products table
cursor.execute("SELECT ProductID FROM Products")
product_ids = [row[0] for row in cursor.fetchall()]

# Insert data into Discounts table
for product_id in product_ids[:20]:  # Only apply discounts to the first 20 products
    discount_amount = round(random.uniform(0.01, 100), 2)  # Random discount amount between 0.01 and 100
    start_date = fake.date_between(start_date='-1y', end_date='today')
    end_date = fake.date_between(start_date=start_date, end_date='+1y')  # End date after start date

    cursor.execute("INSERT INTO Discounts (ProductID, DiscountAmount, StartDate, EndDate) VALUES (%s, %s, %s, %s)",
                   (product_id, discount_amount, start_date, end_date))

conn.commit()

# Close the connection
cursor.close()
conn.close()
