import { useEffect, useLayoutEffect, useMemo, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { formatLikes } from '../utils';
import { createVideoComment, getVideoComments, toggleCommentLike } from '../api/comments';
import { LikeIcon, SmileIcon } from './Icons';

const CHAT_NAME_STORAGE_KEY = 'video-platform-chat-name';

function MessageCard({ item, onToggleLike, isLiking }) {
  const likesText = formatLikes(item.likes);
  const likesLabel = Number(item.likes) > 99 ? `Лайки: ${item.likes}` : `Лайки: ${likesText}`;

  return (
    <article className="message-card message-card--chat">
      <div className="message-card__body">
        <div className="message-card__name">{item.name}</div>
        <p className="message-card__text">{item.text}</p>
      </div>

      <button
        className={`likes-control${item.liked ? ' is-liked' : ''}`}
        type="button"
        aria-label={likesLabel}
        onClick={() => onToggleLike(item.id)}
        disabled={isLiking}
      >
        <LikeIcon className="likes-control__icon" alt="" />
        <span className="likes-control__count">{likesText}</span>
      </button>
    </article>
  );
}

export default function ChatPanel({ videoId }) {
  const { isAuthenticated, user } = useAuth();

  const [activeTab, setActiveTab] = useState('chat');
  const [draft, setDraft] = useState('');
  const [chatMessages, setChatMessages] = useState([]);
  const [qaMessages, setQaMessages] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSending, setIsSending] = useState(false);
  const [errorText, setErrorText] = useState('');
  const [likingIds, setLikingIds] = useState([]);
  const [chatName, setChatName] = useState('');

  const messagesRef = useRef(null);
  const scrollbarRef = useRef(null);
  const trackRef = useRef(null);
  const thumbRef = useRef(null);
  const dragStateRef = useRef({
    isDragging: false,
    dragStartY: 0,
    dragStartScrollTop: 0,
  });

  useEffect(() => {
    try {
      const storedChatName = localStorage.getItem(CHAT_NAME_STORAGE_KEY);

      if (storedChatName && storedChatName.trim()) {
        setChatName(storedChatName.trim());
        return;
      }
    } catch {
      // ignore localStorage errors
    }

    setChatName(user?.firstName || '');
  }, [user?.firstName]);

  const displayChatName = chatName.trim() || user?.firstName || 'Нина';

  useEffect(() => {
    const loadComments = async () => {
      if (!videoId) {
        setChatMessages([]);
        setQaMessages([]);
        setIsLoading(false);
        return;
      }

      try {
        setIsLoading(true);
        setErrorText('');

        const items = await getVideoComments(videoId, user?.email);

        setChatMessages(items.filter((item) => item.kind === 'chat'));
        setQaMessages(items.filter((item) => item.kind === 'qa'));
      } catch (error) {
        setErrorText(error.message || 'Не удалось загрузить комментарии');
      } finally {
        setIsLoading(false);
      }
    };

    void loadComments();
  }, [videoId, user?.email]);

  const data = useMemo(
    () => ({
      chat: chatMessages,
      qa: qaMessages,
    }),
    [chatMessages, qaMessages],
  );

  const currentMessages = data[activeTab] || [];

  const getMetrics = () => {
    const messagesBox = messagesRef.current;
    const track = trackRef.current;

    if (!messagesBox || !track) {
      return null;
    }

    const contentHeight = messagesBox.scrollHeight;
    const viewportHeight = messagesBox.clientHeight;
    const trackHeight = track.clientHeight;
    const maxScrollTop = Math.max(contentHeight - viewportHeight, 0);

    return {
      contentHeight,
      viewportHeight,
      trackHeight,
      maxScrollTop,
    };
  };

  const updateScrollbar = () => {
    const metrics = getMetrics();
    const scrollbar = scrollbarRef.current;
    const thumb = thumbRef.current;
    const messagesBox = messagesRef.current;

    if (!metrics || !scrollbar || !thumb || !messagesBox) {
      return;
    }

    const { contentHeight, viewportHeight, trackHeight, maxScrollTop } = metrics;

    if (!trackHeight || !viewportHeight || contentHeight <= viewportHeight) {
      scrollbar.classList.add('is-hidden');
      thumb.style.height = '';
      thumb.style.top = '0px';
      return;
    }

    scrollbar.classList.remove('is-hidden');

    const visibleRatio = viewportHeight / contentHeight;
    const nextThumbHeight = Math.max(48, Math.round(trackHeight * visibleRatio));
    const maxThumbTop = Math.max(trackHeight - nextThumbHeight, 0);
    const scrollRatio = maxScrollTop > 0 ? messagesBox.scrollTop / maxScrollTop : 0;
    const nextThumbTop = Math.round(maxThumbTop * scrollRatio);

    thumb.style.height = `${nextThumbHeight}px`;
    thumb.style.top = `${nextThumbTop}px`;
  };

  useLayoutEffect(() => {
    const frameId = window.requestAnimationFrame(() => {
      const messagesBox = messagesRef.current;
      if (messagesBox) {
        messagesBox.scrollTop = 0;
      }
      updateScrollbar();
    });

    return () => window.cancelAnimationFrame(frameId);
  }, [activeTab, currentMessages.length, isAuthenticated]);

  useEffect(() => {
    const messagesBox = messagesRef.current;
    const track = trackRef.current;
    const thumb = thumbRef.current;

    if (!messagesBox || !track || !thumb) {
      return undefined;
    }

    let resizeFrameId = 0;

    const scheduleUpdate = () => {
      if (resizeFrameId) {
        window.cancelAnimationFrame(resizeFrameId);
      }
      resizeFrameId = window.requestAnimationFrame(updateScrollbar);
    };

    const handleThumbPointerDown = (event) => {
      const metrics = getMetrics();
      if (!metrics) {
        return;
      }

      const { contentHeight, viewportHeight, trackHeight } = metrics;
      if (contentHeight <= viewportHeight || !trackHeight) {
        return;
      }

      dragStateRef.current = {
        isDragging: true,
        dragStartY: event.clientY,
        dragStartScrollTop: messagesBox.scrollTop,
      };

      thumb.classList.add('is-dragging');
      thumb.setPointerCapture(event.pointerId);
      event.preventDefault();
    };

    const handleThumbPointerMove = (event) => {
      const dragState = dragStateRef.current;
      if (!dragState.isDragging) {
        return;
      }

      const metrics = getMetrics();
      if (!metrics) {
        return;
      }

      const { contentHeight, viewportHeight, trackHeight, maxScrollTop } = metrics;
      if (contentHeight <= viewportHeight || !trackHeight) {
        return;
      }

      const currentThumbHeight = thumb.offsetHeight;
      const maxThumbTravel = Math.max(trackHeight - currentThumbHeight, 1);
      const deltaY = event.clientY - dragState.dragStartY;
      const scrollDelta = deltaY * (maxScrollTop / maxThumbTravel);

      messagesBox.scrollTop = dragState.dragStartScrollTop + scrollDelta;
    };

    const stopDragging = (event) => {
      const dragState = dragStateRef.current;
      if (!dragState.isDragging) {
        return;
      }

      dragState.isDragging = false;
      thumb.classList.remove('is-dragging');

      if (
        event &&
        thumb.hasPointerCapture &&
        typeof event.pointerId === 'number' &&
        thumb.hasPointerCapture(event.pointerId)
      ) {
        thumb.releasePointerCapture(event.pointerId);
      }
    };

    const handleTrackClick = (event) => {
      if (event.target === thumb) {
        return;
      }

      const metrics = getMetrics();
      if (!metrics) {
        return;
      }

      const { contentHeight, viewportHeight, trackHeight, maxScrollTop } = metrics;
      if (contentHeight <= viewportHeight || !trackHeight) {
        return;
      }

      const rect = track.getBoundingClientRect();
      const clickY = event.clientY - rect.top;
      const currentThumbHeight = thumb.offsetHeight;
      const maxThumbTop = Math.max(trackHeight - currentThumbHeight, 0);
      const nextThumbTop = Math.min(Math.max(clickY - currentThumbHeight / 2, 0), maxThumbTop);
      const scrollRatio = maxThumbTop > 0 ? nextThumbTop / maxThumbTop : 0;

      messagesBox.scrollTop = scrollRatio * maxScrollTop;
    };

    const resizeObserver =
      typeof ResizeObserver === 'function'
        ? new ResizeObserver(() => {
            scheduleUpdate();
          })
        : null;

    messagesBox.addEventListener('scroll', updateScrollbar);
    thumb.addEventListener('pointerdown', handleThumbPointerDown);
    thumb.addEventListener('pointermove', handleThumbPointerMove);
    thumb.addEventListener('pointerup', stopDragging);
    thumb.addEventListener('pointercancel', stopDragging);
    track.addEventListener('click', handleTrackClick);
    window.addEventListener('resize', scheduleUpdate);

    if (resizeObserver) {
      resizeObserver.observe(messagesBox);
      resizeObserver.observe(track);
    }

    scheduleUpdate();

    return () => {
      messagesBox.removeEventListener('scroll', updateScrollbar);
      thumb.removeEventListener('pointerdown', handleThumbPointerDown);
      thumb.removeEventListener('pointermove', handleThumbPointerMove);
      thumb.removeEventListener('pointerup', stopDragging);
      thumb.removeEventListener('pointercancel', stopDragging);
      track.removeEventListener('click', handleTrackClick);
      window.removeEventListener('resize', scheduleUpdate);

      if (resizeObserver) {
        resizeObserver.disconnect();
      }

      if (resizeFrameId) {
        window.cancelAnimationFrame(resizeFrameId);
      }
    };
  }, [activeTab, currentMessages.length, isAuthenticated]);

  const handleToggleLike = async (commentId) => {
    if (likingIds.includes(commentId)) {
      return;
    }

    try {
      setLikingIds((current) => [...current, commentId]);
      setErrorText('');

      const result = await toggleCommentLike(commentId, user?.email);

      const patchItems = (items) =>
        items.map((item) =>
          item.id === result.comment_id
            ? {
                ...item,
                liked: result.liked,
                likes: result.likes,
              }
            : item,
        );

      setChatMessages((current) => patchItems(current));
      setQaMessages((current) => patchItems(current));
    } catch (error) {
      setErrorText(error.message || 'Не удалось поставить лайк');
    } finally {
      setLikingIds((current) => current.filter((id) => id !== commentId));
    }
  };

  const handleEditChatName = () => {
    const nextValue = window.prompt('Введите имя в чате', displayChatName);

    if (nextValue === null) {
      return;
    }

    const normalizedValue = nextValue.trim().slice(0, 100);

    try {
      if (!normalizedValue) {
        localStorage.removeItem(CHAT_NAME_STORAGE_KEY);
        setChatName(user?.firstName || '');
        return;
      }

      localStorage.setItem(CHAT_NAME_STORAGE_KEY, normalizedValue);
      setChatName(normalizedValue);
    } catch {
      setChatName(normalizedValue || user?.firstName || '');
    }
  };

  const handleSubmit = async (event) => {
    event.preventDefault();

    const trimmedValue = draft.trim();
    if (!trimmedValue || !videoId) {
      return;
    }

    try {
      setIsSending(true);
      setErrorText('');

      const createdComment = await createVideoComment(videoId, {
        kind: activeTab,
        author_name: displayChatName,
        author_email: user?.email || null,
        text: trimmedValue,
      });

      if (activeTab === 'chat') {
        setChatMessages((current) => [...current, createdComment]);
      } else {
        setQaMessages((current) => [...current, createdComment]);
      }

      setDraft('');

      window.requestAnimationFrame(() => {
        const messagesBox = messagesRef.current;
        if (messagesBox) {
          messagesBox.scrollTop = messagesBox.scrollHeight;
        }
        updateScrollbar();
      });
    } catch (error) {
      setErrorText(error.message || 'Не удалось отправить сообщение');
    } finally {
      setIsSending(false);
    }
  };

  const topMarkup = (
    <div className="chat-panel__top">
      <div className="forum-tabs view-chat-tabs">
        <button
          className={`forum-tab ${activeTab === 'chat' ? 'is-active' : ''}`.trim()}
          type="button"
          onClick={() => setActiveTab('chat')}
        >
          <span className="forum-tab__text">Чат</span>
          <span className="forum-tab__underline" />
        </button>

        <button
          className={`forum-tab ${activeTab === 'qa' ? 'is-active' : ''}`.trim()}
          type="button"
          onClick={() => setActiveTab('qa')}
        >
          <span className="forum-tab__text">Вопрос / ответ</span>
          <span className="forum-tab__underline" />
        </button>
      </div>

      <div className="chat-panel__messages-wrap">
        <div ref={messagesRef} className="chat-panel__messages" data-messages>
          {isLoading ? (
            <p className="auth-note">Загрузка комментариев...</p>
          ) : currentMessages.length ? (
            currentMessages.map((item) => (
              <MessageCard
                key={`${activeTab}-${item.id}`}
                item={item}
                onToggleLike={handleToggleLike}
                isLiking={likingIds.includes(item.id)}
              />
            ))
          ) : (
            <p className="auth-note">
              {activeTab === 'chat'
                ? 'Пока нет сообщений в чате'
                : 'Пока нет вопросов и ответов'}
            </p>
          )}
        </div>

        <div ref={scrollbarRef} className="chat-panel__scrollbar" data-scrollbar>
          <div ref={trackRef} className="scrollbar-track chat-scrollbar-track" data-scroll-track>
            <span ref={thumbRef} className="scrollbar-thumb chat-scrollbar-thumb" data-scroll-thumb />
          </div>
        </div>
      </div>

      {errorText ? <p className="auth-note">{errorText}</p> : null}
    </div>
  );

  if (!isAuthenticated) {
    return (
      <aside className="chat-panel">
        <div className="chat-panel__inner">
          {topMarkup}

          <Link to="/register" className="btn-primary chat-panel__cta">
            <span className="chat-panel__cta-text">
              <span className="chat-panel__cta-line">Хотите отправить сообщение?</span>
              <br />
              <span className="chat-panel__cta-line">Кликните на эту кнопку</span>
            </span>
          </Link>
        </div>
      </aside>
    );
  }

  return (
    <aside className="chat-panel">
      <div className="chat-panel__inner">
        {topMarkup}

        <form className="chat-composer" action="#" method="post" onSubmit={handleSubmit}>
          <div className="chat-composer__box">
            <div className="chat-composer__field">
              <input
                className="chat-composer__input"
                type="text"
                name="message"
                placeholder={activeTab === 'chat' ? 'Текст сообщения' : 'Введите вопрос или ответ'}
                autoComplete="off"
                value={draft}
                onChange={(event) => setDraft(event.target.value)}
              />
              <SmileIcon className="chat-composer__icon" alt="" />
            </div>

            <button
              className="btn-primary btn-primary--small chat-composer__send"
              type="submit"
              disabled={isSending}
            >
              {isSending ? 'Отправка...' : 'Отправить'}
            </button>
          </div>

          <div className="chat-composer__meta">
            <div className="chat-composer__name">
              <span>Имя в чате:</span>
              <strong>{displayChatName}</strong>
            </div>

            <button className="edit-link" type="button" onClick={handleEditChatName}>
              Ред.
            </button>
          </div>
        </form>
      </div>
    </aside>
  );
}