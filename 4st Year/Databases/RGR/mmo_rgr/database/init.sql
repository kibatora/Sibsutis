-- Полный SQL-скрипт для инициализации базы данных MMO 

SET client_min_messages TO WARNING;

-- === СОЗДАНИЕ ТАБЛИЦ ===
CREATE TABLE IF NOT EXISTS players ( id SERIAL PRIMARY KEY, nickname VARCHAR(50) UNIQUE NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW() );
CREATE TABLE IF NOT EXISTS characters ( id SERIAL PRIMARY KEY, player_id INT NOT NULL REFERENCES players(id) ON DELETE CASCADE, class_name VARCHAR(50) NOT NULL, level INT NOT NULL DEFAULT 1, character_name VARCHAR(50) NOT NULL, UNIQUE(player_id, character_name) );
CREATE TABLE IF NOT EXISTS locations ( id SERIAL PRIMARY KEY, name VARCHAR(100) UNIQUE NOT NULL, req_level INT NOT NULL DEFAULT 1 );
CREATE TABLE IF NOT EXISTS mobs ( id SERIAL PRIMARY KEY, location_id INT NOT NULL REFERENCES locations(id) ON DELETE CASCADE, name VARCHAR(100) NOT NULL, hp INT NOT NULL );
CREATE TABLE IF NOT EXISTS combat_logs ( id BIGSERIAL PRIMARY KEY, character_id INT NOT NULL REFERENCES characters(id), mob_id INT NOT NULL REFERENCES mobs(id), event_type VARCHAR(50) NOT NULL, damage INT DEFAULT 0, loot_gold INT DEFAULT 0, timestamp TIMESTAMPTZ DEFAULT NOW() );

-- === ИНДЕКСЫ ===
CREATE INDEX IF NOT EXISTS idx_combat_logs_character_id ON combat_logs(character_id);
CREATE INDEX IF NOT EXISTS idx_combat_logs_timestamp ON combat_logs(timestamp);

-- === НАЧАЛЬНЫЕ ДАННЫЕ (SEED DATA) ===
INSERT INTO locations (name, req_level) VALUES ('Haunted Forest', 1), ('Dragon''s Cave', 10);
INSERT INTO mobs (location_id, name, hp) VALUES (1, 'Giant Spider', 50), (1, 'Goblin Archer', 30), (2, 'Young Dragon', 200), (2, 'Lava Golem', 150);

-- === Cписок игроков и персонажей ===

-- Добавляем 5 уникальных аккаунтов игроков
INSERT INTO players (nickname) VALUES ('WarriorKing'), ('ShadowMage'), ('SwiftArrow'), ('TheAlchemist'), ('RogueShadow');

-- Добавляем 5 персонажей
-- Их ID будут 1, 2, 3, 4, 5, как и ожидает симулятор.
INSERT INTO characters (player_id, class_name, character_name, level) VALUES
    (1, 'Warrior', 'Arthas', 10),      -- ID 1, принадлежит игроку 'WarriorKing'
    (2, 'Mage', 'Jaina', 8),           -- ID 2, принадлежит игроку 'ShadowMage'
    (3, 'Archer', 'Sylvanas', 9),      -- ID 3, принадлежит игроку 'SwiftArrow' 
    (4, 'Mage', 'Kaelthas', 11),       -- ID 4, принадлежит игроку 'TheAlchemist'
    (5, 'Warrior', 'Grommash', 12);   -- ID 5, принадлежит игроку 'RogueShadow'