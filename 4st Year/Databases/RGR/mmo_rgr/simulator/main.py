import requests
import random
import time

# --- Настройки Симулятора ---
# Адрес нашего бэкенда. Docker Compose позволяет обращаться к контейнеру по имени сервиса.
BACKEND_URL = "http://backend:8000/api/log_event"

# Параметры симуляции
SIMULATION_DURATION_SECONDS = 60  # Как долго будет работать симулятор
EVENTS_PER_SECOND = 5  #Сколько событий генерировать в секунду

# --- Игровые данные (в реальной игре это бы бралось из БД) ---
# Для простоты симуляции, мы "захардкодим" ID существующих персонажей и мобов.
# В нашем init.sql мы создали персонажей и мобов, но наш симулятор о них не знает.
# В идеале, симулятор бы сначала регистрировал их через API, но для РГР это усложнение.
# Допустим, у нас есть персонажи с ID 1 и 2, и мобы с ID 1, 2, 3, 4.
# Мы будем создавать их "на лету" в симуляции.
# Для РГР мы можем просто использовать случайные ID, база данных их примет.

CHARACTER_IDS = [1, 2, 3, 4, 5]
MOB_IDS = [1, 2, 3, 4]

# --- Основная логика симулятора ---

def generate_combat_event():
    """Генерирует одно случайное боевое событие с новой логикой."""
    
    character_id = random.choice(CHARACTER_IDS)
    mob_id = random.choice(MOB_IDS)
    
    # !! ОБНОВЛЕНИЕ: Добавляем шанс уклонения моба !!
    # 60% шанс на обычную атаку
    # 20% шанс на уклонение моба
    # 20% шанс на убийство моба
    
    rand_num = random.random() # Генерируем случайное число от 0.0 до 1.0

    if rand_num < 0.6: # 60%
        event = {
            "character_id": character_id, "mob_id": mob_id,
            "event_type": "PLAYER_ATTACK",
            "damage": random.randint(10, 100),
            "loot_gold": 0
        }
    elif rand_num < 0.8: # 20% (от 0.6 до 0.8)
        event = {
            "character_id": character_id, "mob_id": mob_id,
            "event_type": "MOB_DODGE",
            "damage": 0, # Урона нет
            "loot_gold": 0 # Золота нет
        }
    else: # 20% 
        event = {
            "character_id": character_id, "mob_id": mob_id,
            "event_type": "MOB_DIED",
            "damage": 0,
            "loot_gold": random.randint(5, 50)
        }
    
    return event

def run_simulation():
    """Главный цикл симуляции."""
    print("Starting MMO Battle Simulator (v2)...")
    start_time = time.time()
    
    while time.time() - start_time < SIMULATION_DURATION_SECONDS:
        try:
            event_data = generate_combat_event()
            response = requests.post(BACKEND_URL, json=event_data, timeout=5)
            
            if response.status_code == 201:
                print(f"Successfully logged event: {event_data['event_type']} (CharID: {event_data['character_id']}, MobID: {event_data['mob_id']})")
            else:
                print(f"Failed to log event. Status: {response.status_code}, Response: {response.text}")
        except requests.exceptions.RequestException as e:
            print(f"Error connecting to backend: {e}")
        
        time.sleep(1.0 / EVENTS_PER_SECOND)
        
    print("Simulation finished.")

if __name__ == "__main__":
    print("Simulator is waiting for backend to start...")
    time.sleep(10) 
    run_simulation()