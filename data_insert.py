import os
import pandas as pd
from common_functions import connect_to_database

conn = connect_to_database()
cursor = conn.cursor()

csv_directory = '/Users/aadarsh/PycharmProjects/DS-5110-final-project/Excel/'

file_names_in_order = ['Categories.csv', 'Suppliers.csv', 'Products.csv', 'Discounts.csv', 'Customers.csv'
    , 'InventoryLog.csv', 'Orders.csv', 'OrderDetails.csv', 'Orderstatushistory.csv'
    , 'Payments.csv', 'Reviews.csv', 'Rewards.csv', 'Cart.csv']

for csv_file in file_names_in_order:
    df = pd.read_csv(os.path.join(csv_directory, csv_file))
    table_name = os.path.splitext(csv_file)[0]  # Use the file name (without extension) as the table name
    for index, row in df.iterrows():
        insert_query = f"INSERT INTO {table_name} VALUES ({', '.join(['%s'] * len(row))})"
        cursor.execute(insert_query, tuple(row))

    print(f"Data from '{csv_file}' loaded into '{table_name}' successfully!")

conn.commit()
cursor.close()
conn.close()
