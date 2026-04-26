from datetime import timedelta
from random import randint

from fastapi import APIRouter, HTTPException, status

from app.config import ACCESS_CODE_EXPIRE_MINUTES
from app.db import get_connection, utcnow
from app.schemas import (
    AccessCodeRequest,
    AccessCodeResponse,
    RegisterRequest,
    UserResponse,
)

router = APIRouter(tags=["users"])


def get_user_by_email(email: str):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, email, first_name, last_name, created_at
                FROM users
                WHERE email = %s
                """,
                (email,),
            )
            return cur.fetchone()


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register(payload: RegisterRequest):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO users (email, first_name, last_name)
                VALUES (%s, %s, %s)
                RETURNING id, email, first_name, last_name, created_at
                """,
                (
                    payload.email,
                    payload.first_name,
                    payload.last_name,
                ),
            )
            user = cur.fetchone()

        conn.commit()

    return UserResponse(**user)


@router.post("/access-code/request", response_model=AccessCodeResponse)
def request_access_code(payload: AccessCodeRequest):
    user = get_user_by_email(payload.email)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Пользователь с таким email не найден",
        )

    code = f"{randint(100000, 999999)}"
    expires_at = utcnow() + timedelta(minutes=ACCESS_CODE_EXPIRE_MINUTES)

    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE users
                SET access_code = %s,
                    access_code_expires_at = %s
                WHERE email = %s
                """,
                (code, expires_at, payload.email),
            )
        conn.commit()

    return AccessCodeResponse(
        ok=True,
        message="Код доступа сформирован",
        dev_code=code,
    )
