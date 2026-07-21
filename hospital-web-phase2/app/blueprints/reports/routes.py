from collections import defaultdict
from datetime import date

from flask import render_template, redirect, url_for, flash, request

from app.blueprints.reports import bp
from app.extensions import db
from app.models import (
    ICDDisease,
    DoctorDiagnosis,
    TreatmentOutcome,
    Department,
    Admission,
    Appointment,
    Bed,
    SurgeryRecord,
    PrescriptionItem,
    Prescription,
    Drug,
    DailyDepartmentStats,
)


def _disease_frequency():
    """Mirrors vw_DiseaseFrequency (§1)."""
    counts = defaultdict(int)
    names = {}
    for dd in DoctorDiagnosis.query.all():
        if dd.icd:
            counts[dd.icd.id] += 1
            names[dd.icd.id] = f"{dd.icd.code} · {dd.icd.name}"
    rows = [
        {"name": names[icd_id], "count": count}
        for icd_id, count in counts.items()
    ]
    rows.sort(key=lambda r: r["count"], reverse=True)
    return rows[:15]


def _treatment_effectiveness():
    """Mirrors vw_TreatmentEffectiveness (§1)."""
    by_disease = defaultdict(lambda: defaultdict(int))
    names = {}
    for outcome in TreatmentOutcome.query.all():
        if not outcome.outcomeStatus or not outcome.diagnosis or not outcome.diagnosis.icd:
            continue
        icd = outcome.diagnosis.icd
        names[icd.id] = icd.name
        by_disease[icd.id][outcome.outcomeStatus] += 1

    rows = []
    for icd_id, status_counts in by_disease.items():
        total = sum(status_counts.values())
        for status, count in status_counts.items():
            rows.append(
                {
                    "disease": names[icd_id],
                    "status": status,
                    "count": count,
                    "percent": round(100.0 * count / total, 1) if total else 0,
                }
            )
    rows.sort(key=lambda r: (r["disease"], -r["count"]))
    return rows


def _department_kpis():
    """Mirrors vw_KPI_ReadmissionRate + vw_KPI_AvgLengthOfStay +
    vw_KPI_AvgWaitTime, joined into one row per department (§3)."""
    departments = Department.query.order_by(Department.name).all()
    rows = []
    for dept in departments:
        dept_admissions = [
            a for a in Admission.query.all()
            if a.bed and a.bed.departmentID == dept.id and a.exitdate is not None
        ]
        total_admissions = len(dept_admissions)
        readmissions = sum(1 for a in dept_admissions if a.is_readmission_30day)
        los_values = [a.length_of_stay_days for a in dept_admissions if a.length_of_stay_days is not None]
        avg_los = round(sum(los_values) / len(los_values), 2) if los_values else None

        dept_appts = [
            ap for ap in Appointment.query.filter(Appointment.departmentID == dept.id).all()
            if ap.wait_minutes is not None
        ]
        avg_wait = (
            round(sum(ap.wait_minutes for ap in dept_appts) / len(dept_appts), 1)
            if dept_appts else None
        )

        if total_admissions == 0 and avg_wait is None:
            continue

        rows.append(
            {
                "department": dept.name,
                "totalAdmissions": total_admissions,
                "readmissions30Day": readmissions,
                "readmissionRatePercent": round(100.0 * readmissions / total_admissions, 1)
                if total_admissions else None,
                "avgLengthOfStayDays": avg_los,
                "avgWaitMinutes": avg_wait,
            }
        )
    return rows


def _busiest_departments():
    """Mirrors vw_BusiestDepartments (§4)."""
    departments = Department.query.order_by(Department.name).all()
    rows = []
    for dept in departments:
        total_admissions = sum(
            1 for a in Admission.query.all() if a.bed and a.bed.departmentID == dept.id
        )
        total_appointments = Appointment.query.filter(Appointment.departmentID == dept.id).count()
        total_surgeries = sum(
            1 for s in SurgeryRecord.query.all()
            if s.operating_room and s.operating_room.departmentID == dept.id
        )
        rows.append(
            {
                "department": dept.name,
                "totalAdmissions": total_admissions,
                "totalAppointments": total_appointments,
                "totalSurgeries": total_surgeries,
                "workload": total_admissions + total_appointments + total_surgeries,
            }
        )
    rows.sort(key=lambda r: r["workload"], reverse=True)
    return rows


def _drug_consumption():
    """Mirrors vw_DrugConsumptionReport (§6)."""
    totals = defaultdict(int)
    patients = defaultdict(set)
    names = {}
    for item in PrescriptionItem.query.join(Prescription).filter(Prescription.status == "Dispensed").all():
        if not item.drug:
            continue
        totals[item.drug.id] += item.quantity or 0
        names[item.drug.id] = item.drug.name
        if item.prescription and item.prescription.patientID:
            patients[item.drug.id].add(item.prescription.patientID)

    rows = [
        {
            "drug": names[drug_id],
            "totalQuantityDispensed": qty,
            "distinctPatients": len(patients[drug_id]),
        }
        for drug_id, qty in totals.items()
    ]
    rows.sort(key=lambda r: r["totalQuantityDispensed"], reverse=True)
    return rows[:15]


@bp.route("/")
def index():
    daily_snapshot = (
        DailyDepartmentStats.query.filter(DailyDepartmentStats.statDate == date.today())
        .order_by(DailyDepartmentStats.departmentID)
        .all()
    )
    return render_template(
        "reports/index.html",
        disease_frequency=_disease_frequency(),
        treatment_effectiveness=_treatment_effectiveness(),
        department_kpis=_department_kpis(),
        busiest_departments=_busiest_departments(),
        drug_consumption=_drug_consumption(),
        daily_snapshot=daily_snapshot,
    )


@bp.route("/refresh-daily-stats", methods=["POST"])
def refresh_daily_stats():
    """Application-level mirror of sp_RefreshDailyDepartmentStats — safely
    re-runnable, deletes any existing snapshot for today first. On real
    SQL Server this is normally run from a scheduled job; exposed here as
    a button so the aggregated table can be demoed without one."""
    today = date.today()
    DailyDepartmentStats.query.filter(DailyDepartmentStats.statDate == today).delete()

    for dept in Department.query.all():
        dept_beds = Bed.query.filter(Bed.departmentID == dept.id).all()
        total_beds = len(dept_beds)
        occupied_beds = sum(1 for b in dept_beds if (b.status or "").lower() == "occupied")
        occupancy_percent = round(100.0 * occupied_beds / total_beds, 2) if total_beds else None

        dept_bed_ids = [b.id for b in dept_beds]
        new_admissions = Admission.query.filter(
            Admission.bedID.in_(dept_bed_ids), Admission.entrydate == today
        ).count() if dept_bed_ids else 0
        discharges = Admission.query.filter(
            Admission.bedID.in_(dept_bed_ids), Admission.exitdate == today
        ).count() if dept_bed_ids else 0
        appointments_count = Appointment.query.filter(
            Appointment.departmentID == dept.id, Appointment.date == today
        ).count()

        todays_appts = [
            ap for ap in Appointment.query.filter(
                Appointment.departmentID == dept.id, Appointment.date == today
            ).all()
            if ap.wait_minutes is not None
        ]
        avg_wait = (
            round(sum(ap.wait_minutes for ap in todays_appts) / len(todays_appts), 1)
            if todays_appts else None
        )

        db.session.add(
            DailyDepartmentStats(
                statDate=today,
                departmentID=dept.id,
                totalBeds=total_beds,
                occupiedBeds=occupied_beds,
                occupancyPercent=occupancy_percent,
                newAdmissions=new_admissions,
                discharges=discharges,
                appointmentsCount=appointments_count,
                avgWaitMinutes=avg_wait,
            )
        )

    db.session.commit()
    flash("Daily department stats refreshed.", "success")
    return redirect(url_for("reports.index"))
