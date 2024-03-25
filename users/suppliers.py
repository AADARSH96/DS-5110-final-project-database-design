import sys


from common_functions import connect_to_database, execute_query

conn = connect_to_database()

# Check if command-line arguments are provided
if len(sys.argv) < 1:
    print("Usage: python script.py <user_name> ...")
    sys.exit(1)

supplier_id = sys.argv[1]
print("supplier id:", supplier_id)

supplier_details = execute_query(conn, f"select * from supplier_info where SupplierID = {supplier_id}")
print(supplier_details)

#order_history = execute_query(conn, f"select * from OrderHistoryWithStatus where CustomerID = {supplier_id}")
#print(order_history)

#top_selling = execute_query(conn, "select * from TopSellingProducts")
#print(top_selling)

#top_rated = execute_query(conn, "select * from TopRatedProducts")
#print(top_rated)
