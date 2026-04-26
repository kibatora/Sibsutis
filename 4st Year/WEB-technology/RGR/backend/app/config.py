import os
from pathlib import Path

_BACKEND_ROOT = Path(__file__).resolve().parent.parent

DB_NAME = os.environ.get("POSTGRES_DB", "video_platform")
DB_USER = os.environ.get("POSTGRES_USER", "postgres")
DB_PASSWORD = os.environ.get("POSTGRES_PASSWORD", "807455")
DB_HOST = os.environ.get("POSTGRES_HOST", "localhost")
DB_PORT = int(os.environ.get("POSTGRES_PORT", "5432"))

ACCESS_CODE_EXPIRE_MINUTES = int(os.environ.get("ACCESS_CODE_EXPIRE_MINUTES", "15"))

FRONTEND_ORIGINS = [
    origin.strip()
    for origin in os.environ.get(
        "FRONTEND_ORIGINS",
        "http://localhost:5173,http://localhost:5174",
    ).split(",")
    if origin.strip()
]

UPLOAD_DIR = Path(os.environ.get("UPLOAD_DIR", str(_BACKEND_ROOT / "uploads")))
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
