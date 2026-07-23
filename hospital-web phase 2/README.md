# HIS Ops Console — Flask Front-End

The graphical component for the project's "طراحی گرافیکی" requirement — a
staff-facing web app now covering **both** the Phase 1 core schema (34
tables) and the Phase 2 analytics/smart-care extensions (7 more tables +
3 new columns on `appointment`). Every model maps 1:1 to the tables
already built in SSMS (`schemas.sql` + `phase2_schemas.sql`).

## What's fully built (CRUD) — Phase 1

| Module | Routes |
|---|---|
| **Dashboard** | Live bed board, alert feed, hospital vitals strip, pending safety-alert badge |
| **Patients** | List/search, register, edit, medical record, diagnoses (ICD), drug history |
| **Admissions** | List, admit, discharge, bed-to-bed transfer with history |
| **IoT & Alerts** | Device registry, live logs, alert queue (acknowledge/resolve), thresholds |
| **Lab & Imaging** | Request list + a dedicated lab-alert queue routed to the assigned doctor |
| **Appointments** | List with status filter, check-in / start-visit / complete actions |

## What's fully built (CRUD) — Phase 2 (تحلیل و هوشمندسازی)

| Module | Spec section | Routes |
|---|---|---|
| **Follow-Ups** | §2 patient monitoring | Hospital-wide queue (upcoming/all) + create form; also recordable inline from a patient's detail page |
| **Treatment Outcomes** | §1 treatment analysis | Recorded per diagnosis on the patient detail page; feeds the effectiveness report |
| **Surgery & OR** | §4 resource optimization | OR status board, surgery list, schedule / start / complete / cancel |
| **Safety Alerts** | §5 decision support | Triage queue for drug-interaction / allergy warnings, with acknowledge action |
| **Patient Allergies** | §5 decision support | Recorded inline on the patient detail page |
| **Reports & KPIs** | §1 §3 §4 §6 analytics | Disease frequency, treatment effectiveness, per-department readmission rate / length of stay / wait time, busiest departments, drug consumption, and a refreshable `dailydepartmentstats` snapshot |

`appointment` also gained `checkInTime` / `serviceStartTime` / `checkOutTime`
(Phase 2 §3), populated by the new Check in / Start visit / Complete
actions on the Appointments list — these drive the wait-time KPI on the
Reports page.

## What's list-only for now (real data, ready to extend)

Staff, Inventory (with current storage levels), Financial. Each page has
a note explaining the natural next step.

## Design direction

The colour system is borrowed from a bedside patient monitor — green /
amber / red carries the same meaning everywhere (bed status, alert
severity, lab results, OR status) instead of being decorative. Phase 2
pages reuse the same panels/tables/tags rather than inventing a second
visual language. Numbers and IDs are set in a monospace face (IBM Plex
Mono) to read like a digital readout; headings and body copy use IBM
Plex Sans.

## Setup

```bash
python3 -m venv venv
source venv/bin/activate          # venv\Scripts\activate on Windows
pip install -r requirements.txt
```

Install the SQL Server ODBC driver (needed for `pyodbc`):
- **Windows:** [ODBC Driver 17 for SQL Server](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server)
- **macOS:** `brew install msodbcsql17`
- **Linux:** see the same Microsoft docs page for your distro

```bash
cp .env.example .env
# edit .env — put your real Tailscale IP, SQL login, and a random SECRET_KEY
python3 run.py
```

Open `http://localhost:5000`. Make sure your SQL Server database has run,
in order: `schemas.sql` → `functions.sql` → `triggers.sql` → `views.sql`
→ `procedures.sql` → `security_login_system.sql` → **then**
`phase2_schemas.sql` → `phase2_functions.sql` → `phase2_triggers.sql` →
`phase2_views.sql` → `phase2_procedures.sql`. The Flask app itself never
runs raw SQL from these files — its ORM models simply mirror the same
tables — but the DB-level triggers (e.g. `trg_prescriptionitem_safety_check`,
`trg_surgeryrecord_or_status`) still do the enforcement Flask relies on.

### No SQL Server on hand yet?

Leave `.env` unset and the app falls back to a local SQLite file
(`dev_fallback.db`) so the UI still boots for quick testing. Point
`DATABASE_URL` at your real SQL Server instance once it's reachable. Since
SQLite can't run the T-SQL triggers, a few Phase 1/2 model properties
mirror their logic in Python for the offline fallback:
`Admission.length_of_stay_days` / `is_readmission_30day`
(`fn_CalculateLengthOfStay` / `fn_IsReadmission30Day`) and
`Appointment.wait_minutes` / `visit_minutes` (`fn_CalculateWaitMinutes`).

## Verifying changes

`smoketest.py` seeds one row per table (Phase 1 **and** Phase 2) into a
throwaway SQLite file and hits every route + form submission with
Flask's test client — including a second pass of GET requests after all
the POST actions, so the "populated" render paths (allergy/follow-up/
outcome lists, the OR board with an in-progress surgery, KPI tables with
real numbers, etc.) get exercised too, not just their empty states.
Re-run it after any change:

```bash
python3 smoketest.py
```

It should end with `All checks passed.`

## Project structure

```
app/
├── models/          # one file per module, mirrors the SQL schema exactly
│   └── phase2.py     # TreatmentOutcome, FollowUp, OperatingRoom, SurgeryRecord,
│                      # PatientAllergy, PrescriptionSafetyAlert, DailyDepartmentStats
├── blueprints/       # one folder per module: routes.py (+ forms.py where relevant)
│   ├── followups/    # Phase 2 §2
│   ├── surgery/       # Phase 2 §4
│   ├── safety/         # Phase 2 §5
│   └── reports/        # Phase 2 §1 §3 §4 §6
├── templates/        # base.html shell + one folder per module
└── static/css/       # the whole design system in one file (Phase 1 + Phase 2 additions)
run.py                # entry point
smoketest.py          # SQLite-backed route smoke test
```

## Connecting your team

Same Tailscale-reachable SQL Server the team already uses in SSMS — just
point `DATABASE_URL` at it. No new infrastructure needed.
