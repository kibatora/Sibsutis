import { useEffect, useRef, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import AccountControls from '../components/AccountControls';
import { LogoMark } from '../components/Icons';
import { formatDate } from '../utils';
import { useAuth } from '../context/AuthContext';
import { deleteVideoRequest, getVideos, updateVideo, uploadVideo } from '../api/videos';

function VideoCard({ video, onEdit, onDelete }) {
  return (
    <article className="video-card">
      <div className="video-card__preview">
        <video
          src={video.fileUrl}
          className="video-card__preview-media"
          muted
          preload="metadata"
          style={{ width: '100%', height: '100%', objectFit: 'cover' }}
        />
      </div>

      <div className="video-card__body">
        <div className="video-card__content">
          <h2 className="video-card__title">{video.title}</h2>
          <p className="video-card__description">{video.description}</p>
          <p className="video-card__meta">
            ID: {video.id} · Обновлено: {formatDate(video.updatedAt)}
          </p>
        </div>

        <div className="video-card__actions">
          <Link className="video-card__action video-card__action--primary" to={`/video/${video.id}`}>
            Открыть
          </Link>

          <button
            className="video-card__action video-card__action--secondary"
            type="button"
            onClick={() => onEdit(video.id)}
          >
            Изменить
          </button>

          <button
            className="video-card__action video-card__action--danger"
            type="button"
            onClick={() => onDelete(video.id)}
          >
            Удалить видео
          </button>
        </div>
      </div>
    </article>
  );
}

export default function CatalogPage() {
  const [videos, setVideos] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isBusy, setIsBusy] = useState(false);
  const [errorText, setErrorText] = useState('');
  const fileInputRef = useRef(null);

  const { isAuthenticated } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    const loadVideos = async () => {
      try {
        setIsLoading(true);
        const items = await getVideos();
        setVideos(items);
      } catch (error) {
        setErrorText(error.message || 'Не удалось загрузить каталог');
      } finally {
        setIsLoading(false);
      }
    };

    void loadVideos();
  }, []);

  const handleAddClick = () => {
    if (!isAuthenticated) {
      navigate('/register');
      return;
    }

    fileInputRef.current?.click();
  };

  const handleFileChange = async (event) => {
    const file = event.target.files?.[0];
    event.target.value = '';

    if (!file) return;

    const titleValue = window.prompt('Название нового видео', file.name.replace(/\.[^/.]+$/, ''));
    if (titleValue === null) return;

    const descriptionValue = window.prompt('Короткое описание', 'Видео загружено через React-панель.');
    if (descriptionValue === null) return;

    try {
      setIsBusy(true);
      setErrorText('');

      const createdVideo = await uploadVideo({
        title: titleValue.trim() || file.name,
        description: descriptionValue.trim(),
        file,
      });

      setVideos((current) => [createdVideo, ...current]);
    } catch (error) {
      setErrorText(error.message || 'Не удалось загрузить видео');
    } finally {
      setIsBusy(false);
    }
  };

  const handleEditVideo = async (id) => {
    const targetVideo = videos.find((item) => item.id === id);
    if (!targetVideo) return;

    const titleValue = window.prompt('Изменить название', targetVideo.title);
    if (titleValue === null) return;

    const descriptionValue = window.prompt('Изменить описание', targetVideo.description);
    if (descriptionValue === null) return;

    try {
      setIsBusy(true);
      setErrorText('');

      const updatedVideo = await updateVideo(id, {
        title: titleValue.trim() || targetVideo.title,
        description: descriptionValue.trim(),
      });

      setVideos((current) =>
        current.map((item) => (item.id === id ? updatedVideo : item)),
      );
    } catch (error) {
      setErrorText(error.message || 'Не удалось обновить видео');
    } finally {
      setIsBusy(false);
    }
  };

  const handleDeleteVideo = async (id) => {
    const targetVideo = videos.find((item) => item.id === id);
    if (!targetVideo) return;

    const isConfirmed = window.confirm(`Удалить видео «${targetVideo.title}»?`);
    if (!isConfirmed) return;

    try {
      setIsBusy(true);
      setErrorText('');

      await deleteVideoRequest(id);
      setVideos((current) => current.filter((item) => item.id !== id));
    } catch (error) {
      setErrorText(error.message || 'Не удалось удалить видео');
    } finally {
      setIsBusy(false);
    }
  };

  return (
    <div className="catalog-page">
      <header className="catalog-page__header">
        <Link to="/" className="catalog-page__logo" aria-label="Yadro">
          <LogoMark />
        </Link>
        <AccountControls />
      </header>

      <main className="catalog-page__main">
        <div className="catalog-shell">
          <section className="catalog-hero">
            <div className="catalog-hero__content">
              <h1 className="catalog-hero__title">Видеоплатформа</h1>
              <p className="catalog-hero__text">
                Возможности загрузки и удаления видеофайлов для просмотра. И небольшое редактирование.
              </p>
              {!isAuthenticated ? (
                <p className="catalog-hero__hint">
                  Перед добавлением тебе нужен аккаунт — перейдите на{' '}
                  <Link to="/register">страницу регистрации</Link>.
                </p>
              ) : null}
              {errorText ? <p className="auth-note">{errorText}</p> : null}
            </div>

            <div className="catalog-hero__stats">
              <span className="catalog-hero__stats-value">{videos.length}</span>
              <span className="catalog-hero__stats-label">видео</span>
            </div>
          </section>

          <input
            ref={fileInputRef}
            type="file"
            accept="video/*"
            hidden
            onChange={handleFileChange}
          />

          {isLoading ? (
            <div className="empty-state-card">
              <h2>Загрузка каталога...</h2>
            </div>
          ) : (
            <section className="video-grid">
              {!isAuthenticated && videos.length === 0 ? (
                <div className="catalog-guest-banner" role="status">
                  <p className="catalog-guest-banner__title">Каталог пуст</p>
                  <p className="catalog-guest-banner__text">
                    После регистрации вы сможете загружать видео. Просмотр чужих роликов доступен без входа.
                  </p>
                  <Link className="btn-primary catalog-guest-banner__btn" to="/register">
                    Зарегистрироваться
                  </Link>
                </div>
              ) : null}

              {videos.map((video) => (
                <VideoCard
                  key={video.id}
                  video={video}
                  onEdit={handleEditVideo}
                  onDelete={handleDeleteVideo}
                />
              ))}

              <article className="video-card video-card--add">
                <button
                  className="video-card__add-button"
                  type="button"
                  onClick={handleAddClick}
                  disabled={isBusy}
                >
                  <span className="video-card__add-icon">+</span>
                  <span className="video-card__add-title">
                    {isBusy ? 'Загрузка...' : 'Добавить'}
                  </span>
                  <span className="video-card__add-text">
                    {isAuthenticated
                      ? 'Выбрать и загрузить видеофайл'
                      : 'Сначала войдите через регистрацию'}
                  </span>
                </button>
              </article>
            </section>
          )}
        </div>
      </main>
    </div>
  );
}