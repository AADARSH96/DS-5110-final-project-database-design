import mysql.connector
import pandas as pd
import warnings
import mysql.connector
from mysql.connector import errorcode

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)
pd.set_option('display.min_rows', None)
pd.set_option('display.expand_frame_repr', True)
warnings.filterwarnings("ignore", category=DeprecationWarning)


# Function to establish connection to MySQL database
def connect_to_database():
    # Connect to MySQL server
    try:
        return mysql.connector.connect(host='127.0.0.1',
                                       database='inventory_db',
                                       user='root',
                                       password='Raghuram@2000')
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            print("Something is wrong with your username or password")
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            print("Database does not exist")
        else:
            print(err)


# Function to execute a stored procedure
def execute_stored_procedure(conn, proc_name, params=None):
    cursor = conn.cursor()
    try:
        cursor.callproc(proc_name, params)
        for result in cursor.stored_results():
            data = result.fetchall()
            return data
    finally:
        cursor.close()


# Function to execute a query on a view
def execute_query(conn, query):
    cursor = conn.cursor()
    try:
        cursor.execute(query)
        rows = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]

        # Create a DataFrame from the rows and columns
        df = pd.DataFrame(rows, columns=columns)

        return df
    finally:
        cursor.close()
