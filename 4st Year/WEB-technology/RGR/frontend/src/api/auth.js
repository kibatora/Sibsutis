import { apiUrl, readJsonResponse } from './client';

function normalizeUser(user) {
  return {
    id: user.id,
    email: user.email,
    firstName: user.first_name,
    lastName: user.last_name,
    createdAt: user.created_at,
  };
}

async function apiRequest(path, options = {}) {
  const response = await fetch(apiUrl(path), {
    headers: {
      'Content-Type': 'application/json',
      ...(options.headers || {}),
    },
    ...options,
  });

  return readJsonResponse(response);
}

export async function registerRequest(payload) {
  const data = await apiRequest('/register', {
    method: 'POST',
    body: JSON.stringify(payload),
  });

  return normalizeUser(data);
}

export async function requestAccessCode(payload) {
  return apiRequest('/access-code/request', {
    method: 'POST',
    body: JSON.stringify(payload),
  });
}