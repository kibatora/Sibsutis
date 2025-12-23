import os
import psycopg2 # type: ignore
from flask import Flask, request, jsonify # type: ignore

# --- Конфигурация приложения ---
app = Flask(__name__)

# --- Функции для работы с БД ---

def get_db_connection():
    """Устанавливает соединение с базой данных PostgreSQL."""
    try:
        conn = psycopg2.connect(
            host=os.environ.get('DB_HOST'),
            database=os.environ.get('DB_NAME'),
            user=os.environ.get('DB_USER'),
            password=os.environ.get('DB_PASSWORD')
        )
        return conn
    except psycopg2.OperationalError as e:
        # Эта ошибка возникнет, если бэкенд запустится раньше, чем БД будет готова.
        # В реальном проекте здесь была бы логика повторных попыток.
        print(f"Could not connect to database: {e}")
        return None

# --- API Endpoints (точки входа для данных) ---

@app.route('/')
def index():
    """Простая стартовая страница, чтобы проверить, что сервер работает."""
    return "MMO Telemetry Backend is running!"

@app.route('/api/log_event', methods=['POST'])
def log_event():
    """
    Принимает и сохраняет одно боевое событие.
    Ожидает JSON в теле запроса, например:
    {
        "character_id": 1,
        "mob_id": 2,
        "event_type": "PLAYER_ATTACK",
        "damage": 50,
        "loot_gold": 0
    }
    """
    data = request.get_json()

    # Простая валидация входных данных
    if not data or 'character_id' not in data or 'mob_id' not in data or 'event_type' not in data:
        return jsonify({'status': 'error', 'message': 'Missing required fields'}), 400

    # Получаем значения, используя .get() для безопасности (вернет None, если ключа нет)
    character_id = data.get('character_id')
    mob_id = data.get('mob_id')
    event_type = data.get('event_type')
    damage = data.get('damage', 0) # Значение по умолчанию 0
    loot_gold = data.get('loot_gold', 0) # Значение по умолчанию 0

    conn = get_db_connection()
    if conn is None:
        return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO combat_logs (character_id, mob_id, event_type, damage, loot_gold)
                VALUES (%s, %s, %s, %s, %s)
                """,
                (character_id, mob_id, event_type, damage, loot_gold)
            )
        conn.commit()
    except Exception as e:
        print(f"Error inserting data: {e}")
        conn.rollback() # Откатываем транзакцию в случае ошибки
        return jsonify({'status': 'error', 'message': 'Failed to write to database'}), 500
    finally:
        if conn:
            conn.close()

    return jsonify({'status': 'success', 'message': 'Event logged'}), 201


# --- Запуск приложения ---
if __name__ == '__main__':
    # host='0.0.0.0' делает сервер доступным извне контейнера (внутри нашей Docker-сети)
    # port=8000 - порт, на котором будет работать сервер
    app.run(host='0.0.0.0', port=8000, debug=True)