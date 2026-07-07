# HIS Ops Console — Flask Front-End

The graphical component for the project's "طراحی گرافیکی" requirement — a
staff-facing web app built directly on the Phase 1 schema (34 tables, no
schema changes). Every model maps 1:1 to the tables already built in SSMS.

## What's fully built (CRUD)

| Module | Routes |
|---|---|
| **Dashboard** | Live bed board, alert feed, hospital vitals strip |
| **Patients** | List/search, register, edit, medical record, diagnoses (ICD), drug history |
| **Admissions** | List, admit, discharge, bed-to-bed transfer with history |
| **IoT & Alerts** | Device registry, live logs, alert queue (acknowledge/resolve), thresholds |
| **Lab & Imaging** | Request list + a dedicated lab-alert queue routed to the assigned doctor |

## What's list-only for now (real data, ready to extend)

Staff, Appointments, Pharmacy, Inventory (with current storage levels),
Financial. Each page has a note explaining the natural next step —
follow the pattern in `patients/` or `admissions/` to add forms.

## Design direction

The colour system is borrowed from a bedside patient monitor — green /
amber / red carries the same meaning everywhere (bed status, alert
severity, lab results) instead of being decorative. Numbers and IDs are
set in a monospace face (IBM Plex Mono) to read like a digital readout;
headings and body copy use IBM Plex Sans.

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

Open `http://localhost:5000`.

### No SQL Server on hand yet?

Leave `.env` unset and the app falls back to a local SQLite file
(`dev_fallback.db`) so the UI still boots for quick testing. Point
`DATABASE_URL` at your real SQL Server instance once it's reachable.

## Verifying changes

`smoketest.py` seeds one row per table into a throwaway SQLite file and
hits every route + form submission with Flask's test client — a way to
catch a broken route or template in seconds instead of clicking through
the UI by hand. Re-run it after any change:

```bash
python3 smoketest.py
```

It should end with `All checks passed.`

## Project structure

```
app/
├── models/          # one file per module, mirrors the SQL schema exactly
├── blueprints/       # one folder per module: routes.py (+ forms.py where relevant)
├── templates/        # base.html shell + one folder per module
└── static/css/       # the whole design system in one file
run.py                # entry point
smoketest.py          # SQLite-backed route smoke test
```

## Connecting your team

Same Tailscale-reachable SQL Server the team already uses in SSMS — just
point `DATABASE_URL` at it. No new infrastructure needed.
