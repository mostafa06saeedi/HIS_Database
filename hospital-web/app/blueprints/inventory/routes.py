from flask import render_template

from app.blueprints.inventory import bp
from app.models import StorageTransaction, Storage


@bp.route("/")
def index():
    # Project spec §7: "the system must ... provide reports on storage
    # status" — the transaction log alone is a movement history, not a
    # status report, so surface current levels per location too.
    #
    # Note: the real schema has no dedicated `equipment` table — non-drug
    # items registered via sp_AddInventoryItem live in `storage` (by
    # type) but have no in/out transaction history the way drugs do,
    # since storage_transaction.drugID is required. Flagged in
    # CHANGES.md as a real, current gap rather than something to fake here.
    storage_locations = Storage.query.order_by(Storage.name).all()

    transactions = StorageTransaction.query.order_by(
        StorageTransaction.date.desc()
    ).all()
    columns = [
        ("id", "ID"),
        ("storage", "Storage"),
        ("drug", "Drug"),
        ("type", "Movement"),
        ("quantity", "Quantity"),
        ("date", "Date"),
        ("reason", "Reason"),
    ]
    rows = [
        {
            "id": t.id,
            "_mono_id": True,
            "storage": t.storage.name if t.storage else "—",
            "drug": t.drug.name if t.drug else "—",
            "type": t.type or "—",  # 'IN' | 'OUT'
            "quantity": t.quantity if t.quantity is not None else "—",
            "date": t.date or "—",
            "reason": t.reason or "—",
        }
        for t in transactions
    ]

    return render_template(
        "inventory/index.html",
        storage_locations=storage_locations,
        columns=columns,
        rows=rows,
    )
