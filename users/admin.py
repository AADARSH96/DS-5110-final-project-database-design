from common_functions import connect_to_database, execute_stored_procedure, execute_query
from common_exceptions import WrongOption
import sys
from tabulate import tabulate

conn = connect_to_database()
try:
    # stats = execute_query(conn, f"select * from admin_stats ")
    # print("Admin Stats")
    # print(tabulate(stats, headers='keys'))

    # order_count = execute_query(conn, f"select * from order_status_counts")
    # print("Order Stats")
    # # print(order_count)
    # print(tabulate(order_count, headers='keys'))

    Products_View = execute_query(conn, f"select * from products_info")
    print("Products Info")
    # print(Products_View)
    print(tabulate(Products_View, headers='keys'))
except Exception as e:
    print(e)
    conn.close()
    sys.exit(1)
finally:
    conn.close()
    sys.exit(0)
