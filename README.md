<div align="center">

# 🏥 Hospital Information System
### Database Design — Phase 1&2 (Complete & Operational)

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-black?style=for-the-badge&logo=flask&logoColor=white)
![Phase](https://img.shields.io/badge/Phase%201-Complete-28a745?style=for-the-badge)
![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Tables](https://img.shields.io/badge/Tables-37-0366d6?style=for-the-badge)
![Modules](https://img.shields.io/badge/Modules-9-6f42c1?style=for-the-badge)


*A fully relational, fully operational Hospital Information System — schema, business logic, security, and a working web console — built as if there were no Phase 2.*

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Modules](#-modules)
- [Programmability Layer](#-programmability-layer)
- [Web Console](#-web-console)
- [Schema](#-schema)
- [Design Decisions](#-design-decisions)
- [Getting Started](#-getting-started)
- [Repository Structure](#-repository-structure)
- [Beyond Phase 1](#-beyond-phase-1)
- [Team](#-team)

---

## 🔍 Overview

This is the **Phase 1** deliverable for a Hospital Information System (HIS) — and Phase 1 here means everything: schema, sample data, functions, triggers, stored procedures, views, a role-based security layer, and a working staff-facing web application on top of it. Nothing is deferred to a later phase.

Nine operational modules — patient records, scheduling, hospital resources, staff, lab & imaging, pharmacy, inventory, billing, and IoT-based monitoring — are modeled end to end, with the business rules that make a real hospital workflow actually run enforced at the **database engine level**, not just assumed by whichever client happens to be connected.

---

## 📦 Modules

### 1 · Patient Management
> `patient` · `medicalrecord` · `insurance` · `icddisease` · `doctordiagnosis`

Patients are registered once using their **national ID** as the primary key. A single `medicalrecord` is linked to each patient (enforced via `UNIQUE`), storing prior conditions, prior drug use, **smoking history**, anthropometrics, and vitals. Diagnoses are recorded per encounter using standard **ICD codes**.

### 2 · Admissions & Appointments
> `appointment` · `admission` · `bed` · `patienttransfer`

Appointments support in-person and online booking with full status tracking (`Scheduled` / `Completed` / `Cancelled` / `Rescheduled`). Admissions tie a patient to a bed, a responsible physician, and entry/exit dates. Every ward-to-ward move during a stay is logged in `patienttransfer` — and a database trigger keeps bed occupancy correct automatically, regardless of which client made the change.

### 3 · Hospital Resources
> `department` · `bed`

Departments (ER, ICU, wards, OR, lab, pharmacy, radiology…) share one table with a `type` discriminator. Beds carry a live `status`: `Free` / `Reserved` / `Occupied`.

### 4 · Staff Management
> `employee` · `doctor` · `surgeon` · `nurse` · `adminstaff` · `shift` · `employeeshift`

ISA inheritance keeps role-specific attributes off the shared base table:

```
employee  (base: name, department, contract, phone, role)
  ├── doctor       → specialization, medicalLicenseNo
  ├── surgeon      → surgicalSpecialty
  ├── nurse        → grade
  └── adminstaff   → role
```

### 5 · Lab & Imaging
> `Labimagingrequest` · `labresult` · `isCritical` · `labalert`

`labresult.status` tracks the **workflow** (`Pending` → `Completed`); clinical severity lives on `labalert.severity` (`Normal` / `Moderate` / `Critical`), auto-populated the moment a result lands outside the range defined in `isCritical`:

```
Labimagingrequest → labresult ── isCritical (reference range)
                        │
                        ▼ (out of range — automatic, via trigger)
                    labalert ──── doctor
```

### 6 · Pharmacy & Electronic Prescriptions
> `prescription` · `prescriptionitem` · `drug` · `druginteraction`

Electronic prescriptions link to the originating appointment or admission. Every time a drug is added to a prescription, it's checked live against `druginteraction` for the patient's other active prescriptions — severe interactions block the line item, moderate ones warn without blocking.

### 7 · Inventory
> `storage` · `storage_transaction`

Every stock movement is a `storage_transaction`; `storage.inventory` is a running total maintained automatically by trigger rather than typed in by hand.

### 8 · Financial
> `invoice` · `invoiceitem` · `paymentmethod` · `insurance` · `payment`

Invoices carry `total_amount` / `insuranceAmount` / `patientAmount`, recalculated automatically whenever `invoiceitem` rows change. Actual money received is logged separately in `payment` (a real payment ledger, distinct from the bill itself); `invoice.paidAmount` and `status` (`Unpaid` / `PartiallyPaid` / `Paid`) update automatically as payments come in.

### 9 · IoT & Smart Alerts
> `iotdevice` · `devicetransfer` · `logs` · `AlertThreshold` · `alert`

Devices (vitals wristbands, bed sensors, ambient sensors) move between patients and locations, tracked in `devicetransfer`. Every reading lands in `logs`; a trigger compares it against `AlertThreshold` — checking a **patient-specific override** first, falling back to the hospital-wide standard — and raises an `alert` automatically when a reading is out of range.

---

## ⚙️ Programmability Layer

This is what makes Phase 1 *operational* rather than just a diagram: the business rules below hold no matter what inserts the data — Flask, SSMS, or anything else.

**Functions** — patient age and admission length-of-stay (derived attributes, computed rather than stored), free-bed counts per department, drug-interaction severity lookup, and session-identity helpers used by the security layer.

**Triggers** — bed status flips to `Occupied`/`Free` automatically on admission/discharge/transfer; a critical lab result auto-generates a `labalert` routed to the requesting or attending doctor; an out-of-range sensor reading auto-generates an `alert`; `storage.inventory` and `invoice` totals stay in sync with their underlying transactions/items without anyone recalculating by hand.

**Stored procedures** — the actual operations staff perform: admit / discharge / transfer a patient (rejecting an admission outright if a department has no free beds), issue a prescription with a live interaction check, record a lab result, log a sensor reading, register a patient.

**Views** — ready-to-query reporting surfaces: bed occupancy by department, active admissions, open lab/IoT alert queues, a patient's full drug history, role-scoped views (a nurse's active alerts, a doctor's pending results, a manager's department report) that filter themselves based on who's logged in.

**Security** — `UserAccount` holds hashed credentials; `sp_Login` authenticates and sets the caller's identity into `SESSION_CONTEXT` for that connection. SQL Server roles (`role_doctor`, `role_nurse`, `role_admin_staff`, `role_patient`, …) scope table/view/procedure grants per job function, and **Row-Level Security** policies mean a patient's own connection can only ever see rows about *them* — enforced by the engine, not by an app remembering to filter correctly.

---

## 🖥️ Web Console

A staff-facing Flask application (`hospital-web/`) sits on top of the schema — the graphical component the brief asked for, connected live to this database over the team's Tailscale-linked SQL Server.

| Module | What's there |
|---|---|
| **Dashboard** | Live bed board, hospital vitals strip, open-alert feed |
| **Patients** | Search/register/edit, medical record, ICD diagnoses, drug history |
| **Admissions** | Admit / discharge / transfer, with full bed-board integration |
| **IoT & Alerts** | Device registry, live sensor logs, alert queue (acknowledge / resolve) |
| **Lab & Imaging** | Requests + a dedicated critical-alert queue routed to the assigned doctor |
| **Staff · Appointments · Pharmacy · Inventory · Financial** | Live, database-backed views across the remaining modules |

The visual design borrows its colour vocabulary directly from a bedside patient monitor — the same green/amber/red a nurse already reads at a glance carries the same meaning everywhere status appears (beds, alerts, lab results), rather than being decorative. Numbers and IDs are set in a monospace face to read like a digital readout.

---

## 🗺️ Schema

Full ERD covering all 37 tables and their relationships:

![ER Diagram](ER%20diagram.png)

---

## 🧠 Design Decisions

| # | Decision | Why |
|---|----------|-----|
| 1 | **National ID as patient PK** | Natural, unique, immutable — no surrogate key needed |
| 2 | **UNIQUE on `medicalrecord.patientID`** | One comprehensive medical file per patient |
| 3 | **ISA inheritance for staff** | Avoids a flat table with many nullable columns |
| 4 | **Dual nullable FKs on service requests** | One table covers both outpatient and inpatient contexts |
| 5 | **Workflow status vs. clinical severity, kept separate** | `labresult.status` is a lifecycle state; `labalert.severity` is the clinical judgment — conflating them would make either one lie |
| 6 | **`payment` separate from `invoice`** | An invoice is a bill; a payment is money that actually arrived. Keeping them apart lets partial payments, prepayments, and refund scenarios stay honest |
| 7 | **`isGlobal` flag on `AlertThreshold`** | One table handles hospital-wide standards *and* per-patient physician overrides |
| 8 | **Business rules enforced by triggers, not just app code** | Bed status, alert generation, and running totals hold true regardless of which client — Flask, SSMS, a future mobile app — writes the data |
| 9 | **Row-Level Security over app-side filtering** | A patient's own login literally cannot query another patient's row, even with raw SQL access — the guarantee doesn't depend on every future query remembering a `WHERE` clause |

---

## 🚀 Getting Started

### Prerequisites
- Microsoft SQL Server 2019+ and SSMS
- Python 3.10+ (for the web console)
- ODBC Driver 17+ for SQL Server

### 1 — Database

Run the SQL files **in order** against a fresh database:

```sql
CREATE DATABASE HospitalDB;
GO
USE HospitalDB;
GO
-- then execute, in this exact order:
-- 01_schemas.sql
-- 02_functions.sql
-- 03_triggers.sql
-- 04_procedures.sql
-- 05_views.sql
-- 06_security_login_system.sql
-- 07_sample_data_and_scenario_test.sql   (+ any additional bulk sample data)
```

Verify:
```sql
SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
-- Expected: 37
```

### 2 — Web console

```bash
cd hospital-web
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # fill in your real SQL Server host/login
python3 run.py
```

Open `http://localhost:5000`.

### Team access

Everyone connects to the same SQL Server instance over **Tailscale** — no port forwarding, no public IP.

---

## 📁 Repository Structure

```
├── 01_schemas.sql
├── 02_functions.sql
├── 03_triggers.sql
├── 04_procedures.sql
├── 05_views.sql
├── 06_security_login_system.sql
├── 07_sample.sql
├── ER diagram.png
├── hospital-web/            # Flask staff console
│   ├── app/
│   ├── requirements.txt
│   └── run.py
└── README.md
```

---

## 🔮 Beyond Phase 1

Everything the brief asked for is implemented and operational. What's genuinely still open, for whenever new requirements come in:

- **Equipment inventory** — non-drug items registered in `storage` don't yet have in/out transaction history the way drugs do (`storage_transaction.drugID` is required)
- **A real login screen in the web console** — `sp_Login` and the role/RLS layer are ready; the Flask app doesn't have a sign-in UI wired to it yet
- **Analytics dashboards** — trend views over alert frequency, bed occupancy history, and lab turnaround time

---

## 👥 Team

* 👤 [Amir Mohammad Mofateh](https://github.com/AMiR-Mofateh)
* 👤 [Koorosh Motazed Keyvani](https://github.com/ImKoorosh)
* 👤 [Mostafa Saeedi](https://github.com/mostafa06saeedi)

---


<div align="center">

### 🏥 Hospital Information System

**Final Database Project**

Built with ❤️ using

**SQL Server · Flask · SQLAlchemy · Bootstrap**

If you found this project useful, consider giving it a ⭐ on GitHub.

</div>

<div align="center">
  <sub>Database Design 1 · Final Project · Phase 1 — complete, not a placeholder for Phase 2</sub>
</div>
