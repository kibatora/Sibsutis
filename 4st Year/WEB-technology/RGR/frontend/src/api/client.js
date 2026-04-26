import { API_BASE_URL } from '../config';

export async function readJsonResponse(response) {
  const contentType = response.headers.get('content-type') || '';
  const data = contentType.includes('application/json') ? await response.json() : null;

  if (!response.ok) {
    throw new Error(data?.detail || 'Ошибка запроса');
  }

  return data;
}

export function apiUrl(path) {
  return `${API_BASE_URL}${path}`;
}
