# Видеоплатформа (учебный проект)

Проект представляет собой тестовую видеоплатформу, разработанную в рамках РГР по дисциплине «WEB-технологии».

## Возможности

- регистрация пользователя
- просмотр каталога видео
- загрузка видеофайлов
- просмотр видео
- комментарии (чат под видео)

## Используемые технологии

- backend: Python (FastAPI)
- frontend: React (Vite)
- база данных: PostgreSQL
- контейнеризация: Docker

## Структура проекта
```bash
backend/
  app/
    main.py
    requirements.txt
  docker/
    docker-compose.yaml
  uploads/
```
```bash
frontend/
  src/
  public/
  package.json
  vite.config.js
```
## Запуск backend
```bash
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r app/requirements.txt
uvicorn app.main:app --reload
```
Backend будет доступен по адресу:
http://127.0.0.1:8000

Проверка работаспособности:
http://127.0.0.1:8000/health-check

## Запуск frontend
```bash
cd frontend
npm install
npm run dev
```
Frontend будет доступен по адресу:
http://localhost:5173

## Запуск базы данных
```bash
cd backend/docker
docker compose up -d
```
## Примечание

Проект разработан в учебных целях и демонстрирует взаимодействие frontend и backend частей веб-приложения.

Создан в качестве РГР по предмету - WEB-технологии, студентом ИА-232 Зырянов Иван
