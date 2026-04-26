import { apiUrl, readJsonResponse } from './client';

const CLIENT_SESSION_KEY = 'video-platform-client-session-id';

function getClientSessionId() {
  let sessionId = localStorage.getItem(CLIENT_SESSION_KEY);

  if (!sessionId) {
    sessionId = crypto.randomUUID();
    localStorage.setItem(CLIENT_SESSION_KEY, sessionId);
  }

  return sessionId;
}

function buildIdentityHeaders(userEmail) {
  const headers = {
    'X-Client-Session-Id': getClientSessionId(),
  };

  if (userEmail) {
    headers['X-User-Email'] = userEmail;
  }

  return headers;
}

function normalizeComment(item) {
  return {
    id: item.id,
    videoId: item.video_id,
    kind: item.kind,
    name: item.name,
    text: item.text,
    likes: item.likes,
    liked: item.liked,
    createdAt: item.created_at,
  };
}

export async function getVideoComments(videoId, userEmail) {
  const response = await fetch(apiUrl(`/videos/${videoId}/comments`), {
    headers: buildIdentityHeaders(userEmail),
  });

  const data = await readJsonResponse(response);
  return data.map(normalizeComment);
}

export async function createVideoComment(videoId, payload) {
  const response = await fetch(apiUrl(`/videos/${videoId}/comments`), {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  const data = await readJsonResponse(response);
  return normalizeComment(data);
}

export async function toggleCommentLike(commentId, userEmail) {
  const response = await fetch(apiUrl(`/comments/${commentId}/like`), {
    method: 'POST',
    headers: buildIdentityHeaders(userEmail),
  });

  return readJsonResponse(response);
}