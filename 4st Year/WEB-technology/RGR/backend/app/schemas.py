from datetime import datetime
from typing import Literal

from pydantic import BaseModel, EmailStr, Field


class RegisterRequest(BaseModel):
    email: EmailStr
    first_name: str = Field(min_length=1, max_length=100)
    last_name: str = Field(min_length=1, max_length=100)


class AccessCodeRequest(BaseModel):
    email: EmailStr


class UserResponse(BaseModel):
    id: int
    email: EmailStr
    first_name: str
    last_name: str
    created_at: datetime


class AccessCodeResponse(BaseModel):
    ok: bool
    message: str
    dev_code: str | None = None


class VideoResponse(BaseModel):
    id: int
    title: str
    description: str
    original_filename: str
    mime_type: str | None = None
    file_url: str
    created_at: datetime
    updated_at: datetime


class VideoUpdateRequest(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    description: str = Field(default="", max_length=5000)


class VideoCommentResponse(BaseModel):
    id: int
    video_id: int
    kind: Literal["chat", "qa"]
    name: str
    text: str
    likes: int
    liked: bool
    created_at: datetime


class VideoCommentCreateRequest(BaseModel):
    kind: Literal["chat", "qa"] = "chat"
    author_name: str = Field(min_length=1, max_length=100)
    author_email: EmailStr | None = None
    text: str = Field(min_length=1, max_length=2000)


class CommentLikeToggleResponse(BaseModel):
    comment_id: int
    liked: bool
    likes: int
