function AssetImage({ name, alt = '', className = '' }) {
  return <img className={className} src={`/images/${name}`} alt={alt} />;
}

export function LogoMark({ className = '', alt = 'Yadro' }) {
  return <AssetImage name="yadro_logo.svg" alt={alt} className={className || 'logo-mark'} />;
}

export function UserIcon({ className = '', alt = 'Профиль' }) {
  return <AssetImage name="profile.svg" alt={alt} className={className} />;
}

export function LogoutIcon({ className = '', alt = 'Выход' }) {
  return <AssetImage name="profile_exit.svg" alt={alt} className={className} />;
}

export function LikeIcon({ className = '', alt = '' }) {
  return <AssetImage name="like_btn.svg" alt={alt} className={className} />;
}

export function SmileIcon({ className = '', alt = '' }) {
  return <AssetImage name="smile_btn.svg" alt={alt} className={className} />;
}

export function RequiredIcon({ className = '', alt = '' }) {
  return <AssetImage name="required.svg" alt={alt} className={className} />;
}
