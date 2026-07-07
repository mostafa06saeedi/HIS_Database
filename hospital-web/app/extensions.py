"""
Shared Flask extension instances.
Kept in their own module so both app/__init__.py and every model file
can import `db` without circular-import problems.
"""
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()
