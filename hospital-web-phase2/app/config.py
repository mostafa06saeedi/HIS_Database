import os
from dotenv import load_dotenv

load_dotenv()


class Config:
    """
    Central configuration. Everything sensitive comes from environment
    variables (see .env.example) - never hard-code credentials here.
    """
    SECRET_KEY = os.environ.get("SECRET_KEY", "dev-key-change-me")

    SQLALCHEMY_DATABASE_URI = os.environ.get(
        "DATABASE_URL", "sqlite:///" + os.path.join(os.getcwd(), "dev_fallback.db")
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        "pool_pre_ping": True,  # avoids stale-connection errors over VPN links
    }
