
# 🚗 Fleet Management System (FMS)

A relational database system built to efficiently manage a fleet of vehicles, drivers, fuel usage, maintenance schedules, inventory, and trips. The system includes a fully normalized MySQL database, SQL automation scripts, and a Python CLI interface for CRUD operations and analytical reporting.

---

## 📚 Features

- **Database Design**
  - Entity-Relationship Diagram (ERD) and relation schemas
  - Normalized structure (3NF) to ensure data integrity
- **SQL Implementation**
  - Tables for Vehicle, Driver, Trip, Maintenance, Fuel, Inventory, and Location
  - Stored procedures, triggers, views, and user-defined functions
- **Python CLI Tool**
  - Perform CRUD operations
  - Execute advanced OLAP queries
  - Display results with `PrettyTable` for better readability
- **Analytics**
  - Fuel efficiency per vehicle
  - Driver performance ranking
  - Maintenance and fuel cost trends
  - Seasonal vehicle usage insights

---

## 🛠️ Tech Stack

- **Database:** MySQL
- **Language:** Python
- **Libraries:** `mysql-connector-python`, `PrettyTable`
- **Tools:** SQL, ERD tools

---

## 📂 Project Structure

```
📁 Fleet-Management-System/
│
├── Deliverable_1.pdf         # ER Diagram, schema, business rules
├── Deliverable_2.pdf         # SQL DDL, stored procedures, triggers, views, functions
├── Deliverable_3.pdf         # Analytical queries and outputs
├── fmsProject.py             # Python CLI interface for FMS
├── FmsDatabase.sql           # Full SQL script to create the database
└── README.md                 # Project documentation
```

---

## 🚀 How to Run

1. **Clone the repository**

```bash
git clone https://github.com/SanketKumarP/Fleet-Management-System.git
cd Fleet-Management-System
```

2. **Set up the MySQL database**

- Open MySQL Workbench or terminal
- Run the SQL script:

```sql
source FmsDatabase.sql;
```

3. **Install required Python packages**

```bash
pip install mysql-connector-python prettytable
```

4. **Run the CLI application**

```bash
python fmsProject.py
```

---

## 📊 Sample OLAP Reports

- **Average maintenance cost by model**
- **Driver trip count and total miles with rank**
- **Monthly fuel cost trends**
- **Fuel efficiency per vehicle model**
- **Location-based vehicle usage frequency**

---

## 👥 Contributors

- Sanketkumar Patel  
- Yashwanth Reddy Panga  
- Priyanka Karan  
- Aswin Reddy Manthena