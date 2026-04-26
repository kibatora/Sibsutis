import { useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import AccountControls from '../components/AccountControls';
import ChatPanel from '../components/ChatPanel';
import { LogoMark } from '../components/Icons';
import { getVideoById } from '../api/videos';

export default function ViewPage() {
  const { videoId } = useParams();
  const navigate = useNavigate();

  const [video, setVideo] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [errorText, setErrorText] = useState('');

  useEffect(() => {
    const loadVideo = async () => {
      try {
        setIsLoading(true);
        setErrorText('');

        const item = await getVideoById(videoId);
        setVideo(item);
      } catch (error) {
        setErrorText(error.message || 'Видео не найдено');
      } finally {
        setIsLoading(false);
      }
    };

    void loadVideo();
  }, [videoId]);

  if (isLoading) {
    return (
      <div className="view-page">
        <header className="view-page__header">
          <Link to="/" className="view-page__logo" aria-label="Yadro">
            <LogoMark />
          </Link>
        </header>

        <main className="view-page__main view-page__main--centered">
          <div className="empty-state-card">
            <h1>Загрузка видео...</h1>
          </div>
        </main>
      </div>
    );
  }

  if (!video) {
    return (
      <div className="view-page">
        <header className="view-page__header">
          <Link to="/" className="view-page__logo" aria-label="Yadro">
            <LogoMark />
          </Link>
        </header>

        <main className="view-page__main view-page__main--centered">
          <div className="empty-state-card">
            <h1>Видео не найдено</h1>
            <p>{errorText || 'Похоже, карточка была удалена или ссылка устарела.'}</p>
            <button type="button" className="btn-primary" onClick={() => navigate('/')}>
              Вернуться в каталог
            </button>
          </div>
        </main>
      </div>
    );
  }

  return (
    <div className="view-page">
      <header className="view-page__header">
        <Link to="/" className="view-page__logo" aria-label="Yadro">
          <LogoMark />
        </Link>

        <AccountControls />
      </header>

      <main className="view-page__main">
        <section className="view-layout">
          <div className="media-panel">
            <div id="media" style={{ width: '100%', height: '100%' }}>
              <video
                controls
                src={video.fileUrl}
                style={{ width: '100%', height: '100%', background: '#000' }}
              >
                Ваш браузер не поддерживает тег video.
              </video>
            </div>
          </div>

          <ChatPanel videoId={video.id} />
        </section>
      </main>
    </div>
  );
}