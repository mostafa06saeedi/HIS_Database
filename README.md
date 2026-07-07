<div align="center">

# 🏥 Hospital Information System
### Database Design — Phase 1

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Phase](https://img.shields.io/badge/Phase%201-Complete-28a745?style=for-the-badge)
![Tables](https://img.shields.io/badge/Tables-34-0366d6?style=for-the-badge)
![Modules](https://img.shields.io/badge/Modules-9-6f42c1?style=for-the-badge)

*A fully relational database schema for managing patients, clinical workflows, hospital resources, pharmacy, financials, and IoT device monitoring — designed as the core foundation of a modern HIS.*

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Modules](#-modules)
- [Schema](#-schema)
- [Design Decisions](#-design-decisions)
- [Getting Started](#-getting-started)
- [Phase 2 Roadmap](#-phase-2-roadmap)
- [Team](#-team)

---

## 🔍 Overview

This project is the **Phase 1 database design** for a Hospital Information System (HIS) — a centralized platform that unifies all hospital departments under one data model.

The schema is built on **Microsoft SQL Server** and covers nine operational modules from patient registration to IoT-based vital sign monitoring. Every table, relationship, and constraint was designed with real clinical workflows in mind.

---

## 📦 Modules

### 1 · Patient Management
> `patient` · `medicalrecord` · `insurance` · `icddisease` · `doctordiagnosis`

Patients are registered once using their **national ID** as the primary key. A single `medicalrecord` is linked to each patient (enforced via `UNIQUE` constraint), storing pre-existing conditions, prior drug consumption, anthropometric data (height, weight), and vital signs.

Physicians record diagnoses per encounter — either from an outpatient appointment or an inpatient admission — using standardized **ICD codes** via the `icddisease` lookup table.

---

### 2 · Admissions & Appointments
> `appointment` · `admission` · `bed` · `patienttransfer`

Appointments support both in-person and online scheduling and track status (scheduled, cancelled, completed). When a patient requires inpatient care, an `admission` record is created with the assigned bed, responsible physician, entry/exit dates, and reason.

Patient transfers between beds and departments during a single admission are fully logged in `patienttransfer` with timestamps and reasons.

---

### 3 · Hospital Resources
> `department` · `bed`

All hospital departments (clinic, emergency, ICU, OR, lab, pharmacy, etc.) are managed through a single `department` table with a `type` discriminator. Each `bed` belongs to a department and carries a real-time `status` field: **free / reserved / occupied**.

---

### 4 · Staff Management
> `employee` · `doctor` · `surgeon` · `nurse` · `adminstaff` · `shift` · `employeeshift`

All personnel share a common `employee` base table. Role-specific attributes are stored in dedicated subtype tables following the **ISA inheritance pattern**:

```
employee  (base: name, department, contract, phone)
  ├── doctor       → specialization, medicalLicenseNo
  ├── surgeon      → surgicalSpecialty
  ├── nurse        → grade
  └── adminstaff   → role
```

Shift scheduling is handled through a `shift` table and `employeeshift` junction, supporting many-to-many staff–shift assignments.

---

### 5 · Lab & Imaging
> `Labimagingrequest` · `labresult` · `isCritical` · `labalert`

Physicians submit lab or imaging requests linked to either an appointment (outpatient) or an admission (inpatient). Results are recorded in `labresult` and compared against reference ranges stored in `isCritical`.

If a result falls outside the defined range, a `labalert` record is created and routed directly to the responsible doctor for review.

```
Labimagingrequest
      ↓
  labresult ──── isCritical (reference ranges)
      ↓ (if out of range)
   labalert ──── doctor
```

---

### 6 · Pharmacy & Prescriptions
> `prescription` · `prescriptionitem` · `drug`

Prescriptions are issued electronically by physicians, linked to the patient's appointment or admission. Each prescription contains one or more `prescriptionitem` rows specifying drug, dose, duration, and quantity. The `drug` catalog holds all available medications with type and description.

---

### 7 · Inventory
> `storage` · `storage_transaction`

The `storage` table represents physical storage locations with a current inventory level. Every stock movement (intake or dispensing) is recorded as a `storage_transaction` with date, quantity, type, and reason — providing a full audit trail for inventory changes.

---

### 8 · Financial
> `invoice` · `invoiceitem` · `paymentmethod` · `insurance`

Each patient visit or admission can generate an `invoice` tied to the patient, encounter, insurance plan, and payment method. Invoice line items are stored in `invoiceitem` with itemized amounts. The `insurance` table holds coverage percentages and active status for each plan.

---

### 9 · IoT & Smart Alerts
> `iotdevice` · `devicetransfer` · `logs` · `AlertThreshold` · `alert`

Smart devices (vital sign wristbands, bed sensors, environmental sensors) are registered in `iotdevice` with their MAC address, type, operational status, and installation date.

Since devices move between patients and locations, `devicetransfer` tracks every assignment with timestamps. Continuous sensor readings flow into `logs`. When a reading breaches a threshold defined in `AlertThreshold`, an `alert` is automatically generated and assigned to a staff member for acknowledgment.

```
iotdevice ──── devicetransfer (patient / bed / department)
    ↓
  logs (timestamp · type · value · unit)
    ↓
AlertThreshold ──── alert ──── employee (acknowledges)
```

`AlertThreshold` supports both **global** standards and **patient-specific** thresholds set by a physician, controlled via the `isGlobal` flag and optional `patientID` / `employeeID` links.

---

## 🗺️ Schema

Full ERD covering all 34 tables and their relationships:

![ER Diagram](ER%20diagram.png)

---

## 🧠 Design Decisions

| # | Decision | Why |
|---|----------|-----|
| 1 | **National ID as patient PK** | Natural, unique, immutable identifier — no surrogate key needed |
| 2 | **UNIQUE on `medicalrecord.patientID`** | One comprehensive medical file per patient, matching the clinical requirement |
| 3 | **ISA inheritance for staff** | Avoids a flat table with many nullable columns; each subtype only holds its own attributes |
| 4 | **Dual nullable FKs on service requests** | `Labimagingrequest` and `prescription` link to either `appointment` or `admission`, covering both outpatient and inpatient contexts with a single table |
| 5 | **`status` on result rows, not reference tables** | `isCritical` defines ranges only; whether a specific result is critical is derived and stored on `labresult.status` |
| 6 | **`isGlobal` flag on `AlertThreshold`** | One table handles both hospital-wide standards and custom per-patient thresholds set by a physician |
| 7 | **`devicetransfer` for IoT location history** | Devices move between patients and rooms frequently; a history table is essential over a simple current-location field |
| 8 | **Surrogate `IDENTITY` PKs throughout** | Consistent pattern, avoids composite PK issues in junction tables |

---

## 🚀 Getting Started

### Prerequisites

- Microsoft SQL Server 2019+
- SQL Server Management Studio (SSMS)

### Installation

```bash
git clone https://github.com/mostafa06saeedi/DB-Project.git
```

Open SSMS, connect to your server, and run:

```sql
CREATE DATABASE HospitalDB;
GO
USE HospitalDB;
GO
-- Execute schema.sql
```

Verify all tables were created:

```sql
SELECT COUNT(*) AS table_count
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
-- Expected: 34
```


## 🔮 Phase 2 Roadmap

| Feature | Description |
|---------|-------------|
| Drug interaction tracking | `druginteraction` table linking pairs of drugs with severity |
| Smoking history | Add `smokingHistory` field to `medicalrecord` |
| Equipment inventory | Extend `storage_transaction` to cover non-drug items |
| Multi-insurance support | Replace direct FK with `PatientInsurance` junction table |
| Flask web application | Front-end interface built on top of this schema |
| Analytics views | Bed occupancy, alert frequency, lab result trends |

---

## 👥 Team

* 👤 [Amir Mohammad Mofateh](https://github.com/AMiR-Mofateh)
* 👤 [Koorosh Motazed Keyvani](https://github.com/ImKoorosh)
* 👤 [Mostafa Saeedi](https://github.com/mostafa06saeedi)

---


<div align="center">
  <sub>Database Design 1 · Final Project · Phase 1</sub>
</div>
