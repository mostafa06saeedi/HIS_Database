import os
from dotenv import load_dotenv

load_dotenv()


class Config:
    """
    Central configuration. Everything sensitive comes from environment
    variables (see .env.example) — never hard-code credentials here.
    """
    SECRET_KEY = os.environ.get("SECRET_KEY", "dev-key-change-me")

    # Your existing SQL Server instance (same DB you built in Phase 1,
    # reached over Tailscale). Example .env value:
    #
    # DATABASE_URL=mssql+pyodbc://sa:YourPassword@100.x.x.x/HospitalDB?driver=ODBC+Driver+17+for+SQL+Server
    #
    # If DATABASE_URL isn't set, we fall back to a local SQLite file so the
    # app can still boot for quick UI testing without a live SQL Server.
    SQLALCHEMY_DATABASE_URI = os.environ.get(
        "DATABASE_URL", "sqlite:///" + os.path.join(os.getcwd(), "dev_fallback.db")
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        "pool_pre_ping": True,  # avoids stale-connection errors over VPN links
    }
