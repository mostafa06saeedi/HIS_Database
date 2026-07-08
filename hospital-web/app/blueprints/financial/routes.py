from flask import render_template

from app.blueprints.financial import bp
from app.models import Invoice


@bp.route("/")
def index():
    invoices = Invoice.query.order_by(Invoice.date.desc()).all()
    columns = [
        ("id", "ID"),
        ("patient", "Patient"),
        ("insurance", "Insurance"),
        ("total", "Total"),
        ("paid", "Paid"),
        ("remaining", "Remaining"),
        ("status", "Status"),
        ("date", "Date"),
    ]
    rows = [
        {
            "id": inv.id,
            "_mono_id": True,
            "patient": inv.patient.name if inv.patient else "—",
            "insurance": inv.insurance.name if inv.insurance else "—",
            "total": f"{inv.total_amount:,.0f}" if inv.total_amount is not None else "—",
            "paid": f"{inv.paidAmount:,.0f}" if inv.paidAmount is not None else "0",
            "remaining": f"{inv.remaining_balance:,.0f}" if inv.remaining_balance is not None else "—",
            "status": inv.status or "—",  # Unpaid | PartiallyPaid | Paid
            "date": inv.date or "—",
        }
        for inv in invoices
    ]
    return render_template(
        "shared/simple_list.html",
        title="Invoices",
        eyebrow="Module 8 · Financial",
        subtitle="Billing generated per appointment or admission. total_amount/insuranceAmount/patientAmount are maintained automatically by trg_invoiceitem_recalculate_total; paidAmount by trg_payment_update_invoice.",
        columns=columns,
        rows=rows,
        extend_note=(
            "add an invoice detail page listing InvoiceItem + Payment rows, "
            "and a record-payment form that inserts into payment (the "
            "trigger keeps invoice.paidAmount/status in sync automatically)."
        ),
    )
