-- SQL-скрипт для системы мониторинга трафика приложений (5 сущностей, 3NF)
SET client_min_messages TO WARNING;

-- Таблица 1: Абоненты (владельцы устройств)
CREATE TABLE IF NOT EXISTS subscribers (
    id SERIAL PRIMARY KEY,
    owner_name VARCHAR(50) UNIQUE NOT NULL
);

-- Таблица 2: Категории приложений (НОВАЯ СУЩНОСТЬ №5)
CREATE TABLE IF NOT EXISTS app_categories (
    id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL
);

-- Таблица 3: Приложения (справочник)
CREATE TABLE IF NOT EXISTS apps (
    id SERIAL PRIMARY KEY,
    app_name VARCHAR(50) UNIQUE NOT NULL,
    category_id INT NOT NULL REFERENCES app_categories(id)
);

-- Таблица 4: Устройства (телефоны)
CREATE TABLE IF NOT EXISTS devices (
    id SERIAL PRIMARY KEY,
    subscriber_id INT NOT NULL REFERENCES subscribers(id) ON DELETE CASCADE,
    model_name VARCHAR(50) NOT NULL,
    os_type VARCHAR(20) NOT NULL -- 'Android' или 'iOS'
);

-- Таблица 5: Журнал потребления трафика (главная таблица)
CREATE TABLE IF NOT EXISTS traffic_logs (
    id BIGSERIAL PRIMARY KEY,
    device_id INT NOT NULL REFERENCES devices(id),
    app_id INT NOT NULL REFERENCES apps(id),
    data_used_mb INT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_traffic_logs_device_id ON traffic_logs(device_id);
CREATE INDEX IF NOT EXISTS idx_traffic_logs_app_id ON traffic_logs(app_id);

-- Начальные данные
INSERT INTO subscribers (owner_name) VALUES ('Alice'), ('Bob'), ('Charlie');
INSERT INTO app_categories (category_name) VALUES ('Video'), ('Messenger'), ('Social'), ('Navigation');
INSERT INTO apps (app_name, category_id) VALUES
    ('YouTube', 1), ('Netflix', 1),
    ('Telegram', 2), ('WhatsApp', 2),
    ('TikTok', 3),
    ('Google Maps', 4);
INSERT INTO devices (subscriber_id, model_name, os_type) VALUES
    (1, 'iPhone 15', 'iOS'),
    (2, 'Samsung S25', 'Android'),
    (3, 'Pixel 9', 'Android'),
    (1, 'iPad Pro', 'iOS');