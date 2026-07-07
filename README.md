<div align="center">

# 🏥 Hospital Information System (HIS)

### Complete SQL Server Database & Flask Web Application

![SQL Server](https://img.shields.io/badge/SQL%20Server-2022-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-Web%20Application-000000?style=for-the-badge&logo=flask)
![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Tables](https://img.shields.io/badge/Tables-34-0366d6?style=for-the-badge)
![Views](https://img.shields.io/badge/Views-✓-6f42c1?style=for-the-badge)
![Procedures](https://img.shields.io/badge/Stored%20Procedures-✓-ff9800?style=for-the-badge)
![Functions](https://img.shields.io/badge/Functions-✓-2ea44f?style=for-the-badge)
![Triggers](https://img.shields.io/badge/Triggers-✓-e63946?style=for-the-badge)

*A complete Hospital Information System featuring a fully normalized SQL Server database, automated business logic, analytical reporting, IoT monitoring, and a modern Flask-based web interface.*

</div>

---

# 📋 Table of Contents

- [Overview](#-overview)
- [Highlights](#-highlights)
- [Features](#-features)
- [System Architecture](#-system-architecture)
- [Database Modules](#-database-modules)
- [Database Objects](#-database-objects)
- [Web Application](#-web-application)
- [Schema](#-schema)
- [Project Structure](#-project-structure)
- [Installation](#-installation)
- [Screenshots](#-screenshots)
- [Design Decisions](#-design-decisions)
- [Future Improvements](#-future-improvements)
- [Team](#-team)

---

# 🔍 Overview

This project is a complete **Hospital Information System (HIS)** developed as the final Database course project.

Unlike a traditional database assignment, this repository contains a complete backend database implementation together with a Flask-based web application capable of interacting directly with Microsoft SQL Server.

The system models real hospital workflows including:

- Patient Registration
- Medical Records
- Doctor Appointments
- Hospital Admissions
- Laboratory & Imaging
- Pharmacy
- Inventory
- Financial Management
- IoT Monitoring
- Automated Alert System

The database follows normalization principles and implements business logic directly inside SQL Server using stored procedures, functions, triggers, constraints, and views.

---

# 🚀 Highlights

| Component | Status |
|-----------|--------|
| Fully Normalized Database | ✅ |
| 34 Relational Tables | ✅ |
| Foreign Keys & Constraints | ✅ |
| Stored Procedures | ✅ |
| SQL Functions | ✅ |
| SQL Triggers | ✅ |
| SQL Views | ✅ |
| Sample Data | ✅ |
| Flask Web Interface | ✅ |
| Dashboard | ✅ |
| Patient Management | ✅ |
| Financial Module | ✅ |
| Inventory Management | ✅ |
| IoT Monitoring | ✅ |
| Laboratory Module | ✅ |

---

# ✨ Features

## Database

- Fully normalized SQL Server schema
- 34 relational tables
- Strong referential integrity
- CHECK constraints
- UNIQUE constraints
- Identity keys
- Cascade relationships where appropriate

---

## Business Logic

- Stored Procedures
- Scalar Functions
- Table-Valued Functions
- SQL Triggers
- Views
- Transactions
- Error Handling

---

## Clinical Modules

- Patient Registration
- Electronic Medical Records
- Doctor Diagnosis
- Appointment Scheduling
- Admission Management
- Bed Allocation
- Patient Transfer

---

## Laboratory

- Lab Requests
- Imaging Requests
- Critical Result Detection
- Automatic Lab Alerts

---

## Pharmacy

- Drug Catalog
- Prescriptions
- Prescription Items
- Drug Interaction Database

---

## Financial

- Insurance Coverage
- Invoices
- Invoice Items
- Payments
- Payment Methods

---

## Smart Hospital

- IoT Devices
- Vital Sign Logs
- Patient Thresholds
- Automatic Alert Generation

---

## Web Interface

- Flask
- SQLAlchemy
- Bootstrap
- Dashboard
- CRUD Operations
- Responsive Design

---

# 🏗 System Architecture

```

Browser
│
▼
Flask Web Application
│
├── Dashboard
├── Patients
├── Admissions
├── Laboratory
├── Pharmacy
├── Inventory
├── Financial
└── IoT

│

▼

SQLAlchemy ORM

│

▼

Microsoft SQL Server

│

├── Tables
├── Views
├── Functions
├── Procedures
└── Triggers

---

### 5 · Lab & Imaging

> `Labimagingrequest` · `labresult` · `isCritical` · `labalert`

The laboratory subsystem supports both **outpatient** and **inpatient** diagnostic workflows.

A physician creates a laboratory or imaging request linked to either an appointment or an admission. Each completed request stores one or more results inside `labresult`.

Reference intervals are defined in `isCritical`.

Whenever a measured value falls outside the acceptable range, SQL Server automatically creates a notification inside `labalert` through database triggers.

```
Doctor
   │
   ▼
Lab Request
   │
   ▼
Lab Result
   │
Compare with Reference Range
   │
   ├── Normal
   │
   └── Critical
           │
           ▼
      Lab Alert
```

---

### 6 · Pharmacy

> `drug`
> `prescription`
> `prescriptionitem`
> `druginteraction`

Electronic prescriptions are fully normalized.

Each prescription belongs to a patient encounter while individual medications are stored in `prescriptionitem`.

Drug interactions are maintained separately and can be validated before dispensing medication.

The design supports:

- Multiple medications
- Dosage
- Quantity
- Duration
- Drug interaction lookup

---

### 7 · Inventory

> `storage`
> `storage_transaction`

Hospital inventory management is implemented using transaction history instead of mutable counters.

Each movement is recorded as:

- IN
- OUT

allowing complete auditing of stock history.

```
Storage
      │
      ▼
Storage Transaction
      │
      ├── IN
      └── OUT
```

---

### 8 · Financial System

> `invoice`
> `invoiceitem`
> `payment`
> `paymentmethod`
> `insurance`

The billing subsystem supports:

- insurance calculation
- patient share
- paid amount
- remaining balance
- multiple payment methods

Invoices contain detailed line items for every medical service.

---

### 9 · IoT Monitoring

> `iotdevice`
> `devicetransfer`
> `logs`
> `AlertThreshold`
> `alert`

The system supports continuous monitoring of patients through smart medical devices.

Examples include:

- Heart Rate sensors
- Oxygen saturation monitors
- Temperature sensors
- Bed occupancy sensors

Every reading is inserted into `logs`.

Database triggers compare each reading against configurable thresholds.

If values exceed acceptable limits, SQL Server automatically generates alerts for medical staff.

```
IoT Device
      │
      ▼
Measurement Log
      │
Threshold Check
      │
      ├── OK
      │
      └── Alert
               │
               ▼
          Employee
```

---

# ⚙ Database Features

Unlike a traditional university database assignment, this project includes complete business logic implemented directly inside SQL Server.

## Stored Procedures

The database provides procedures for operations such as:

- Patient registration
- Appointment scheduling
- Admission management
- Prescription generation
- Inventory transactions
- Invoice creation
- Payment processing
- IoT management

---

## User Defined Functions

Several reusable SQL functions simplify common operations, including:

- Financial calculations
- Insurance coverage
- Bed availability
- Patient statistics
- Drug related utilities

---

## Triggers

Business rules are enforced automatically.

Examples include:

✅ Automatic Lab Alerts

Whenever a laboratory result exceeds its normal reference interval, a new alert is generated automatically.

---

✅ Automatic IoT Alerts

Incoming sensor measurements are validated immediately.

Abnormal readings create emergency alerts without application-side code.

---

✅ Data Integrity

Multiple triggers maintain consistency across related modules and prevent invalid operations.

---

## Views

Several SQL Views are included to simplify reporting.

Examples include:

- Current Admissions
- Patient History
- Financial Summary
- Inventory Overview
- Active Alerts
- IoT Dashboard

These views are also consumed directly by the Flask application.

---

# 🌐 Flask Web Application

A complete web interface has been developed on top of the SQL Server database.

The application is built using:

- Flask
- SQLAlchemy
- Jinja2
- Bootstrap
- Microsoft SQL Server

```
Browser
    │
Flask
    │
SQLAlchemy
    │
SQL Server
```

Main modules include:

- Dashboard
- Patients
- Staff
- Admissions
- Appointments
- Laboratory
- Pharmacy
- Inventory
- Financial
- IoT Monitoring

The web interface communicates directly with the relational database without requiring any additional middleware.

---

# 🗺 Database Schema

The Hospital Information System is composed of **34 normalized tables** distributed across nine major modules.

The schema follows relational database best practices including:

- Primary & Foreign Keys
- CHECK Constraints
- UNIQUE Constraints
- Default Values
- Cascading Relationships
- Junction Tables
- ISA Inheritance
- Transaction Tables

---

## Entity Relationship Diagram

The complete ER Diagram illustrates all entities, relationships, cardinalities and foreign key dependencies.

<p align="center">
  <img src="ER diagram.png" width="100%">
</p>

---

# 🧠 Design Decisions

| # | Decision | Reason |
|---|----------|--------|
| 1 | National ID as Patient PK | Natural immutable identifier that uniquely identifies every patient |
| 2 | One Medical Record per Patient | Enforced using UNIQUE constraint |
| 3 | ISA inheritance for Employees | Eliminates nullable columns while keeping subtype-specific attributes |
| 4 | Separate transaction tables | Inventory, payments, transfers and logs preserve complete history |
| 5 | Appointment OR Admission model | Clinical services support both outpatient and inpatient workflows |
| 6 | Trigger-based alert generation | Critical events are generated automatically inside SQL Server |
| 7 | Configurable IoT thresholds | Supports both hospital-wide and patient-specific monitoring |
| 8 | Reference tables | Lookup values are normalized to eliminate duplication |
| 9 | Identity keys | Simplifies joins while keeping relationships consistent |
|10 | SQL business logic | Procedures, Functions and Triggers keep application logic inside the database |

---

# 📂 Project Structure

```
HIS_Database
│
├── ER diagram.png
│
├── SQL
│   ├── 01_create_tables.sql
│   ├── 02_constraints.sql
│   ├── 03_triggers.sql
│   ├── 04_procedures.sql
│   ├── 05_functions.sql
│   ├── 06_views.sql
│   └── 07_sample_data.sql
│
├── hospital-web
│   ├── app
│   ├── templates
│   ├── static
│   ├── models
│   ├── blueprints
│   ├── config.py
│   └── run.py
│
└── README.md
```

---

# 📊 Sample Data

The project includes a comprehensive sample dataset designed to demonstrate every major workflow.

Sample records include:

- Patients
- Medical Records
- Departments
- Staff
- Doctors
- Nurses
- Admissions
- Beds
- Appointments
- Diagnoses
- Laboratory Requests
- Lab Results
- Critical Alerts
- Prescriptions
- Drug Interactions
- Inventory Transactions
- Invoices
- Payments
- Insurance Plans
- IoT Devices
- Sensor Logs
- Smart Alerts

The provided dataset enables the Flask application to display realistic dashboards, reports, patient histories, laboratory alerts, inventory status and financial information immediately after installation.

---

# 🚀 Getting Started

## Requirements

- Microsoft SQL Server 2019+
- SQL Server Management Studio (SSMS)
- Python 3.11+
- Flask

---

## Clone Repository

```bash
git clone https://github.com/mostafa06saeedi/HIS_Database.git
```

---

## Database Setup

Run the SQL scripts in the following order:

```
01_create_tables.sql

02_constraints.sql

03_triggers.sql

04_procedures.sql

05_functions.sql

06_views.sql

07_sample_data.sql
```

---

## Flask Setup

```bash
cd hospital-web

pip install -r requirements.txt

python run.py
```

Then open

```
http://127.0.0.1:5000
```

---

# 📈 Implemented Features

## Database

- ✔ 34 Normalized Tables
- ✔ Primary & Foreign Keys
- ✔ CHECK Constraints
- ✔ UNIQUE Constraints
- ✔ Default Constraints
- ✔ Transactions
- ✔ Views
- ✔ Stored Procedures
- ✔ User Defined Functions
- ✔ Triggers
- ✔ Sample Data

---

## Hospital Modules

- ✔ Patient Management
- ✔ Medical Records
- ✔ Staff Management
- ✔ Admissions
- ✔ Appointments
- ✔ Laboratory
- ✔ Pharmacy
- ✔ Inventory
- ✔ Financial System
- ✔ Insurance
- ✔ IoT Monitoring
- ✔ Smart Alerts

---

## Web Application

- ✔ Flask
- ✔ SQLAlchemy
- ✔ Bootstrap UI
- ✔ Dashboard
- ✔ CRUD Pages
- ✔ Reporting Views
- ✔ SQL Server Integration

---

# 📚 Technologies

<p align="center">

<img src="https://skillicons.dev/icons?i=python,flask,bootstrap,html,css,git,github"/>

</p>

**Database**

- Microsoft SQL Server

**Backend**

- Flask
- SQLAlchemy

**Frontend**

- HTML
- CSS
- Bootstrap
- Jinja2

---

# 👥 Team

| Name | GitHub |
|------|--------|
| Amir Mohammad Mofateh | https://github.com/AMiR-Mofateh |
| Koorosh Motazed Keyvani | https://github.com/ImKoorosh |
| Mostafa Saeedi | https://github.com/mostafa06saeedi |

---

# ⭐ Project Highlights

- Enterprise-style Hospital Information System
- Fully normalized relational database
- SQL Server implementation
- Real clinical workflow modeling
- Trigger-based automation
- Stored Procedures & Functions
- IoT monitoring subsystem
- Financial management
- Inventory tracking
- Flask web interface
- Ready-to-use sample database
- Clean modular architecture

---

<div align="center">

### 🏥 Hospital Information System

**Final Database Project**

Built with ❤️ using

**SQL Server · Flask · SQLAlchemy · Bootstrap**

If you found this project useful, consider giving it a ⭐ on GitHub.

</div>
