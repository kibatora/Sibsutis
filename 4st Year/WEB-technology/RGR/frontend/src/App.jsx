import { Navigate, Route, Routes } from 'react-router-dom';
import CatalogPage from './pages/CatalogPage';
import ViewPage from './pages/ViewPage';
import RegisterPage from './pages/RegisterPage';

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<CatalogPage />} />
      <Route path="/register" element={<RegisterPage />} />
      <Route path="/video/:videoId" element={<ViewPage />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
