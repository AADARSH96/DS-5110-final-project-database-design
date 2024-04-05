import sys
from common_functions import connect_to_database, execute_query, execute_stored_procedure
from common_exceptions import UserError, WrongOption
from getpass import getpass
import pyautogui
import ast
import pandas as pd
from tabulate import tabulate
conn = connect_to_database()

try:
    supplier_id = int(input("Enter your Supplier Id:"))
    supplier_check = execute_query(conn, f"select * from Suppliers where SupplierID = {supplier_id}")
    if supplier_check.empty:
        raise UserError(f"Supplier id {supplier_id} does not exist. Please enter valid Supplier id")
    print("Supplier Id entered is:", supplier_id)

    print("What do you want to do - 1.View Profile | 2.Add Product | 3.Modify Product")
    print("4.Delete Product | 5.Modify/Add Discount | 6.Delete Discount | 7.Add Product Quantity")
    print("8.Update Order Status")
    option = int(input("Enter your option: "))

    if option == 1:
        supplier_details = execute_query(conn, f"select * from supplier_info where SupplierID = {supplier_id}")
        df = pd.DataFrame(supplier_details)
        print("Your Profile")
        print(tabulate(df, headers='keys'))
    elif option == 2:
        product_name = input('Enter the Product Name:')
        product_description = input('Enter the Product Description:')
        price = input('Enter the Product price:')
        category_id = input('Enter the Product Category ID:')
        Quantity = input('Enter the Product Quantity:')
        #password = getpass('Enter the Supplier password:')
        password = pyautogui.password(text='Enter the Supplier password', title='', default='', mask='*')

        data = execute_stored_procedure(conn, 'AddProduct', (
            product_name, product_description, price, category_id, supplier_id, Quantity, password))
        conn.commit()
    elif option == 3:
        product_id = input('Enter the Product ID:')
        product_name = ast.literal_eval(input('Enter the Product Name:'))
        product_description = ast.literal_eval(input('Enter the Product Description:'))
        price = ast.literal_eval(input('Enter the Product price:'))
        category_id = ast.literal_eval(input('Enter the Product Category ID:'))
        password = pyautogui.password(text='Enter the Supplier password', title='', default='', mask='*')

        data = execute_stored_procedure(conn, 'ModifyProduct',
                                        (product_id, product_name, product_description, price, category_id, supplier_id,
                                         password))
        conn.commit()
    elif option == 4:
        product_id = input('Enter the Product ID:')
        password = pyautogui.password(text='Enter the Supplier password', title='', default='', mask='*')

        data = execute_stored_procedure(conn, 'DeleteProduct', (product_id, supplier_id, password))
        conn.commit()
    elif option == 5:
        product_id = input('Enter the Product ID:')
        discount_price = input('Enter the Product discount price:')
        start_date = input('Enter the discount start date in yyyy-mm-dd:')
        end_date = input('Enter the discount end date in yyyy-mm-dd:')
        password = pyautogui.password(text='Enter the Supplier password', title='', default='', mask='*')

        data = execute_stored_procedure(conn, 'ModifyOrAddDiscount',
                                        (product_id, supplier_id, discount_price, start_date, end_date, password))
        conn.commit()
    elif option == 6:
        product_id = input('Enter the Product ID:')
        password = pyautogui.password(text='Enter the Supplier password', title='', default='', mask='*')

        data = execute_stored_procedure(conn, 'DeleteDiscount', (product_id, supplier_id, password))
        conn.commit()
    elif option == 7:
        product_id = input('Enter the Product ID:')
        quantity = input('Enter the number of quantity to add:')
        password = pyautogui.password(text='Enter the Supplier password', title='', default='', mask='*')

        data = execute_stored_procedure(conn, 'AddProductQuantity', (product_id, quantity, supplier_id, password))
        conn.commit()
    elif option == 8:
        order_id = input('Enter the Order ID:')
        product_id = input('Enter the Product ID:')
        status = input('Enter the status of the product:')
        password = pyautogui.password(text='Enter the Supplier password', title='', default='', mask='*')

        data = execute_stored_procedure(conn, 'UpdateOrderStatus',
                                        (order_id, product_id, supplier_id, status, password))
        conn.commit()
    else:
        raise WrongOption(f"Option {option} is not available. Please choose from 1-8 options ")
except UserError as e:
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
