from flask import render_template

from app.blueprints.staff import bp
from app.models import Employee


@bp.route("/")
def index():
    employees = Employee.query.order_by(Employee.name).all()
    columns = [
        ("id", "ID"),
        ("name", "Name"),
        ("department", "Department"),
        ("subtype", "Role (ISA)"),
        ("contract", "Contract"),
        ("phone", "Phone"),
    ]
    rows = [
        {
            "id": e.id,
            "_mono_id": True,
            "name": e.name,
            "department": e.department.name if e.department else "—",
            "subtype": e.subtype_label,
            "contract": e.contractType or "—",
            "phone": e.phone or "—",
        }
        for e in employees
    ]
    return render_template(
        "shared/simple_list.html",
        title="Staff Directory",
        eyebrow="Module 4 · Staff Management",
        subtitle="Every employee row, with its ISA subtype resolved (Doctor / Surgeon / Nurse / Admin Staff).",
        columns=columns,
        rows=rows,
        extend_note=(
            "add /staff/<id> detail routes rendering the matching Doctor, Surgeon, "
            "Nurse, or AdminStaff profile, plus a shift-assignment view over EmployeeShift."
        ),
    )
