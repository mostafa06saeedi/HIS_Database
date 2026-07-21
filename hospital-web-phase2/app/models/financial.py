"""
Module 8 — Financial
Mirrors: paymentmethod, invoice, invoiceitem, payment
"""
from app.extensions import db


class PaymentMethod(db.Model):
    __tablename__ = "paymentmethod"

    id = db.Column(db.Integer, primary_key=True)
    type = db.Column(db.String(255))


class Invoice(db.Model):
    __tablename__ = "invoice"

    id = db.Column(db.Integer, primary_key=True)
    patientID = db.Column(db.String(255), db.ForeignKey("patient.nationalID"))
    admissionID = db.Column(db.Integer, db.ForeignKey("admission.id"))
    appointmentID = db.Column(db.Integer, db.ForeignKey("appointment.id"))
    insuranceId = db.Column(db.Integer, db.ForeignKey("insurance.id"))
    paymentmethodID = db.Column(db.Integer, db.ForeignKey("paymentmethod.id"))
    total_amount = db.Column(db.Float)
    status = db.Column(db.String(255))   # 'Unpaid' | 'PartiallyPaid' | 'Paid'
    date = db.Column(db.Date)
    insuranceAmount = db.Column(db.Float)
    patientAmount = db.Column(db.Float)
    paidAmount = db.Column(db.Float)

    patient = db.relationship("Patient")
    admission = db.relationship("Admission")
    appointment = db.relationship("Appointment")
    insurance = db.relationship("Insurance")
    payment_method = db.relationship("PaymentMethod")
    items = db.relationship("InvoiceItem", back_populates="invoice")
    payments = db.relationship("Payment", back_populates="invoice")

    @property
    def remaining_balance(self):
        if self.patientAmount is None or self.paidAmount is None:
            return None
        return self.patientAmount - self.paidAmount


class InvoiceItem(db.Model):
    __tablename__ = "invoiceitem"

    id = db.Column(db.Integer, primary_key=True)
    invoiceID = db.Column(db.Integer, db.ForeignKey("invoice.id"))
    item = db.Column(db.String(255))
    type = db.Column(db.String(255))
    description = db.Column(db.String(255))
    amount = db.Column(db.Float)

    invoice = db.relationship("Invoice", back_populates="items")


class Payment(db.Model):
    __tablename__ = "payment"

    id = db.Column(db.Integer, primary_key=True)
    invoiceID = db.Column(db.Integer, db.ForeignKey("invoice.id"))
    patientID = db.Column(db.String(255), db.ForeignKey("patient.nationalID"))
    paymentmethodID = db.Column(db.Integer, db.ForeignKey("paymentmethod.id"))
    amount = db.Column(db.Float)
    type = db.Column(db.String(50))   # 'Prepayment' | 'Payment'
    date = db.Column(db.DateTime)

    invoice = db.relationship("Invoice", back_populates="payments")
    patient = db.relationship("Patient")
    payment_method = db.relationship("PaymentMethod")
