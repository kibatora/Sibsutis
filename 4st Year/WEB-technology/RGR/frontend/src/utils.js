import { defaultVideos, VIDEO_STORAGE_KEY } from './data';

export function formatDate(value) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return 'сейчас';
  }

  return new Intl.DateTimeFormat('ru-RU', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).format(date);
}

export function formatLikes(value) {
  const likes = Number(value) || 0;
  return likes > 99 ? '99+' : String(Math.max(0, likes));
}

export function getInitialVideos() {
  try {
    const rawValue = localStorage.getItem(VIDEO_STORAGE_KEY);
    if (!rawValue) {
      return [...defaultVideos];
    }

    const parsedValue = JSON.parse(rawValue);
    if (!Array.isArray(parsedValue) || parsedValue.length === 0) {
      return [...defaultVideos];
    }

    return parsedValue;
  } catch {
    return [...defaultVideos];
  }
}

export function persistVideos(videos) {
  localStorage.setItem(VIDEO_STORAGE_KEY, JSON.stringify(videos));
}

export function getNextVideoId(videos) {
  return videos.reduce((maxId, item) => Math.max(maxId, Number(item.id) || 0), 0) + 1;
}
