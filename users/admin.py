from common_functions import connect_to_database, execute_stored_procedure, execute_query

conn = connect_to_database()
try:
    '''add_product = execute_stored_procedure(conn, 'AddProduct',
                                           ('Almost Man5', 'Understand low strong data skill although.', 28.46, 4, 6,))

    conn.commit()
    print("Product added successfully")

    modify_product = execute_stored_procedure(conn, 'ModifyProduct', (
                    43, None, 'Understand low strong data skill although hello.', None, None, None,))
    conn.commit()
    print("Product modified successfully")'''

    '''delete_product = execute_stored_procedure(conn, 'DeleteProduct', (50,))
    conn.commit()
    print("Product deleted successfully")

    modify_add_discount = execute_stored_procedure(conn, 'ModifyOrAddDiscount', (42,10,'2023-09-14','2024-09-05'))
    conn.commit()
    print("discount added/modified successfully")

    delete_discount = execute_stored_procedure(conn, 'DeleteDiscountsForProduct', (42,))
    conn.commit()
    print("discount deleted successfully")'''

    #update_status = execute_stored_procedure(conn, 'UpdateOrderStatus', (20,'Shipped'))
    #conn.commit()
    #print("Status updated successfully")

except Exception as err:
    print(err)
finally:
    conn.close()


'''stats = execute_query(conn, f"select * from admin_stats ")
print(stats)

order_count = execute_query(conn, f"select * from order_status_counts")
print(order_count)

Products_View = execute_query(conn, f"select * from products_info")
print(Products_View)'''