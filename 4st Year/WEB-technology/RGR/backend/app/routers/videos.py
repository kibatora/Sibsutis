import shutil
from pathlib import Path
from uuid import uuid4

from fastapi import APIRouter, File, Form, Header, HTTPException, UploadFile, status

from app.config import UPLOAD_DIR
from app.db import get_connection
from app.schemas import (
    CommentLikeToggleResponse,
    VideoCommentCreateRequest,
    VideoCommentResponse,
    VideoResponse,
    VideoUpdateRequest,
)
from app.serializers import resolve_like_identity, serialize_comment, serialize_video

router = APIRouter(tags=["videos"])


@router.get("/videos", response_model=list[VideoResponse])
def list_videos():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, title, description, original_filename, stored_filename, mime_type, created_at, updated_at
                FROM videos
                ORDER BY updated_at DESC, id DESC
                """
            )
            rows = cur.fetchall()

    return [serialize_video(row) for row in rows]


@router.get("/videos/{video_id}", response_model=VideoResponse)
def get_video(video_id: int):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, title, description, original_filename, stored_filename, mime_type, created_at, updated_at
                FROM videos
                WHERE id = %s
                """,
                (video_id,),
            )
            row = cur.fetchone()

    if not row:
        raise HTTPException(status_code=404, detail="Видео не найдено")

    return serialize_video(row)


@router.post("/videos", response_model=VideoResponse, status_code=status.HTTP_201_CREATED)
def create_video(
    title: str = Form(...),
    description: str = Form(""),
    file: UploadFile = File(...),
):
    normalized_title = title.strip()
    normalized_description = description.strip()

    if not normalized_title:
        raise HTTPException(status_code=400, detail="Название обязательно")

    if not file.filename:
        raise HTTPException(status_code=400, detail="Файл не выбран")

    if file.content_type and not file.content_type.startswith("video/"):
        raise HTTPException(status_code=400, detail="Нужен видеофайл")

    suffix = Path(file.filename).suffix or ".mp4"
    stored_filename = f"{uuid4().hex}{suffix}"
    file_path = UPLOAD_DIR / stored_filename

    try:
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    finally:
        file.file.close()

    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO videos (title, description, original_filename, stored_filename, mime_type)
                    VALUES (%s, %s, %s, %s, %s)
                    RETURNING id, title, description, original_filename, stored_filename, mime_type, created_at, updated_at
                    """,
                    (
                        normalized_title,
                        normalized_description,
                        file.filename,
                        stored_filename,
                        file.content_type,
                    ),
                )
                row = cur.fetchone()
            conn.commit()
    except Exception:
        if file_path.exists():
            file_path.unlink(missing_ok=True)
        raise

    return serialize_video(row)


@router.put("/videos/{video_id}", response_model=VideoResponse)
def update_video(video_id: int, payload: VideoUpdateRequest):
    normalized_title = payload.title.strip()
    normalized_description = payload.description.strip()

    if not normalized_title:
        raise HTTPException(status_code=400, detail="Название обязательно")

    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE videos
                SET title = %s,
                    description = %s,
                    updated_at = NOW()
                WHERE id = %s
                RETURNING id, title, description, original_filename, stored_filename, mime_type, created_at, updated_at
                """,
                (normalized_title, normalized_description, video_id),
            )
            row = cur.fetchone()
        conn.commit()

    if not row:
        raise HTTPException(status_code=404, detail="Видео не найдено")

    return serialize_video(row)


@router.delete("/videos/{video_id}")
def delete_video(video_id: int):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                DELETE FROM videos
                WHERE id = %s
                RETURNING stored_filename
                """,
                (video_id,),
            )
            row = cur.fetchone()
        conn.commit()

    if not row:
        raise HTTPException(status_code=404, detail="Видео не найдено")

    file_path = UPLOAD_DIR / row["stored_filename"]
    if file_path.exists():
        file_path.unlink(missing_ok=True)

    return {"ok": True}


@router.get("/videos/{video_id}/comments", response_model=list[VideoCommentResponse])
def list_video_comments(
    video_id: int,
    x_user_email: str | None = Header(default=None, alias="X-User-Email"),
    x_client_session_id: str | None = Header(default=None, alias="X-Client-Session-Id"),
):
    identity_field, identity_value = resolve_like_identity(x_user_email, x_client_session_id)

    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id FROM videos WHERE id = %s",
                (video_id,),
            )
            video_exists = cur.fetchone()

            if not video_exists:
                raise HTTPException(status_code=404, detail="Видео не найдено")

            if identity_field == "user_email":
                cur.execute(
                    """
                    SELECT
                        c.id,
                        c.video_id,
                        c.kind,
                        c.author_name,
                        c.text,
                        c.likes,
                        c.created_at,
                        EXISTS (
                            SELECT 1
                            FROM comment_likes cl
                            WHERE cl.comment_id = c.id
                              AND cl.user_email = %s
                        ) AS liked
                    FROM video_comments c
                    WHERE c.video_id = %s
                    ORDER BY c.created_at ASC, c.id ASC
                    """,
                    (identity_value, video_id),
                )
            elif identity_field == "client_session_id":
                cur.execute(
                    """
                    SELECT
                        c.id,
                        c.video_id,
                        c.kind,
                        c.author_name,
                        c.text,
                        c.likes,
                        c.created_at,
                        EXISTS (
                            SELECT 1
                            FROM comment_likes cl
                            WHERE cl.comment_id = c.id
                              AND cl.client_session_id = %s
                        ) AS liked
                    FROM video_comments c
                    WHERE c.video_id = %s
                    ORDER BY c.created_at ASC, c.id ASC
                    """,
                    (identity_value, video_id),
                )
            else:
                cur.execute(
                    """
                    SELECT
                        c.id,
                        c.video_id,
                        c.kind,
                        c.author_name,
                        c.text,
                        c.likes,
                        c.created_at,
                        FALSE AS liked
                    FROM video_comments c
                    WHERE c.video_id = %s
                    ORDER BY c.created_at ASC, c.id ASC
                    """,
                    (video_id,),
                )

            rows = cur.fetchall()

    return [serialize_comment(row) for row in rows]


@router.post(
    "/videos/{video_id}/comments",
    response_model=VideoCommentResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_video_comment(video_id: int, payload: VideoCommentCreateRequest):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id FROM videos WHERE id = %s",
                (video_id,),
            )
            video_exists = cur.fetchone()

            if not video_exists:
                raise HTTPException(status_code=404, detail="Видео не найдено")

            cur.execute(
                """
                INSERT INTO video_comments (video_id, kind, author_name, author_email, text)
                VALUES (%s, %s, %s, %s, %s)
                RETURNING id, video_id, kind, author_name, text, likes, created_at
                """,
                (
                    video_id,
                    payload.kind,
                    payload.author_name.strip(),
                    payload.author_email,
                    payload.text.strip(),
                ),
            )
            row = cur.fetchone()

        conn.commit()

    return serialize_comment(row)


@router.post("/comments/{comment_id}/like", response_model=CommentLikeToggleResponse)
def toggle_comment_like(
    comment_id: int,
    x_user_email: str | None = Header(default=None, alias="X-User-Email"),
    x_client_session_id: str | None = Header(default=None, alias="X-Client-Session-Id"),
):
    identity_field, identity_value = resolve_like_identity(x_user_email, x_client_session_id)

    if not identity_field or not identity_value:
        raise HTTPException(status_code=400, detail="Не передана идентичность пользователя или сессии")

    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id FROM video_comments WHERE id = %s",
                (comment_id,),
            )
            comment_exists = cur.fetchone()

            if not comment_exists:
                raise HTTPException(status_code=404, detail="Комментарий не найден")

            if identity_field == "user_email":
                cur.execute(
                    """
                    SELECT id
                    FROM comment_likes
                    WHERE comment_id = %s AND user_email = %s
                    """,
                    (comment_id, identity_value),
                )
                existing_like = cur.fetchone()

                if existing_like:
                    cur.execute(
                        """
                        DELETE FROM comment_likes
                        WHERE comment_id = %s AND user_email = %s
                        """,
                        (comment_id, identity_value),
                    )
                    liked = False
                else:
                    cur.execute(
                        """
                        INSERT INTO comment_likes (comment_id, user_email)
                        VALUES (%s, %s)
                        """,
                        (comment_id, identity_value),
                    )
                    liked = True
            else:
                cur.execute(
                    """
                    SELECT id
                    FROM comment_likes
                    WHERE comment_id = %s AND client_session_id = %s
                    """,
                    (comment_id, identity_value),
                )
                existing_like = cur.fetchone()

                if existing_like:
                    cur.execute(
                        """
                        DELETE FROM comment_likes
                        WHERE comment_id = %s AND client_session_id = %s
                        """,
                        (comment_id, identity_value),
                    )
                    liked = False
                else:
                    cur.execute(
                        """
                        INSERT INTO comment_likes (comment_id, client_session_id)
                        VALUES (%s, %s)
                        """,
                        (comment_id, identity_value),
                    )
                    liked = True

            cur.execute(
                """
                SELECT COUNT(*) AS likes
                FROM comment_likes
                WHERE comment_id = %s
                """,
                (comment_id,),
            )
            likes_row = cur.fetchone()
            likes_count = int(likes_row["likes"])

            cur.execute(
                """
                UPDATE video_comments
                SET likes = %s
                WHERE id = %s
                """,
                (likes_count, comment_id),
            )

        conn.commit()

    return CommentLikeToggleResponse(
        comment_id=comment_id,
        liked=liked,
        likes=likes_count,
    )
