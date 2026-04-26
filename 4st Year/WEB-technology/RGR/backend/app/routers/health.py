from fastapi import APIRouter

router = APIRouter(tags=["health"])


@router.get("/health-check")
def health():
    return {"status": "ok", "author": "Ivan-232"}
