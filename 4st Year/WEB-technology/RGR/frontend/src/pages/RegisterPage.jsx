import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { registerRequest, requestAccessCode } from '../api/auth';
import { LogoMark, RequiredIcon } from '../components/Icons';

function FormField({
  label,
  placeholder,
  value,
  onChange,
  type = 'text',
  required = false,
  error = '',
  hint = '',
}) {
  const wrapperClass = [
    'form-field',
    'form-field--wide',
    value ? 'is-filled' : '',
    error ? 'is-error' : '',
    !error && hint ? 'with-message' : '',
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <div className={wrapperClass}>
      <label className="form-field__title">{label}</label>

      <div className="form-field__control">
        <input
          className="form-field__input"
          type={type}
          placeholder={placeholder}
          value={value}
          onChange={onChange}
          aria-invalid={Boolean(error)}
        />
        {required ? <RequiredIcon className="form-field__icon" /> : null}
      </div>

      {error ? (
        <div className="form-field__hint form-field__hint--error">{error}</div>
      ) : null}

      {!error && hint ? (
        <div className="form-field__hint form-field__hint--info">{hint}</div>
      ) : null}
    </div>
  );
}

export default function RegisterPage() {
  const [activeTab, setActiveTab] = useState('register');
  const [email, setEmail] = useState('');
  const [lastName, setLastName] = useState('');
  const [firstName, setFirstName] = useState('');
  const [recoveryEmail, setRecoveryEmail] = useState('');
  const [errorText, setErrorText] = useState('');
  const [successText, setSuccessText] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const [fieldErrors, setFieldErrors] = useState({
    email: '',
    lastName: '',
    firstName: '',
    recoveryEmail: '',
  });

  const { setUser } = useAuth();
  const navigate = useNavigate();

  const clearFieldError = (fieldName) => {
    setFieldErrors((prev) => ({
      ...prev,
      [fieldName]: '',
    }));
  };

  const isValidEmail = (value) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);

  const validateRegisterForm = () => {
    const nextErrors = {
      email: '',
      lastName: '',
      firstName: '',
      recoveryEmail: '',
    };

    if (!email.trim()) {
      nextErrors.email = 'Поле обязательно для заполнения';
    } else if (!isValidEmail(email.trim())) {
      nextErrors.email = 'Введите корректный email';
    }

    if (!lastName.trim()) {
      nextErrors.lastName = 'Поле обязательно для заполнения';
    }

    if (!firstName.trim()) {
      nextErrors.firstName = 'Поле обязательно для заполнения';
    }

    setFieldErrors(nextErrors);
    return !nextErrors.email && !nextErrors.lastName && !nextErrors.firstName;
  };

  const validateAccessCodeForm = () => {
    const nextErrors = {
      email: '',
      lastName: '',
      firstName: '',
      recoveryEmail: '',
    };

    if (!recoveryEmail.trim()) {
      nextErrors.recoveryEmail = 'Поле обязательно для заполнения';
    } else if (!isValidEmail(recoveryEmail.trim())) {
      nextErrors.recoveryEmail = 'Введите корректный email';
    }

    setFieldErrors(nextErrors);
    return !nextErrors.recoveryEmail;
  };

  const handleRegister = async () => {
    setErrorText('');
    setSuccessText('');

    if (!validateRegisterForm()) {
      return;
    }

    try {
      setIsSubmitting(true);

      const user = await registerRequest({
        email: email.trim(),
        first_name: firstName.trim(),
        last_name: lastName.trim(),
      });

      setUser(user);
      navigate('/');
    } catch (error) {
      const message = error.message || 'Ошибка регистрации';

      if (message.includes('уже существует')) {
        setFieldErrors((prev) => ({
          ...prev,
          email: 'Пользователь с таким email уже существует',
        }));
      } else {
        setErrorText(message);
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleAccessCode = async () => {
    setErrorText('');
    setSuccessText('');

    if (!validateAccessCodeForm()) {
      return;
    }

    try {
      setIsSubmitting(true);

      const result = await requestAccessCode({
        email: recoveryEmail.trim(),
      });

      setSuccessText(
        result.dev_code
          ? `Код доступа сформирован. Тестовый код: ${result.dev_code}`
          : 'Код доступа отправлен'
      );
    } catch (error) {
      const message = error.message || 'Ошибка запроса кода';

      if (message.includes('не найден')) {
        setFieldErrors((prev) => ({
          ...prev,
          recoveryEmail: 'Пользователь с таким email не найден',
        }));
      } else {
        setErrorText(message);
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="auth-page">
      <Link to="/" className="auth-page__logo" aria-label="Yadro">
        <LogoMark />
      </Link>

      <main className="auth-entry">
        <div className="forum-tabs forum-tabs--auth">
          <button
            className={`forum-tab forum-tab--auth ${activeTab === 'register' ? 'is-active' : ''}`.trim()}
            type="button"
            onClick={() => {
              setActiveTab('register');
              setErrorText('');
              setSuccessText('');
              setFieldErrors({
                email: '',
                lastName: '',
                firstName: '',
                recoveryEmail: '',
              });
            }}
          >
            <span className="forum-tab__text">Регистрация</span>
            <span className="forum-tab__underline" />
          </button>

          <button
            className={`forum-tab forum-tab--auth ${activeTab === 'access' ? 'is-active' : ''}`.trim()}
            type="button"
            onClick={() => {
              setActiveTab('access');
              setErrorText('');
              setSuccessText('');
              setFieldErrors({
                email: '',
                lastName: '',
                firstName: '',
                recoveryEmail: '',
              });
            }}
          >
            <span className="forum-tab__text">Код доступа</span>
            <span className="forum-tab__underline" />
          </button>
        </div>

        {activeTab === 'register' ? (
          <section className="auth-card auth-card--register">
            <div className="auth-form-fields">
              <div className="auth-groups">
                <section className="auth-group">
                  <h2 className="auth-group__title">Данные для авторизации</h2>
                  <FormField
                    label="Электронная почта"
                    placeholder="example-email@mail.ru"
                    type="email"
                    value={email}
                    onChange={(event) => {
                      setEmail(event.target.value);
                      clearFieldError('email');
                    }}
                    error={fieldErrors.email}
                    required
                  />
                </section>

                <section className="auth-group">
                  <h2 className="auth-group__title">Прочие данные</h2>

                  <div className="auth-stack">
                    <FormField
                      label="Фамилия"
                      placeholder="Ваша фамилия"
                      value={lastName}
                      onChange={(event) => {
                        setLastName(event.target.value);
                        clearFieldError('lastName');
                      }}
                      error={fieldErrors.lastName}
                      required
                    />
                    <FormField
                      label="Имя"
                      placeholder="Ваше имя"
                      value={firstName}
                      onChange={(event) => {
                        setFirstName(event.target.value);
                        clearFieldError('firstName');
                      }}
                      error={fieldErrors.firstName}
                      required
                    />
                  </div>
                </section>
              </div>

              {errorText ? <p className="auth-note">{errorText}</p> : null}
              {successText ? <p className="auth-note">{successText}</p> : null}

              <button
                className="btn-primary btn-primary--full auth-submit"
                type="button"
                onClick={handleRegister}
                disabled={isSubmitting}
              >
                {isSubmitting ? 'Отправка...' : 'Отправить'}
              </button>

              <p className="auth-note">* поле, обязательное для заполнения</p>
            </div>
          </section>
        ) : (
          <section className="auth-card auth-card--compact">
            <div className="auth-form-fields auth-form-fields--compact">
              <FormField
                label="Укажите электронную почту для восстановления кода"
                placeholder="my_email@mail.ru"
                type="email"
                value={recoveryEmail}
                onChange={(event) => {
                  setRecoveryEmail(event.target.value);
                  clearFieldError('recoveryEmail');
                }}
                error={fieldErrors.recoveryEmail}
              />

              {errorText ? <p className="auth-note">{errorText}</p> : null}
              {successText ? <p className="auth-note">{successText}</p> : null}

              <button
                className="btn-primary btn-primary--full auth-submit"
                type="button"
                onClick={handleAccessCode}
                disabled={isSubmitting}
              >
                {isSubmitting ? 'Отправка...' : 'Отправить код'}
              </button>
            </div>
          </section>
        )}
      </main>
    </div>
  );
}