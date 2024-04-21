import mysql.connector
from mysql.connector import Error
from prettytable import PrettyTable

def connect_to_db():
    db_config = {
        'user': 'root',
        'password': '12345678',
        'host': 'localhost',
        'port': 3306,
        'database': 'fms'
    }
    try:
        conn = mysql.connector.connect(**db_config)
        print("\nSuccessfully connected to the FMS database.")
        return conn
    except Error as err:
        print(f"\nConnection error: {err}")
        exit(1)

def display_data(connection, query, params=None):
    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute(query, params)
        results = cursor.fetchall()
        if not results:
            print("\nNo data found.")
        else:
            table = PrettyTable()
            table.field_names = [i[0] for i in cursor.description]  # Set table headers to column names
            for row in results:
                table.add_row([row[col] for col in table.field_names])
            print(table)
    finally:
        cursor.close()

def execute_sql(connection, query, data=None, is_select=False):
    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute(query, data if data else None)
        if is_select:
            result = cursor.fetchall()
            if not result:
                print("\nNo data found.")
            else:
                table = PrettyTable()
                table.field_names = [i[0] for i in cursor.description]
                for row in result:
                    table.add_row([row[col] for col in table.field_names])
                print(table)
        else:
            connection.commit()
            print("\nOperation was successful.")
    finally:
        cursor.close()

def execute_custom_sql(connection):
    print("\nWarning: This feature allows execution of direct SQL commands and should be used with caution.")
    sql_command = input("Please enter your SQL command: ").strip()
    is_select = sql_command.lower().startswith('select')
    try:
        execute_sql(connection, sql_command, is_select=is_select)
    except Exception as e:
        print(f"An error occurred: {e}")




def advanced_olap_operations(connection):
    while True:
        print("\nAdvanced OLAP Operations:")
        print("1. Average Maintenance Costs by Vehicle Model")
        print("2. Total Trips and Distance by Driver with Ranking")
        print("3. Fuel Efficiency per Vehicle Model")
        print("4. Vehicle Utilization Rates")
        print("5. Monthly Fuel Costs with CUME_DIST")
        print("6. Driver Performance Analysis")
        print("7. Monthly Cost Trends (Maintenance + Fuel Combined)")
        print("8. Seasonal Impact on Vehicle Usage")
        print("9. Detailed Driver Performance Analysis")
        print("10. Vehicles by Location Frequency")
        print("11. Combine tables using UNION")
        print("12. Print common values using INNER JOIN")
        print("13. Return to Previous Menu")
        choice = input("Select an operation: ")

        queries = {
            '1': """
            SELECT Vehicle.model, AVG(Maintenance.cost) AS average_maintenance_cost
            FROM Maintenance
            JOIN Vehicle ON Maintenance.Vehicle_ID = Vehicle.ID
            GROUP BY Vehicle.model
            """,
            '2': """
            SELECT Driver.name, COUNT(Trip.ID) AS total_trips, SUM(Trip.end_odometer - Trip.start_odometer) AS total_distance,
                   RANK() OVER (ORDER BY SUM(Trip.end_odometer - Trip.start_odometer) DESC) AS driver_rank
            FROM Trip
            JOIN Driver ON Trip.driver_ID = Driver.ID
            GROUP BY Driver.name
            """,
            '3': """
            SELECT Vehicle.model, AVG(Trip.end_odometer - Trip.start_odometer) / AVG(Fuel.gallons_purchased) AS average_fuel_efficiency
            FROM Trip
            JOIN Vehicle ON Trip.Vehicle_ID = Vehicle.ID
            LEFT JOIN Fuel ON Vehicle.ID = Fuel.vehicle_ID AND DATEDIFF(Trip.end_datetime, Fuel.date) BETWEEN -1 AND 1
            GROUP BY Vehicle.model
            """,
            '4': """
            SELECT Vehicle.model, COUNT(Trip.ID) AS usage_count
            FROM Vehicle
            JOIN Trip ON Vehicle.ID = Trip.Vehicle_ID
            GROUP BY Vehicle.model
            ORDER BY usage_count DESC
            """,
            '5': """
            SELECT MONTH(Fuel.date) AS month, SUM(Fuel.total_cost) AS total_monthly_cost,
                   CUME_DIST() OVER (ORDER BY SUM(Fuel.total_cost)) AS cumulative_distribution
            FROM Fuel
            GROUP BY month
            ORDER BY month
            """,
            '6': """
            SELECT Driver.name, AVG(Trip.end_odometer - Trip.start_odometer) AS average_distance_per_trip
            FROM Trip
            JOIN Driver ON Trip.driver_ID = Driver.ID
            GROUP BY Driver.name
            ORDER BY average_distance_per_trip DESC
            """,
            '7': """
            SELECT MONTH(Maintenance.date) AS month, SUM(Maintenance.cost + IFNULL(Fuel.total_cost, 0)) AS total_cost
            FROM Maintenance
            LEFT JOIN Fuel ON MONTH(Maintenance.date) = MONTH(Fuel.date)
            GROUP BY month
            ORDER BY month
            """,
            '8': """
            SELECT MONTH(Trip.start_datetime) AS month, COUNT(*) AS trip_count
            FROM Trip
            GROUP BY month
            ORDER BY month
            """,
            '9': """
            SELECT Driver.name, AVG(Trip.end_odometer - Trip.start_odometer) AS average_distance_per_trip, COUNT(Trip.ID) AS number_of_trips
            FROM Trip
            JOIN Driver ON Trip.driver_ID = Driver.ID
            GROUP BY Driver.name
            HAVING number_of_trips >= 1
            ORDER BY average_distance_per_trip DESC
            """,
            '10': """
            SELECT address, COUNT(*) AS visit_count
            FROM Location
            GROUP BY address
            ORDER BY visit_count DESC
            """,
            '11':"""
            SELECT 'Vehicle' AS Type, ID, VIN, model, year, make FROM Vehicle
            UNION
            SELECT 'Driver' AS Type, ID, name, license_number, '', '' FROM Driver
            """,
            '12':""" 
            SELECT Vehicle.ID as Vehicle_ID, Vehicle.VIN, Vehicle.model, Vehicle.year, Vehicle.make, Vehicle.license_plate,
            Vehicle.odometer_reading, Vehicle.fuel_type, Vehicle.acquisition_date, Vehicle.status, 
            Vehicle.assigned_driver_ID,
            Driver.ID as Driver_ID, Driver.name as Driver_name, Driver.license_number, Driver.address as Driver_address, 
            Driver.contact_info, Driver.hire_date, Driver.driving_record
            FROM Vehicle
            INNER JOIN Driver ON Vehicle.assigned_driver_ID = Driver.ID
            """

        }

        if choice == '13':
            break
        elif choice in queries:
            display_data(connection, queries[choice])
        else:
            print("Invalid choice.")







def driver_crud_operations(connection):
    while True:
        print("\nDriver Operations:")
        print("1. Display Drivers")
        print("2. Read Driver Details")
        print("3. Add Driver")
        print("4. Update Driver")
        print("5. Delete Driver")
        print("6. Go back to main menu")
        print("7. Exit")
        choice = input("Select an operation: ")

        if choice == '1':
            query = "SELECT * FROM Driver"
            display_data(connection, query)

        elif choice == '2':
            # Read Driver Details
            driver_id = input("Enter Driver ID: ")
            query = "SELECT * FROM Driver WHERE ID = %s"
            display_data(connection, query, (driver_id,))

        elif choice == '3':
            driver_data = (
                input("Enter ID: "),
                input("Enter Name: "),
                input("Enter License Number: "),
                input("Enter Address: "),
                input("Enter Contact Info: "),
                input("Enter Hire Date (YYYY-MM-DD): "),
                input("Enter Driving Record: ")
            )
            query = """
                INSERT INTO Driver
                (ID, name, license_number, address, contact_info, hire_date, driving_record)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            execute_sql(connection, query, driver_data)

        elif choice == '4':
            id = input("Enter Driver ID to update: ")
            new_address = input("Enter new address: ")
            query = "UPDATE Driver SET address = %s WHERE ID = %s"
            execute_sql(connection, query, (new_address, id))

        elif choice == '5':
            id = input("Enter Driver ID to delete: ")
            query = "DELETE FROM Driver WHERE ID = %s"
            execute_sql(connection, query, (id,))

        elif choice == '6':
            break
        elif choice == '7':
            print("\nThank you for using the Fleet Management System. Goodbye!")
            connection.close()
            exit()
        else:
            print("Invalid choice.")

def vehicle_crud_operations(connection):
    while True:
        print("\nVehicle Operations:")
        print("1. Display Vehicles")
        print("2. Add Vehicle")
        print("3. Update Vehicle")
        print("4. Delete Vehicle")
        print("5. Go back to main menu")
        print("6. Exit")
        choice = input("Select an operation: ")

        if choice == '1':
            query = "SELECT * FROM Vehicle"
            display_data(connection, query)

        elif choice == '2':
            vehicle_data = (
                input("Enter ID: "),
                input("Enter VIN: "),
                input("Enter Model: "),
                input("Enter Year: "),
                input("Enter Make: "),
                input("Enter License Plate: "),
                input("Enter Odometer Reading: "),
                input("Enter Fuel Type: "),
                input("Enter Acquisition Date (YYYY-MM-DD): "),
                input("Enter Status: "),
                input("Enter Assigned Driver ID: ")
            )
            query = """
                INSERT INTO Vehicle
                (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            execute_sql(connection, query, vehicle_data)

        elif choice == '3':
            id = input("Enter Vehicle ID to update: ")
            new_status = input("Enter new status: ")
            new_odometer_reading = input("Enter new odometer reading: ")
            query = "UPDATE Vehicle SET status = %s, odometer_reading = %s WHERE ID = %s"
            execute_sql(connection, query, (new_status, new_odometer_reading, id))

        elif choice == '4':
            id = input("Enter Vehicle ID to delete: ")
            query = "DELETE FROM Vehicle WHERE ID = %s"
            execute_sql(connection, query, (id,))

        elif choice == '5':
            break
        elif choice == '6':
            print("\nThank you for using the Fleet Management System. Goodbye!")
            connection.close()
            exit()
        else:
            print("Invalid choice.")

def inventory_crud_operations(connection):
    while True:
        print("\nInventory Operations:")
        print("1. Display Inventory")
        print("2. Add Inventory Item")
        print("3. Update Inventory Item")
        print("4. Delete Inventory Item")
        print("5. Go back to main menu")
        print("6. Exit")
        choice = input("Select an operation: ")

        if choice == '1':
            query = "SELECT * FROM Inventory"
            display_data(connection, query)

        elif choice == '2':
            inventory_data = (
                input("Enter ID: "),
                input("Enter Name: "),
                input("Enter Description: "),
                input("Enter Stock Level: "),
                input("Enter Unit Price: "),
                input("Enter Supplier: "),
                input("Enter Reorder Point: ")
            )
            query = """
                INSERT INTO Inventory
                (ID, name, description, stock_level, unit_price, supplier, reorder_point)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            execute_sql(connection, query, inventory_data)

        elif choice == '3':
            id = input("Enter Inventory ID to update: ")
            new_stock_level = input("Enter new stock level: ")
            new_reorder_point = input("Enter new reorder point: ")
            query = "UPDATE Inventory SET stock_level = %s, reorder_point = %s WHERE ID = %s"
            execute_sql(connection, query, (new_stock_level, new_reorder_point, id))

        elif choice == '4':
            id = input("Enter Inventory ID to delete: ")
            query = "DELETE FROM Inventory WHERE ID = %s"
            execute_sql(connection, query, (id,))

        elif choice == '5':
            break
        elif choice == '6':
            print("\nThank you for using the Fleet Management System. Goodbye!")
            connection.close()
            exit()
        else:
            print("Invalid choice.")

def maintenance_crud_operations(connection):
    while True:
        print("\nMaintenance Operations:")
        print("1. Display Maintenance Records")
        print("2. Add Maintenance Record")
        print("3. Update Maintenance Record")
        print("4. Delete Maintenance Record")
        print("5. Go back to main menu")
        print("6. Exit")
        choice = input("Select an operation: ")

        if choice == '1':
            query = "SELECT * FROM Maintenance"
            display_data(connection, query)

        elif choice == '2':
            maintenance_data = (
                input("Enter ID: "),
                input("Enter Vehicle ID: "),
                input("Enter Date (YYYY-MM-DD): "),
                input("Enter Type: "),
                input("Enter Mileage: "),
                input("Enter Cost: "),
                input("Enter Description: "),
                input("Enter Technician: "),
                input("Enter Next Service Due Date (YYYY-MM-DD): "),
                input("Enter Part Used: ")
            )
            query = """
                INSERT INTO Maintenance
                (ID, vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            execute_sql(connection, query, maintenance_data)

        elif choice == '3':
            id = input("Enter Maintenance Record ID to update: ")
            new_cost = input("Enter new cost: ")
            new_next_service_due = input("Enter new next service due date (YYYY-MM-DD): ")
            query = "UPDATE Maintenance SET cost = %s, next_service_due = %s WHERE ID = %s"
            execute_sql(connection, query, (new_cost, new_next_service_due, id))

        elif choice == '4':
            id = input("Enter Maintenance Record ID to delete: ")
            query = "DELETE FROM Maintenance WHERE ID = %s"
            execute_sql(connection, query, (id,))

        elif choice == '5':
            break
        elif choice == '6':
            print("\nThank you for using the Fleet Management System. Goodbye!")
            connection.close()
            exit()
        else:
            print("Invalid choice.")

def fuel_crud_operations(connection):
    while True:
        print("\nFuel Log Operations:")
        print("1. Display Fuel Logs")
        print("2. Add Fuel Log")
        print("3. Update Fuel Log")
        print("4. Delete Fuel Log")
        print("5. Go back to main menu")
        print("6. Exit")
        choice = input("Select an operation: ")

        if choice == '1':
            query = "SELECT * FROM Fuel"
            display_data(connection, query)

        elif choice == '2':
            fuel_data = (
                input("Enter Vehicle ID: "),
                input("Enter Date (YYYY-MM-DD): "),
                input("Enter Gallons Purchased: "),
                input("Enter Odometer Reading: "),
                input("Enter Price Per Gallon: "),
                input("Enter Fuel Station: ")
            )
            query = """
                INSERT INTO Fuel
                (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, fuel_station)
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            execute_sql(connection, query, fuel_data)

        elif choice == '3':
            id = input("Enter Fuel Log ID to update: ")
            new_odometer_reading = input("Enter new odometer reading: ")
            query = "UPDATE Fuel SET odometer_reading = %s WHERE ID = %s"
            execute_sql(connection, query, (new_odometer_reading, id))

        elif choice == '4':
            id = input("Enter Fuel Log ID to delete: ")
            query = "DELETE FROM Fuel WHERE ID = %s"
            execute_sql(connection, query, (id,))

        elif choice == '5':
            break
        else:
            print("Invalid choice.")

def trips_crud_operations(connection):
    while True:
        print("\nTrip Operations:")
        print("1. Display Trips")
        print("2. Add Trip")
        print("3. Update Trip")
        print("4. Delete Trip")
        print("5. Go back to main menu")
        print("6. Exit")
        choice = input("Select an operation: ")

        if choice == '1':
            query = "SELECT * FROM Trip"
            display_data(connection, query)

        elif choice == '2':
            trip_data = (
                input("Enter Vehicle ID: "),
                input("Enter Driver ID: "),
                input("Enter Start Datetime (YYYY-MM-DD HH:MM:SS): "),
                input("Enter End Datetime (YYYY-MM-DD HH:MM:SS): "),
                input("Enter Start Odometer: "),
                input("Enter End Odometer: "),
                input("Enter Destination: "),
                input("Enter Purpose: "),
                input("Enter Notes: ")
            )
            query = """
                INSERT INTO Trip
                (vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            execute_sql(connection, query, trip_data)

        elif choice == '3':
            id = input("Enter Trip ID to update: ")
            new_purpose = input("Enter new purpose: ")
            query = "UPDATE Trip SET purpose = %s WHERE ID = %s"
            execute_sql(connection, query, (new_purpose, id))

        elif choice == '4':
            id = input("Enter Trip ID to delete: ")
            query = "DELETE FROM Trip WHERE ID = %s"
            execute_sql(connection, query, (id,))

        elif choice == '5':
            break
        elif choice == '6':
            print("\nThank you for using the Fleet Management System. Goodbye!")
            connection.close()
            exit()
        else:
            print("Invalid choice.")

def location_crud_operations(connection):
    while True:
        print("\nLocation Operations:")
        print("1. Display Locations")
        print("2. Add Location")
        print("3. Update Location")
        print("4. Delete Location")
        print("5. Go back to main menu")
        print("6. Exit")
        choice = input("Select an operation: ")

        if choice == '1':
            query = "SELECT * FROM Location"
            display_data(connection, query)

        elif choice == '2':
            location_data = (
                input("Enter Vehicle ID: "),
                input("Enter Datetime (YYYY-MM-DD HH:MM:SS): "),
                input("Enter GPS Coordinates: "),
                input("Enter Address: ")
            )
            query = """
                INSERT INTO Location
                (vehicle_ID, datetime, GPS_coordinates, address)
                VALUES (%s, %s, %s, %s)
            """
            execute_sql(connection, query, location_data)

        elif choice == '3':
            id = input("Enter Location ID to update: ")
            new_address = input("Enter new address: ")
            query = "UPDATE Location SET address = %s WHERE ID = %s"
            execute_sql(connection, query, (new_address, id))

        elif choice == '4':
            id = input("Enter Location ID to delete: ")
            query = "DELETE FROM Location WHERE ID = %s"
            execute_sql(connection, query, (id,))

        elif choice == '5':
            break
        elif choice == '6':
            print("\nThank you for using the Fleet Management System. Goodbye!")
            connection.close()
            exit()
        else:
            print("Invalid choice.")






def crud_menu(connection):
    while True:
        print("\nCRUD Operations:")
        print("1. Vehicle Management")
        print("2. Driver Management")
        print("3. Inventory Management")
        print("4. Maintenance Management")
        print("5. Fuel Log Management")
        print("6. Trip Management")
        print("7. Location Management")
        print("8. Return to Main Menu")
        choice = input("Select an operation: ")

        if choice == '1':
            vehicle_crud_operations(connection)
        elif choice == '2':
            driver_crud_operations(connection)
        elif choice == '3':
            inventory_crud_operations(connection)
        elif choice == '4':
            maintenance_crud_operations(connection)
        elif choice == '5':
            fuel_crud_operations(connection)
        elif choice == '6':
            trips_crud_operations(connection)
        elif choice == '7':
            location_crud_operations(connection)
        elif choice == '8':
            break
        else:
            print("Invalid choice.")

def main_menu():
    connection = connect_to_db()
    while True:
        print("\n========== Main Menu: Fleet Management System ==========")
        print("1. CRUD Operations")
        print("2. Advanced OLAP Operations")
        print("3. Execute Custom SQL Command")
        print("4. Exit - Close the application.")
        choice = input("\nPlease choose an option (1-4): ")

        if choice == '1':
            crud_menu(connection)
        elif choice == '2':
            advanced_olap_operations(connection)
        elif choice == '3':
            execute_custom_sql(connection)
        elif choice == '4':
            print("\nThank you for using the Fleet Management System. Goodbye!")
            connection.close()
            exit()
        else:
            print("\nInvalid choice. Please select a number between 1-4.")

if __name__ == "__main__":
    main_menu()
