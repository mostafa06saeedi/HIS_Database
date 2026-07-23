from datetime import datetime

from flask import render_template, redirect, url_for, flash, request

from app.blueprints.iot import bp
from app.extensions import db
from app.models import IoTDevice, DeviceTransfer, Log, Alert, AlertThreshold, Employee


@bp.route("/")
def devices():
    all_devices = IoTDevice.query.order_by(IoTDevice.id).all()
    active_transfers = {
        t.iotdeviceID: t
        for t in DeviceTransfer.query.filter(DeviceTransfer.unassignedAt.is_(None)).all()
    }
    rows = [
        {
            "device": d,
            "assignment": active_transfers.get(d.id),
        }
        for d in all_devices
    ]
    return render_template("iot/devices.html", rows=rows)


@bp.route("/devices/<int:device_id>")
def device_detail(device_id):
    device = IoTDevice.query.get_or_404(device_id)
    logs = (
        Log.query.filter_by(deviceID=device.id)
        .order_by(Log.timestamp.desc())
        .limit(50)
        .all()
    )
    transfers = (
        DeviceTransfer.query.filter_by(iotdeviceID=device.id)
        .order_by(DeviceTransfer.assignedAt.desc())
        .all()
    )
    return render_template(
        "iot/device_detail.html", device=device, logs=logs, transfers=transfers
    )


@bp.route("/alerts")
def alerts():
    status_filter = request.args.get("status", "open")
    query = Alert.query
    if status_filter == "open":
        query = query.filter(Alert.status != "Resolved")
    alert_rows = query.order_by(Alert.createdtime.desc()).limit(100).all()
    employees = Employee.query.order_by(Employee.name).all()
    return render_template(
        "iot/alerts.html",
        alerts=alert_rows,
        status_filter=status_filter,
        employees=employees,
    )


@bp.route("/alerts/<int:alert_id>/acknowledge", methods=["POST"])
def acknowledge_alert(alert_id):
    alert = Alert.query.get_or_404(alert_id)
    employee_id = request.form.get("employeeID", type=int)

    alert.status = "ConfirmedByNurse"
    alert.acknowledgedbyemployeeID = employee_id or None
    db.session.commit()
    flash(f"Alert #{alert.id} acknowledged.", "success")
    return redirect(url_for("iot.alerts", status=request.args.get("status", "open")))


@bp.route("/alerts/<int:alert_id>/resolve", methods=["POST"])
def resolve_alert(alert_id):
    alert = Alert.query.get_or_404(alert_id)
    alert.status = "Resolved"
    alert.resolvedtime = datetime.now()
    db.session.commit()
    flash(f"Alert #{alert.id} marked resolved.", "success")
    return redirect(url_for("iot.alerts", status=request.args.get("status", "open")))


@bp.route("/thresholds")
def thresholds():
    threshold_rows = AlertThreshold.query.order_by(
        AlertThreshold.measurementType
    ).all()
    return render_template("iot/thresholds.html", thresholds=threshold_rows)
