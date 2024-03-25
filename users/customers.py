import sys


import warnings

warnings.filterwarnings("ignore", category=DeprecationWarning)
from common_functions import connect_to_database, execute_query, execute_stored_procedure

conn = connect_to_database()

# Check if command-line arguments are provided
if len(sys.argv) < 1:
    print("Usage: python script.py <user_id> ...")
    sys.exit(1)

user_id = sys.argv[1]
print("Script:", user_id)

user_details = execute_query(conn, f"select * from user_info where CustomerID = {user_id}")
print(user_details)

order_history = execute_query(conn, f"select * from user_orders where CustomerID = {user_id}")
print(order_history)

top_selling = execute_query(conn, "select * from top_selling_products")
print(top_selling)

top_rated = execute_query(conn, "select * from top_rated_products")
print(top_rated)

# Example usage
customer_id = 1
order_details = '[{"product_id": 1, "quantity": 2}, {"product_id": 2, "quantity": 3}]'

modify_add_discount = execute_stored_procedure(conn, 'PlaceOrder', [customer_id, order_details])
conn.commit()
print("discount added/modified successfully")

conn.close()