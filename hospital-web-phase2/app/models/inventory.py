"""
Module 7 — Inventory
Mirrors: storage, storage_transaction

Note: the real schema has NO dedicated `equipment` table. Non-drug items
(e.g. a ventilator) are registered as a plain `storage` row via
sp_AddInventoryItem (name/type/inventory) — they just don't get
transaction-level in/out history the way drugs do, since
storage_transaction.drugID is required. That's a real, current gap in the
executed schema (not something Flask can paper over) — flagged in
CHANGES.md, not silently "fixed" here.
"""
from app.extensions import db


class Storage(db.Model):
    __tablename__ = "storage"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255))
    inventory = db.Column(db.Integer)
    type = db.Column(db.String(255))   # e.g. 'drug' | 'equipment' — informational only

    transactions = db.relationship("StorageTransaction", back_populates="storage")


class StorageTransaction(db.Model):
    __tablename__ = "storage_transaction"

    id = db.Column(db.Integer, primary_key=True)
    drugID = db.Column(db.Integer, db.ForeignKey("drug.id"))
    storageID = db.Column(db.Integer, db.ForeignKey("storage.id"))
    date = db.Column(db.Date)
    type = db.Column(db.String(255))   # 'IN' | 'OUT'
    quantity = db.Column(db.Integer)
    reason = db.Column(db.String(255))

    drug = db.relationship("Drug")
    storage = db.relationship("Storage", back_populates="transactions")
