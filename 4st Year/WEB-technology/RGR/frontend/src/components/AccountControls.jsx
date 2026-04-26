import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { LogoutIcon, UserIcon } from './Icons';

export default function AccountControls() {
  const { isAuthenticated, logout, user } = useAuth();
  const navigate = useNavigate();

  if (!isAuthenticated) {
    return (
      <div className="view-page__account view-page__account--guest">
        <Link to="/register" className="view-page__register-link">
          Регистрация
        </Link>

        <Link to="/register" className="view-page__icon-btn" aria-label="Регистрация">
          <UserIcon className="view-page__icon-image" />
        </Link>
      </div>
    );
  }

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  return (
    <div className="view-page__account view-page__account--auth">
      <span className="view-page__username">{user?.firstName || 'Пользователь'}</span>

      <div className="view-page__account-icons">
        <span className="view-page__icon-btn" aria-hidden="true">
          <UserIcon className="view-page__icon-image" />
        </span>

        <button type="button" className="view-page__icon-btn view-page__icon-btn--button" onClick={handleLogout} aria-label="Выход">
          <LogoutIcon className="view-page__icon-image" />
        </button>
      </div>
    </div>
  );
}
