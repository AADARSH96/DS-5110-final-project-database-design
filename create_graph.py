import mysql.connector
import pandas as pd
import matplotlib.pyplot as plt
from common_functions import execute_query,connect_to_database

conn = connect_to_database()

try:
    fig, axes = plt.subplots(2, 2, figsize=(20, 15))  # Increase the size of the subplots

    # Query to retrieve data for the first graph
    query1 = "SELECT Category, COUNT(*) AS TotalCustomers FROM user_info GROUP BY Category"
    df1 = execute_query(conn, query1)
    if df1 is not None:
        # Plotting the first graph (bar plot for customer distribution by category)
        axes[0, 0].bar(df1['Category'], df1['TotalCustomers'], color='skyblue')
        axes[0, 0].set_title('Customer Distribution by Category')
        axes[0, 0].set_xlabel('Category')
        axes[0, 0].set_ylabel('Number of Customers')
        axes[0, 0].tick_params(axis='x', rotation=45)

    # Query to retrieve data for the second graph
    query2 = "SELECT SupplierName, SupplierRevenue FROM supplier_info ORDER BY SupplierRevenue DESC LIMIT 5"
    df2 = execute_query(conn, query2)
    if df2 is not None:
        # Plotting the second graph (top 5 suppliers by revenue)
        axes[0, 1].bar(df2['SupplierName'], df2['SupplierRevenue'], color='lightgreen')
        axes[0, 1].set_title('Top 5 Suppliers by Revenue')
        axes[0, 1].set_xlabel('Supplier Name')
        axes[0, 1].set_ylabel('Revenue')
        axes[0, 1].tick_params(axis='x', rotation=45)

    # Query to retrieve data for the third graph (distribution of products supplied by suppliers)
    query3 = "SELECT SupplierName, NumberOfProductsSupplied FROM supplier_info ORDER BY NumberOfProductsSupplied DESC"
    df3 = execute_query(conn, query3)
    if df3 is not None:
        # Plotting the third graph (pie chart for distribution of products supplied by suppliers)
        axes[1, 0].pie(df3['NumberOfProductsSupplied'], labels=df3['SupplierName'], autopct='%1.1f%%', startangle=140)
        axes[1, 0].set_title('Distribution of Products Supplied by Suppliers')

    # Query to retrieve data for the fourth graph (top selling products)
    query4 = "SELECT ProductName, TotalQuantitySold FROM top_selling_products"
    df4 = execute_query(conn, query4)
    if df4 is not None:
        # Plotting the fourth graph (bar chart for top selling products)
        axes[1, 1].bar(df4['ProductName'], df4['TotalQuantitySold'], color='orange')
        axes[1, 1].set_title('Top Selling Products')
        axes[1, 1].set_xlabel('Product Name')
        axes[1, 1].set_ylabel('Total Quantity Sold')
        axes[1, 1].tick_params(axis='x', rotation=45)

    plt.tight_layout()

    plt.show()

except Exception as err:
    print(f"Error: {err}")

finally:
    conn.close()
