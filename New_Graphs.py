import mysql.connector
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from common_functions import execute_query,connect_to_database
from common_functions import connect_to_database, execute_query, execute_stored_procedure
from common_exceptions import UserError, WrongOption

conn = connect_to_database()

try:
    fig, axes = plt.subplots()  # Increase the size of the subplots

    print("Which graph you want to see:")
    print("1.Bar graph(Customer Distribution by Category)")
    print("1.Bar graph(Top 5 Suppliers by Revenue)")
    print("1.Pie Chart(Distribution of Products Supplied by Suppliers)")
    print("1.Bar graph(Top Selling Products)")

    option = int(input("Enter your option: "))

    if option == 1:
        try:
            # Query to retrieve data for the first graph
            query1 = "SELECT Category, COUNT(*) AS TotalCustomers FROM user_info GROUP BY Category"
            df1 = execute_query(conn, query1)
            if df1 is not None:
                # Plotting the first graph (bar plot for customer distribution by category)
                axes.bar(df1['Category'], df1['TotalCustomers'], color='Pink')
                axes.set_title('Customer Distribution by Category', color='Red', size=15)
                axes.set_xlabel('Category', fontsize=10, color='Purple')
                axes.set_ylabel('Number of Customers', color='Purple')
                axes.tick_params(axis='x', rotation=0)

            plt.tight_layout()

            plt.show()

        except Exception as err:
            print(f"Error: {err}")

    elif option == 2:
        try:
            # Query to retrieve data for the first graph
            query2 = "SELECT SupplierName, SupplierRevenue FROM supplier_info ORDER BY SupplierRevenue DESC LIMIT 5"
            df2 = execute_query(conn, query2)
            if df2 is not None:
                # Plotting the second graph (top 5 suppliers by revenue)
                axes.bar(df2['SupplierName'], df2['SupplierRevenue'], color='lightgreen', width=0.4)
                axes.set_title('Top 5 Suppliers by Revenue', color='Red')
                axes.set_xlabel('Supplier Name', color='Orange')
                axes.set_ylabel('Revenue', color='Orange')
                axes.tick_params(axis='x', rotation=0, labelsize=8, pad=10)

            plt.tight_layout()

            plt.show()

        except Exception as err:
            print(f"Error: {err}")

    elif option == 3:
        try:
            query3 = ("SELECT SupplierName, NumberOfProductsSupplied FROM supplier_info ORDER BY "
                      "NumberOfProductsSupplied DESC")
            df3 = execute_query(conn, query3)
            if df3 is not None:
                # Plotting the third graph (pie chart for distribution of products supplied by suppliers)
                axes.pie(df3['NumberOfProductsSupplied'], labels=df3['SupplierName'], autopct='%1.1f%%',
                               startangle=80)
                axes.set_title('Distribution of Products Supplied by Suppliers', fontsize=14, color='Red')

            plt.tight_layout()

            plt.show()

        except Exception as err:
            print(f"Error: {err}")

    elif option == 4:
        try:
            # Query to retrieve data for the fourth graph (top selling products)
            query4 = "SELECT ProductName, TotalQuantitySold FROM top_selling_products"
            df4 = execute_query(conn, query4)
            if df4 is not None:
                # Plotting the fourth graph (bar chart for top selling products)
                axes.bar(df4['ProductName'], df4['TotalQuantitySold'], color='orange')
                axes.set_title('Top Selling Products', color='Red')
                axes.set_xlabel('Product Name', color='Purple', size=12)
                axes.set_ylabel('Total Quantity Sold', color='Purple', size=12)
                axes.tick_params(axis='x', rotation=90)

            plt.tight_layout()

            plt.show()

        except Exception as err:
            print(f"Error: {err}")

    else:
        raise WrongOption(f"Option {option} is not available. Please choose from 1-4 options ")

finally:
    conn.close()
