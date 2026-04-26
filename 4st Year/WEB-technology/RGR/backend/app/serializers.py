from app.schemas import VideoCommentResponse, VideoResponse


def serialize_video(row: dict) -> VideoResponse:
    return VideoResponse(
        id=row["id"],
        title=row["title"],
        description=row["description"],
        original_filename=row["original_filename"],
        mime_type=row["mime_type"],
        file_url=f"/uploads/{row['stored_filename']}",
        created_at=row["created_at"],
        updated_at=row["updated_at"],
    )


def serialize_comment(row: dict) -> VideoCommentResponse:
    return VideoCommentResponse(
        id=row["id"],
        video_id=row["video_id"],
        kind=row["kind"],
        name=row["author_name"],
        text=row["text"],
        likes=row["likes"],
        liked=bool(row.get("liked", False)),
        created_at=row["created_at"],
    )


def resolve_like_identity(
    x_user_email: str | None,
    x_client_session_id: str | None,
) -> tuple[str, str] | tuple[None, None]:
    if x_user_email and x_user_email.strip():
        return "user_email", x_user_email.strip().lower()

    if x_client_session_id and x_client_session_id.strip():
        return "client_session_id", x_client_session_id.strip()

    return None, None
