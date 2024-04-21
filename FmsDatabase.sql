CREATE DATABASE fms;  
USE fms;             

-- Driver table creation
CREATE TABLE Driver (
  ID INT PRIMARY KEY,
  name VARCHAR(255),
  license_number VARCHAR(20) UNIQUE,
  address VARCHAR(255),
  contact_info VARCHAR(255),
  hire_date DATE,
  driving_record TEXT
);

-- Vehicle table creation
CREATE TABLE Vehicle (
  ID INT PRIMARY KEY,
  VIN VARCHAR(17) UNIQUE,
  model VARCHAR(255),
  year INT,
  make VARCHAR(255),
  license_plate VARCHAR(15) UNIQUE,
  odometer_reading INT,
  fuel_type VARCHAR(50),
  acquisition_date DATE,
  status VARCHAR(50),
  assigned_driver_ID INT,
  FOREIGN KEY (assigned_driver_ID) REFERENCES Driver(ID)
);


CREATE TABLE Inventory (
    ID INT PRIMARY KEY,
    name VARCHAR(255),
    description TEXT,
    recorder_point int,
    stock_level INT,
    unit_price DECIMAL(10,2),
    supplier VARCHAR(255),
    reorder_point INT
);

CREATE TABLE Maintenance (
   ID INT PRIMARY KEY,
    vehicle_ID INT,
    date DATE,
    type VARCHAR(50),
    mileage INT,
    cost DECIMAL(10,2),
    description TEXT,
    technician VARCHAR(255),
    next_service_due DATE,
    part_used INT,
    FOREIGN KEY (vehicle_ID) REFERENCES Vehicle(ID),
    FOREIGN KEY (part_used) REFERENCES Inventory(ID)
);

CREATE TABLE Fuel (
    ID INT PRIMARY KEY,
    vehicle_ID INT,
    date DATE,
    gallons_purchased DECIMAL(10,2),
    odometer_reading INT,
    price_per_gallon DECIMAL(10,2),
    total_cost DECIMAL(10,2),
    fuel_station VARCHAR(255),
    FOREIGN KEY (vehicle_ID) REFERENCES Vehicle(ID)
);

ALTER TABLE Fuel MODIFY total_cost DECIMAL(12,4);
ALTER TABLE Fuel MODIFY ID INT AUTO_INCREMENT;




CREATE TABLE Trip (
    ID INT PRIMARY KEY,
    vehicle_ID INT,
    driver_ID INT,
    start_datetime DATETIME,
    end_datetime DATETIME,
    start_odometer INT,
    end_odometer INT,
    destination VARCHAR(255),
    purpose VARCHAR(255),
    notes TEXT,
    FOREIGN KEY (vehicle_ID) REFERENCES Vehicle(ID),
    FOREIGN KEY (driver_ID) REFERENCES Driver(ID)
);


CREATE TABLE Location (
    ID INT PRIMARY KEY,
    vehicle_ID INT,
    datetime DATETIME,
    GPS_coordinates VARCHAR(255),
    address VARCHAR(255),
    FOREIGN KEY (vehicle_ID) REFERENCES Vehicle(ID)
);

CREATE INDEX idx_vehicle_id ON Vehicle(ID);  
CREATE INDEX idx_vehicle_vin ON Vehicle(VIN);  
CREATE INDEX idx_vehicle_model ON Vehicle(model);  
CREATE INDEX idx_vehicle_year ON Vehicle(year);  
CREATE INDEX idx_vehicle_make ON Vehicle(make);  
CREATE INDEX idx_vehicle_license_plate ON Vehicle(license_plate);  
CREATE INDEX idx_vehicle_odometer_reading ON Vehicle(odometer_reading);  
CREATE INDEX idx_vehicle_fuel_type ON Vehicle(fuel_type);  
CREATE INDEX idx_vehicle_acquisition_date ON Vehicle(acquisition_date);  
CREATE INDEX idx_vehicle_status ON Vehicle(status);  
CREATE INDEX idx_vehicle_assigned_driver_id ON Vehicle(assigned_driver_ID);  

CREATE INDEX idx_driver_id ON Driver (ID);  
CREATE INDEX idx_driver_name ON Driver (name);  
CREATE INDEX idx_driver_license_number ON Driver (license_number);  
CREATE INDEX idx_driver_address ON Driver (address);  
CREATE INDEX idx_driver_contact_info ON Driver (contact_info);  
CREATE INDEX idx_driver_hire_date ON Driver (hire_date);  

CREATE INDEX idx_maintenance_id ON Maintenance(ID);
CREATE INDEX idx_maintenance_vehicle_id ON Maintenance(vehicle_ID);
CREATE INDEX idx_maintenance_date ON Maintenance(date);
CREATE INDEX idx_maintenance_type ON Maintenance(type);
CREATE INDEX idx_maintenance_mileage ON Maintenance(mileage);
CREATE INDEX idx_maintenance_cost ON Maintenance(cost);
CREATE INDEX idx_maintenance_next_service_due ON Maintenance(next_service_due);
CREATE INDEX idx_maintenance_part_used ON Maintenance(part_used);
CREATE INDEX idx_maintenance_technician ON Maintenance(technician);

CREATE INDEX idx_fuel_id ON Fuel(ID);
   CREATE INDEX idx_fuel_vehicle_id ON Fuel(vehicle_ID);
   CREATE INDEX idx_fuel_date ON Fuel(date);
   CREATE INDEX idx_fuel_gallons_purchased ON Fuel(gallons_purchased);
   CREATE INDEX idx_fuel_odometer_reading ON Fuel(odometer_reading);
   CREATE INDEX idx_fuel_price_per_gallon ON Fuel(price_per_gallon);
   CREATE INDEX idx_fuel_total_cost ON Fuel(total_cost);
   CREATE INDEX idx_fuel_fuel_station ON Fuel(fuel_station);
   
CREATE INDEX idx_trip_id ON Trip(ID);
CREATE INDEX idx_trip_vehicle_id ON Trip(vehicle_ID); 
CREATE INDEX idx_trip_driver_id ON Trip(driver_ID);
CREATE INDEX idx_trip_start_datetime ON Trip(start_datetime);
CREATE INDEX idx_trip_end_datetime ON Trip(end_datetime);
CREATE INDEX idx_trip_start_odometer ON Trip(start_odometer);
CREATE INDEX idx_trip_end_odometer ON Trip(end_odometer);
CREATE INDEX idx_trip_destination ON Trip(destination);
CREATE INDEX idx_fuel_purpose ON Trip(purpose);



CREATE INDEX idx_inventory_id ON Inventory(ID);
           CREATE INDEX idx_inventory_name ON Inventory(name);
           CREATE INDEX idx_inventory_stock_level ON Inventory(stock_level);
           CREATE INDEX idx_inventory_unit_price ON Inventory(unit_price);
           CREATE INDEX idx_inventory_supplier ON Inventory(supplier);
           CREATE INDEX idx_inventory_recorder_point ON Inventory(recorder_point);

CREATE INDEX idx_location_id ON Location(ID);
         CREATE INDEX idx_location_vehicle_id ON Location(vehicle_ID);
         CREATE INDEX idx_location_datetime ON Location(datetime);
         CREATE INDEX idx_location_gps_coordinates ON Location(GPS_coordinates);
         CREATE INDEX idx_location_address ON Location(address);
         
         DELIMITER //
CREATE PROCEDURE Get_Trips_For_vehicle(IN vehicleID INT)
BEGIN
      SELECT*
      FROM Trip
      WHERE Vehicle_ID = vehicleID;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdateVehicleStatus(
    IN vehicleID INT,
    IN newOdometerReading INT
)
BEGIN
    DECLARE currentStatus VARCHAR(50);
  -- Get the current status of the vehicle
    SELECT status INTO currentStatus FROM Vehicle WHERE ID = vehicleID;
  -- Update the status based on the odometer reading
    IF newOdometerReading < 50000 THEN
        UPDATE Vehicle SET status = 'Good' WHERE ID = vehicleID;
    ELSEIF newOdometerReading >= 50000 AND newOdometerReading < 100000 THEN
        UPDATE Vehicle SET status = 'Maintenance Required' WHERE ID = vehicleID;
    ELSE
        UPDATE Vehicle SET status = 'Out of Service' WHERE ID = vehicleID;
    END IF;
END //
DELIMITER ;

DROP TEMPORARY TABLE IF EXISTS Temp_Fuel_Purchases;

CREATE TEMPORARY TABLE Temp_Fuel_Purchases AS
SELECT *
FROM Fuel
WHERE total_cost > 50;

   
DROP TEMPORARY TABLE IF EXISTS Temp_Trip_Summary;

CREATE TEMPORARY TABLE Temp_Trip_Summary AS
SELECT
    t.ID AS Trip_ID,
    v.VIN,
    v.model,
    d.name AS Driver_Name,
    t.start_datetime,
    t.end_datetime,
    t.start_odometer,
    t.end_odometer,
    t.destination,
    t.purpose,
    t.notes
FROM Trip t
JOIN Vehicle v ON t.vehicle_ID = v.ID
JOIN Driver d ON t.driver_ID = d.ID;


CREATE VIEW Vehicle_Driver_Info AS
  SELECT v.ID AS Vehicle_ID, v.license_plate, d.name AS Driver_Name
  FROM Vehicle v
  LEFT JOIN Driver d ON v.assigned_driver_ID = d.ID;

CREATE VIEW FuelUsageView AS
   SELECT
    f.vehicle_ID AS VehicleID,
    SUM(f.gallons_purchased) AS TotalGallonsPurchased,
    SUM(f.total_cost) AS TotalFuelCost
    FROM  Fuel f
   GROUP BY f.vehicle_ID;
   
   CREATE VIEW MaintenanceCostView AS
SELECT
 m.vehicle_ID AS VehicleID, SUM(m.cost) AS TotalMaintenanceCost
FROM Maintenance m
GROUP BY m.vehicle_ID;

DELIMITER //

CREATE TRIGGER Update_Odometer
AFTER INSERT ON Trip
FOR EACH ROW
BEGIN
    UPDATE Vehicle
    SET odometer_reading = NEW.end_odometer
    WHERE ID = NEW.vehicle_ID;
END//

DELIMITER ;


DELIMITER //

CREATE TRIGGER Update_Total_Cost
BEFORE INSERT ON Fuel
FOR EACH ROW
BEGIN
    SET NEW.total_cost = NEW.gallons_purchased * NEW.price_per_gallon;
END //

DELIMITER ;

 DELIMITER //
CREATE FUNCTION calculate_Total_Maintenance_Cost(vehicleID INT)
RETURNS DECIMAL
DETERMINISTIC
READS SQL DATA
BEGIN
           DECLARE total_cost DECIMAL(10,2);
           SELECT SUM(cost) INTO total_cost 
            FROM Maintenance
            WHERE vehicle_ID = vehicleID;
             RETURN total_cost;
   END;
   
DELIMITER //

CREATE FUNCTION Get_Next_Service_Due_Date(vehicleID INT)
RETURNS DATE
READS SQL DATA
BEGIN
    DECLARE next_due_date DATE;
    SELECT MIN(next_service_due) INTO next_due_date
    FROM Maintenance
    WHERE vehicle_ID = vehicleID AND next_service_due IS NOT NULL;
    IF next_due_date IS NULL THEN
        SET next_due_date = '9999-12-31'; 
    END IF;
    RETURN next_due_date;

END //

DELIMITER ;


DELIMITER //
CREATE FUNCTION Calculate_Total_Fuel_Cost(vehicleID INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_cost DECIMAL(10,2);
   SELECT SUM(total_cost) INTO total_cost
    FROM Fuel
    WHERE vehicle_ID = vehicleID;
    IF total_cost IS NULL THEN
        SET total_cost = 0.00;
    END IF;
 RETURN total_cost;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS Get_Next_Service_Due_Date;

DELIMITER //
CREATE FUNCTION Get_Next_Service_Due_Date(vehicleID INT)
RETURNS DATE
READS SQL DATA
BEGIN
    DECLARE next_due_date DATE;
    SELECT MIN(next_service_due) INTO next_due_date
    FROM Maintenance
    WHERE vehicle_ID = vehicleID;
    IF next_due_date IS NULL THEN
        SET next_due_date = '9999-12-31'; -- Default date if no next service due date is found
    END IF;
    RETURN next_due_date;
END //
DELIMITER ;




DELIMITER //
CREATE FUNCTION Calculate_Total_Inventory_Cost() 
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_cost DECIMAL(10,2);
    SELECT SUM(stock_level * unit_price) INTO total_cost
    FROM Inventory;
    IF total_cost IS NULL THEN
        SET total_cost = 0.00;
    END IF;
    RETURN total_cost;
    END //
DELIMITER ;

insert into Driver (id, name, license_number, address, contact_info, hire_date, driving_record) values (1, 'Hephzibah McPaik', 'QWE456', '951 Victoria Road', '546-861-5131', '2014-07-20', 'no violations');
insert into Driver (id, name, license_number, address, contact_info, hire_date, driving_record) values (2, 'Suzi Bilbery', '654MNO', '36965 Anniversary Hill', '868-759-7590', '2012-04-17', 'failure to yield citation');
insert into Driver (id, name, license_number, address, contact_info, hire_date, driving_record) values (3, 'Ardyth Baysting', '123ABC', '73 Pearson Way', '171-431-7158', '2014-07-12', 'minor speeding ticket');
insert into Driver (id, name, license_number, address, contact_info, hire_date, driving_record) values (4, 'Dodi Hannan', 'VWX789', '61915 Ronald Regan Terrace', '820-413-0412', '2021-03-11', 'failure to yield citation');
insert into Driver (id, name, license_number, address, contact_info, hire_date, driving_record) values (5, 'Kahlil Van Son', 'JKL321', '69 Hoard Point', '308-781-5167', '2014-04-05', 'speeding ticket');
insert into Driver (id, name, license_number, address, contact_info, hire_date, driving_record) values (6, 'Yetta Collyear', '321JKL', '99 Bobwhite Crossing', '697-269-4583', '2015-05-15', 'DUI conviction');
insert into Driver (id, name, license_number, address, contact_info, hire_date, driving_record) values (7, 'Rickie Blaze', 'MNO987', '3 Carey Avenue', '655-843-9704', '2019-09-15', 'DUI conviction');
insert into Driver (id, name, license_number, address, contact_info, hire_date, driving_record) values (8, 'Janessa Riccetti', 'XYZ789', '34 Burning Wood Pass', '435-203-3361', '2016-09-05', 'hit and run incident');
insert into Driver (id, name, license_number, address, contact_info, hire_date, driving_record) values (9, 'Gib Tuson', 'GHI987', '74532 Carberry Junction', '422-244-1268', '2018-12-17', 'no violations');
insert into Driver (id, name, license_number, address, contact_info, hire_date, driving_record) values (10, 'Irma Suller', 'WHZ789', '74 Lindbergh Crossing', '273-936-4350', '2014-12-02', 'DUI conviction');
insert into Driver (id, name, license_number, address, contact_info, hire_date, driving_record) values (11, 'Sibley Tonn', 'DEF654', '33 Anthes Avenue', '739-366-5416', '2018-04-20', 'improper lane change citation');
insert into Driver (id, name, license_number, address, contact_info, hire_date, driving_record) values (12, 'Bert Emm', 'IJK987', '29432 Westridge Park', '152-318-1397', '2016-07-10', 'minor speeding ticket');
insert into Driver (id, name, license_number, address, contact_info, hire_date, driving_record) values (13, 'Burnard Pordall', 'NOP987', '9013 Washington Court', '387-359-5518', '2012-11-09', 'improper lane change citation');
insert into Driver (id, name, license_number, address, contact_info, hire_date, driving_record) values (14, 'Olia Morling', 'LMN321', '763 Vermont Parkway', '822-671-5027', '2016-03-14', 'speeding ticket');
insert into Driver (id, name, license_number, address, contact_info, hire_date, driving_record) values (15, 'Minne Devey', 'ABC789', '080 Westridge Street', '746-224-3342', '2017-05-25', 'suspended license');

insert into Vehicle (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID) values (1, 'JTEBU5JR2E5406763', 'Reatta', 1991, 'Buick', 'KIY659', 72890, 'electric', '2014-04-26', 'reserved', 5);
insert into Vehicle (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID) values (2, 'WAUMFBFL4DN453962', 'Odyssey', 2012, 'Honda', 'XAI191', 53324, 'diesel', '2010-04-20', 'under maintenance', 3);
insert into Vehicle (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID) values (3, 'WAUED54B41N732457', '300E', 1993, 'Mercedes-Benz', 'RSF959', 72916, 'hydrogen', '2008-02-24', 'parked', 11);
insert into Vehicle (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID) values (4, '5N1AN0NW0DN993524', 'Aspire', 1996, 'Ford', 'JVO476', 58658, 'coal', '2008-03-12', 'scrapped', 11);
insert into Vehicle (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID) values (5, '1G6AF5S32D0183837', '7 Series', 2012, 'BMW', 'YJY716', 62411, 'ethanol', '2011-10-15', 'scrapped', 2);
insert into Vehicle (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID) values (6, 'WAUXL68E84A097258', 'V12 Vantage', 2012, 'Aston Martin', 'KSU377', 66563, 'butanol', '2013-11-11', 'repossessed', 1);
insert into Vehicle (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID) values (7, '5TFAW5F19EX570769', 'Jetta', 2010, 'Volkswagen', 'CAW879', 87819, 'wood gas', '2013-02-22', 'parked', 13);
insert into Vehicle (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID) values (8, '1GT3C0BG4AF433415', 'Jetta', 1985, 'Volkswagen', 'XHJ452', 72214, 'hybrid', '2013-07-28', 'repossessed', 10);
insert into Vehicle (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID) values (9, 'WBAVD53587A032582', 'C30', 2009, 'Volvo', 'PBB278', 83659, 'hybrid', '2014-05-08', 'parked', 1);
insert into Vehicle (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID) values (10, 'SCBFH7ZA6FC217392', 'Tacoma Xtra', 1995, 'Toyota', 'TZN285', 74760, 'diesel', '2014-09-06', 'in use', 7);
insert into Vehicle (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID) values (11, '5NPEB4ACXDH078908', 'Xterra', 2002, 'Nissan', 'FIJ658', 50938, 'solar', '2009-06-23', 'repossessed', 6);
insert into Vehicle (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID) values (12, '1GYUCBEF4AR304201', 'Cruze', 2012, 'Chevrolet', 'DVA964', 95406, 'coal', '2015-04-25', 'available', 14);
insert into Vehicle (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID) values (13, 'KNAFT4A22A5490080', '3 Series', 2007, 'BMW', 'YFE542', 90040, 'vegetable oil', '2010-06-05', 'repossessed', 8);
insert into Vehicle (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID) values (14, 'WP1AE2A2XBL100797', 'RDX', 2012, 'Acura', 'AZZ490', 74955, 'biofuel', '2015-11-07', 'repossessed', 14);
insert into Vehicle (ID, VIN, model, year, make, license_plate, odometer_reading, fuel_type, acquisition_date, status, assigned_driver_ID) values (15, 'WDDHF5GB9AA337323', '1500', 1997, 'Chevrolet', 'DAF632', 86480, 'diesel', '2007-03-27', 'active', 15);

insert into Inventory (id, name, description, stock_level, unit_price, supplier, reorder_point) values (1, 'engine', 'High quality engine for various models', 64, 351.65, 'AutoMax Suppliers', 8);
insert into Inventory (id, name, description, stock_level, unit_price, supplier, reorder_point) values (2, 'tire', 'All-season radial tire for sedans', 55, 105.66, 'Speedy Motors', 30);
insert into Inventory (id, name, description, stock_level, unit_price, supplier, reorder_point) values (3, 'brake pad', 'High quality brake pads for various models', 110, 438.89, 'CarZone Distributors', 9);
insert into Inventory (id, name, description, stock_level, unit_price, supplier, reorder_point) values (4, 'headlight', 'High intensity of light', 168, 134.43, 'DriveTime Wholesalers', 61);
insert into Inventory (id, name, description, stock_level, unit_price, supplier, reorder_point) values (5, 'bumper', 'Multi-layer design', 32, 177.03, 'WheelWorks Inc.', 54);
insert into Inventory (id, name, description, stock_level, unit_price, supplier, reorder_point) values (6, 'radiator', 'Designing high quality cooling system', 78, 230.81, 'FastLane Auto Parts', 49);
insert into Inventory (id, name, description, stock_level, unit_price, supplier, reorder_point) values (7, 'spark plug', 'Generate electrical spark', 210, 166.48, 'RoadRunner Supplies', 8);
insert into Inventory (id, name, description, stock_level, unit_price, supplier, reorder_point) values (8, 'fuel pump', 'High quality mechanism to pump fuel', 79, 477.97, 'GearUp Motors', 43);
insert into Inventory (id, name, description, stock_level, unit_price, supplier, reorder_point) values (9, 'air filter', 'High performance of filter', 153, 307.81, 'AutoPro Distributors', 40);
insert into Inventory (id, name, description, stock_level, unit_price, supplier, reorder_point) values (10, 'alternator', 'Converts AC to DC', 182, 102.59, 'MileHigh Auto', 81);
insert into Inventory (id, name, description, stock_level, unit_price, supplier, reorder_point) values (11, 'steering wheel', 'Made with high quality raw materials', 148, 300.35, 'CarCraft Suppliers', 66);
insert into Inventory (id, name, description, stock_level, unit_price, supplier, reorder_point) values (12, 'exhaust pipe', 'Smoke is emitted without disturbance', 120, 268.77, 'DriveSmart Wholesalers', 54);
insert into Inventory (id, name, description, stock_level, unit_price, supplier, reorder_point) values (13, 'shock absorber', 'High quality material used for springs', 92, 73.53, 'AutoTech Parts', 19);
insert into Inventory (id, name, description, stock_level, unit_price, supplier, reorder_point) values (14, 'windshield wiper', 'Made with high quality plastic', 36, 241.59, 'WheelWorld Inc.', 52);
insert into Inventory (id, name, description, stock_level, unit_price, supplier, reorder_point) values (15, 'catalytic converter', 'Reduces harmful pollutants emitted', 97, 94.15, 'SpeedyDrive Distributors', 36);




insert into Trip (ID, Vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes) values (1, 12, 4, '2023-11-27', '2023-11-27', 67417.62, 67917.62, 'client meeting', 'Business', 'successful meeting');
insert into Trip (ID, Vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes) values (2, 2, 10, '2023-04-28', '2023-04-28', 82029.89, 82529.89, 'delivery', 'work', 'delivered packages on time');
insert into Trip (ID, Vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes) values (3, 4, 15, '2023-11-05', '2023-11-05', 82716.32, 83216.32, 'service center', 'maintenance', 'routine checkup');
insert into Trip (ID, Vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes) values (4, 13, 3, '2023-08-03', '2023-08-03', 76785.33, 77285.33, 'Exam', 'education', 'successful exam');
insert into Trip (ID, Vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes) values (5, 8, 7, '2023-06-09', '2023-06-09', 87322.6, 87822.6, 'shopping', 'personal', 'completed on time');
insert into Trip (ID, Vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes) values (6, 7, 14, '2023-12-13', '2023-12-13', 58038.77, 58538.77, 'client meeting', 'Business', 'successful meeting');
insert into Trip (ID, Vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes) values (7, 7, 11, '2023-09-19', '2023-09-19', 52503.01, 53003.01, 'delivery', 'work', 'delivered packages on time');
insert into Trip (ID, Vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes) values (8, 3, 9, '2023-03-02', '2023-03-02', 69246.81, 69746.81, 'service center', 'maintenance', 'routine checkup');
insert into Trip (ID, Vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes) values (9, 11, 6, '2023-06-23', '2023-06-23', 79905.62, 80405.62, 'Exam', 'education', 'successful exam');
insert into Trip (ID, Vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes) values (10, 5, 12, '2023-07-15', '2023-07-15', 68198.18, 68698.18, 'shopping', 'personal', 'completed on time');
insert into Trip (ID, Vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes) values (11, 10, 12, '2023-06-08', '2023-06-08', 68087.79, 68587.79, 'client meeting', 'Business', 'successful meeting');
insert into Trip (ID, Vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes) values (12, 1, 14, '2023-03-06', '2023-03-06', 83096.09, 83596.09, 'delivery', 'work', 'delivered packages on time');
insert into Trip (ID, Vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes) values (13, 2, 10, '2023-07-17', '2023-07-17', 82778.09, 83278.09, 'service center', 'maintenance', 'routine checkup');
insert into Trip (ID, Vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes) values (14, 2, 9, '2023-03-11', '2023-03-11', 80841.65, 81341.65, 'Exam', 'education', 'successful exam');
insert into Trip (ID, Vehicle_ID, driver_ID, start_datetime, end_datetime, start_odometer, end_odometer, destination, purpose, notes) values (15, 11, 7, '2023-08-21', '2023-08-21', 65433.32, 65933.32, 'shopping', 'personal', 'completed on time');

insert into Fuel (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, total_cost, fuel_station) values (2, '2023-05-23', 7.52, 77851, 4.64, 34.89, 'Texco');
insert into Fuel (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, total_cost, fuel_station) values (14, '2023-11-14', 17.08, 84826, 3.01, 51.41, 'Pilot');
insert into Fuel (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, total_cost, fuel_station) values (5, '2023-08-03', 2.07, 68140, 2.14, 4.43, 'Quikr');
insert into Fuel (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, total_cost, fuel_station) values (4, '2023-09-08', 5.09, 53001, 3.5, 17.82, 'Chevy');
insert into Fuel (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, total_cost, fuel_station) values (9, '2023-07-22', 25.4, 57137, 4.53, 115.06, 'Pilot');
insert into Fuel (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, total_cost, fuel_station) values (5, '2023-09-19', 15.54, 88786, 2.06, 32.01, 'Wawa');
insert into Fuel (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, total_cost, fuel_station) values (12, '2023-08-26', 29.01, 54209, 3.26, 94.57, 'Gulf');
insert into Fuel (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, total_cost, fuel_station) values (6, '2023-08-19', 18.11, 72593, 2.22, 40.20, 'Shell');
insert into Fuel (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, total_cost, fuel_station) values (5, '2023-06-02', 4.13, 76767, 4.61, 19.04, 'Exxon');
insert into Fuel (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, total_cost, fuel_station) values (1, '2023-03-26', 23.46, 89075, 2.55, 59.82, 'Shell');
insert into Fuel (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, total_cost, fuel_station) values (8, '2023-11-05', 12.9, 55434, 2.05, 26.45, 'Wawa');
insert into Fuel (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, total_cost, fuel_station) values (13, '2023-03-08', 24.23, 53624, 3.76, 91.10, 'Speed');
insert into Fuel (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, total_cost, fuel_station) values (6, '2023-03-17', 16.51, 77166, 4.6, 75.95, 'Sheetz');
insert into Fuel (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, total_cost, fuel_station) values (2, '2023-03-02', 21.05, 62802, 3.79, 79.78, 'Chevy');
insert into Fuel (vehicle_ID, date, gallons_purchased, odometer_reading, price_per_gallon, total_cost, fuel_station) values (7, '2023-12-25', 3.42, 59432, 3.45, 11.80, 'BP');

insert into Maintenance (ID, Vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used) values (1, 1, '2015-11-27', 'corrective', 93547, 457.55, 'car wash', 'Alex Mechanic', '2018-05-10', 1);
insert into Maintenance (ID, Vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used) values (2, 1, '2018-04-12', 'preventive', 74305, 363.81, 'engine tune-up', 'Sara Mechanic', '2017-07-10', 2);
insert into Maintenance (ID, Vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used) values (3, 1, '2015-12-19', 'corrective', 82317, 228.71, 'headlight bulb replacement', 'Mike Mechanic', '2018-04-25', 3);
insert into Maintenance (ID, Vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used) values (4, 4, '2018-06-30', 'corrective', 87127, 290.30, 'windshield wiper replacement', 'Emily Mechanic', '2018-12-08', 4);
insert into Maintenance (ID, Vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used) values (5, 2, '2018-07-25', 'corrective', 69975, 136.09, 'power steering fluid flush', 'Jake Mechanic', '2017-07-17', 5);
insert into Maintenance (ID, Vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used) values (6, 6, '2018-06-05', 'preventive', 82101, 307.80, 'suspension system inspection', 'Lily Mechanic', '2017-12-06', 6);
insert into Maintenance (ID, Vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used) values (7, 7, '2017-08-23', 'preventive', 83719, 181.04, 'spark plug replacement', 'Max Mechanic', '2019-01-15', 7);
insert into Maintenance (ID, Vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used) values (8, 4, '2017-05-24', 'preventive', 68568, 499.58, 'brake inspection', 'Sophie Mechanic', '2018-03-26', 8);
insert into Maintenance (ID, Vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used) values (9, 6, '2020-02-12', 'preventive', 69362, 249.25, 'wheel alignment', 'Ben Mechanic', '2017-09-27', 9);
insert into Maintenance (ID, Vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used) values (10, 7, '2019-04-09', 'corrective', 91378, 100.47, 'exhaust system inspection', 'Olivia Mechanic', '2018-01-12', 10);
insert into Maintenance (ID, Vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used) values (11, 12, '2020-02-25', 'corrective', 74189, 270.90, 'brake inspection', 'Luke Mechanic', '2017-04-25', 11);
insert into Maintenance (ID, Vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used) values (12, 10, '2019-06-17', 'preventive', 68149, 279.97, 'car wash', 'Ava Mechanic', '2017-10-03', 12);
insert into Maintenance (ID, Vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used) values (13, 10, '2017-03-04', 'corrective', 84972, 280.25, 'air filter replacement', 'Chris Mechanic', '2018-06-19', 13);
insert into Maintenance (ID, Vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used) values (14, 8, '2016-06-25', 'preventive', 63154, 275.40, 'AC recharge', 'Nora Mechanic', '2018-06-28', 14);
insert into Maintenance (ID, Vehicle_ID, date, type, mileage, cost, description, technician, next_service_due, part_used) values (15, 7, '2015-05-19', 'preventive', 69906, 258.64, 'suspension system inspection', 'Ethan Mechanic', '2017-08-08', 15);


insert into location (ID, vehicle_ID, datetime, GPS_coordinates, address ) values (1, 6, '2023-02-14 08:42:16', '55.6761 N', 'NewOrleans');
insert into location (ID, vehicle_ID, datetime, GPS_coordinates, address ) values (2, 3, '2023-06-17 23:59:16', '74.0060 W', 'Boston');
insert into location (ID, vehicle_ID, datetime, GPS_coordinates, address ) values (3, 3, '2023-06-08 15:55:03', '51.5074 N', 'Miami');
insert into location (ID, vehicle_ID, datetime, GPS_coordinates, address ) values (4, 9, '2023-08-26 11:29:25', '2.3522 W', 'Atlanta');
insert into location (ID, vehicle_ID, datetime, GPS_coordinates, address ) values (5, 10, '2023-03-31 10:22:30', '139.6917 W', 'Atlanta');
insert into location (ID, vehicle_ID, datetime, GPS_coordinates, address ) values (6, 9, '2023-06-15 19:08:54', '40.4168 N', 'Philadelphia');
insert into location (ID, vehicle_ID, datetime, GPS_coordinates, address ) values (7, 2, '2023-12-09 07:48:09', '74.0060 W', 'LasVegas');
insert into location (ID, vehicle_ID, datetime, GPS_coordinates, address ) values (8, 7, '2023-03-25 07:12:03', '55.7558 N', 'Richmond');
insert into location (ID, vehicle_ID, datetime, GPS_coordinates, address ) values (9, 8, '2023-05-07 02:58:54', '52.5200 N', 'Michigan');
insert into location (ID, vehicle_ID, datetime, GPS_coordinates, address ) values (10, 11, '2023-06-29 17:21:26', '73.5673 W', 'Ohio');
insert into location (ID, vehicle_ID, datetime, GPS_coordinates, address ) values (11, 13, '2023-09-13 23:57:54', '23.7275 W', 'Charlotte');
insert into location (ID, vehicle_ID, datetime, GPS_coordinates, address ) values (12, 15, '2023-10-24 13:11:11', '34.0522 N', 'Chicago');
insert into location (ID, vehicle_ID, datetime, GPS_coordinates, address ) values (13, 7, '2023-09-27 03:28:27', '55.7558 N', 'LasVegas');
insert into location (ID, vehicle_ID, datetime, GPS_coordinates, address ) values (14, 6, '2023-09-24 03:19:20', '73.5673 W', 'California');
insert into location (ID, vehicle_ID, datetime, GPS_coordinates, address ) values (15, 13, '2023-02-01 16:03:36', '40.7128 N', 'LasVegas');


SELECT * FROM Vehicle LIMIT 0, 1000;

SELECT * FROM Driver LIMIT 0, 1000;

SELECT * FROM Inventory LIMIT 0, 1000;

SELECT * FROM Trip LIMIT 0, 1000;

SELECT * FROM Fuel LIMIT 0, 1000;

SELECT * FROM Maintenance LIMIT 0, 1000;

SELECT * FROM location LIMIT 0, 1000;