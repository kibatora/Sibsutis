import { API_BASE_URL } from '../config';
import { apiUrl, readJsonResponse } from './client';

function normalizeVideo(item) {
  return {
    id: item.id,
    title: item.title,
    description: item.description,
    originalFilename: item.original_filename,
    mimeType: item.mime_type,
    fileUrl: `${API_BASE_URL}${item.file_url}`,
    createdAt: item.created_at,
    updatedAt: item.updated_at,
  };
}

export async function getVideos() {
  const response = await fetch(apiUrl('/videos'));
  const data = await readJsonResponse(response);
  return data.map(normalizeVideo);
}

export async function getVideoById(videoId) {
  const response = await fetch(apiUrl(`/videos/${videoId}`));
  const data = await readJsonResponse(response);
  return normalizeVideo(data);
}

export async function uploadVideo({ title, description, file }) {
  const formData = new FormData();
  formData.append('title', title);
  formData.append('description', description || '');
  formData.append('file', file);

  const response = await fetch(apiUrl('/videos'), {
    method: 'POST',
    body: formData,
  });

  const data = await readJsonResponse(response);
  return normalizeVideo(data);
}

export async function updateVideo(videoId, payload) {
  const response = await fetch(apiUrl(`/videos/${videoId}`), {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  const data = await readJsonResponse(response);
  return normalizeVideo(data);
}

export async function deleteVideoRequest(videoId) {
  const response = await fetch(apiUrl(`/videos/${videoId}`), {
    method: 'DELETE',
  });

  return readJsonResponse(response);
}