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
    return "Telemetry Backend is running!"

@app.route('/api/log_event', methods=['POST'])
def log_event():
    data = request.get_json()
    if not data or 'device_id' not in data or 'app_id' not in data or 'data_used_mb' not in data:
        return jsonify({'status': 'error', 'message': 'Missing required fields'}), 400

    device_id = data.get('device_id')
    app_id = data.get('app_id')
    data_used = data.get('data_used_mb')

    conn = get_db_connection()
    if conn is None:
        return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO traffic_logs (device_id, app_id, data_used_mb)
                VALUES (%s, %s, %s)
                """,
                (device_id, app_id, data_used)
            )
        conn.commit()
    except Exception as e:
        print(f"Error inserting data: {e}")
        conn.rollback()
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