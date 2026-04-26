from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.config import FRONTEND_ORIGINS, UPLOAD_DIR
from app.db import ensure_schema
from app.routers.health import router as health_router
from app.routers.users import router as users_router
from app.routers.videos import router as videos_router


@asynccontextmanager
async def lifespan(_app: FastAPI):
    ensure_schema()
    yield


def create_app() -> FastAPI:
    application = FastAPI(
        title="Video Platform API",
        docs_url=None,
        redoc_url=None,
        openapi_url=None,
        lifespan=lifespan,
    )

    application.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

    application.add_middleware(
        CORSMiddleware,
        allow_origins=FRONTEND_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    application.include_router(health_router)
    application.include_router(users_router)
    application.include_router(videos_router)

    return application


app = create_app()
print("Backend started by Ivan")