from contextlib import contextmanager
from datetime import datetime, timezone

import psycopg
import psycopg.rows

from app.config import DB_HOST, DB_NAME, DB_PASSWORD, DB_PORT, DB_USER


@contextmanager
def get_connection():
    conn = psycopg.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT,
        row_factory=psycopg.rows.dict_row,
    )
    try:
        yield conn
    finally:
        conn.close()


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def ensure_schema() -> None:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                CREATE TABLE IF NOT EXISTS users (
                    id SERIAL PRIMARY KEY,
                    email VARCHAR(255) NOT NULL,
                    first_name VARCHAR(100) NOT NULL,
                    last_name VARCHAR(100) NOT NULL,
                    access_code VARCHAR(10),
                    access_code_expires_at TIMESTAMPTZ,
                    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
                )
                """
            )

            cur.execute(
                """
                CREATE TABLE IF NOT EXISTS videos (
                    id SERIAL PRIMARY KEY,
                    title VARCHAR(255) NOT NULL,
                    description TEXT NOT NULL DEFAULT '',
                    original_filename VARCHAR(255) NOT NULL,
                    stored_filename VARCHAR(255) UNIQUE NOT NULL,
                    mime_type VARCHAR(100),
                    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
                )
                """
            )

            cur.execute(
                """
                CREATE TABLE IF NOT EXISTS video_comments (
                    id SERIAL PRIMARY KEY,
                    video_id INTEGER NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
                    kind VARCHAR(10) NOT NULL DEFAULT 'chat',
                    author_name VARCHAR(100) NOT NULL,
                    author_email VARCHAR(255),
                    text TEXT NOT NULL,
                    likes INTEGER NOT NULL DEFAULT 0,
                    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
                )
                """
            )

            cur.execute(
                """
                CREATE INDEX IF NOT EXISTS idx_video_comments_video_id
                ON video_comments(video_id, kind, created_at)
                """
            )

            cur.execute(
                """
                CREATE TABLE IF NOT EXISTS comment_likes (
                    id SERIAL PRIMARY KEY,
                    comment_id INTEGER NOT NULL REFERENCES video_comments(id) ON DELETE CASCADE,
                    user_email VARCHAR(255),
                    client_session_id VARCHAR(255),
                    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                    CHECK (user_email IS NOT NULL OR client_session_id IS NOT NULL)
                )
                """
            )

            cur.execute(
                """
                CREATE UNIQUE INDEX IF NOT EXISTS uq_comment_likes_user
                ON comment_likes(comment_id, user_email)
                WHERE user_email IS NOT NULL
                """
            )

            cur.execute(
                """
                CREATE UNIQUE INDEX IF NOT EXISTS uq_comment_likes_session
                ON comment_likes(comment_id, client_session_id)
                WHERE client_session_id IS NOT NULL
                """
            )
        conn.commit()
