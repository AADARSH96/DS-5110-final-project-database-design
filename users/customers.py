import sys
import warnings
from common_functions import connect_to_database, execute_query, execute_stored_procedure
from common_exceptions import UserError, WrongOption

warnings.filterwarnings("ignore", category=DeprecationWarning)

conn = connect_to_database()

try:
    user_id = int(input("Enter your User Id:"))
    user_check = execute_query(conn, f"select * from customers where CustomerID = {user_id}")
    if user_check.empty:
        raise UserError(f"user id {user_id} does not exist. Please enter valid used id")
    print("User Id entered is:", user_id)

    print("What do you want to do - 1.View Products| 2.Add to Cart | 3.Place Order | 4.View Profile | 5.Top Products")
    option = int(input("Enter your option:"))
    if option == 1:
        products = execute_query(conn,
                                 """select ProductId,ProductName,Description,Price,
                                    Category,Supplier,SupplierEmail,AverageRating from products_info """
                                 )
        print(" Products")
        print(products)
    elif option == 2:
        product_id = input('Enter the Product ID (if multiple products enter by comma separated):')
        Quantity = input('Enter the Product Quantity(if multiple products enter by comma separated):')
        add_to_cart = execute_stored_procedure(conn, 'AddtoCart', (user_id, product_id, Quantity))
        conn.commit()
        print("added to cart successfully")
    elif option == 3:
        product_id = input('Enter the Product ID (if multiple products enter by comma seperated):')
        data = execute_stored_procedure(conn, 'PlaceOrder', (user_id, product_id))
        conn.commit()
        print("order placed successfully")
    elif option == 4:
        user_details = execute_query(conn, f"select * from user_info where CustomerID = {user_id}")
        print("Your Profile")
        print(user_details)

        order_history = execute_query(conn, f"select * from user_orders where CustomerID = {user_id}")
        print("Your order History")
        print(order_history)
    elif option == 5:
        top_selling = execute_query(conn, "select * from top_selling_products")
        print("Top Selling Products")
        print(top_selling)

        top_rated = execute_query(conn, "select * from top_rated_products")
        print("Top Rated Products")
        print(top_rated)
    else:
        raise WrongOption(f"Option {option} is not available. Please choose from 1,2,3,4,5 options ")
except UserError as e:
    print(e)
    conn.close()
    sys.exit(1)
except WrongOption as e:
    print(e)
    conn.close()
    sys.exit(1)
except Exception as e:
    print(e)
    conn.close()
    sys.exit(1)
finally:
    conn.close()
    sys.exit(0)
