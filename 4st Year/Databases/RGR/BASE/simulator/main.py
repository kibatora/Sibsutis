import requests
import random
import time

BACKEND_URL = "http://backend:8000/api/log_event"
SIMULATION_DURATION_SECONDS = 120
EVENTS_PER_SECOND = 10 # Увеличим интенсивность, трафик генерируется быстро

# ID наших устройств и приложений из init.sql
DEVICE_IDS = [1, 2, 3, 4]
APP_IDS = [1, 2, 3, 4, 5, 6]

def run_simulation():
    print("Starting App Traffic Simulator...")
    start_time = time.time()
    
    while time.time() - start_time < SIMULATION_DURATION_SECONDS:
        # Генерируем одно событие потребления трафика
        event_data = {
            "device_id": random.choice(DEVICE_IDS),
            "app_id": random.choice(APP_IDS),
            "data_used_mb": random.randint(5, 100) # Случайный объем трафика
        }

        try:
            response = requests.post(BACKEND_URL, json=event_data, timeout=5)
            if response.status_code == 201:
                print(f"Logged: Device {event_data['device_id']} used {event_data['data_used_mb']}MB on App {event_data['app_id']}")
            else:
                print(f"Failed to log event. Status: {response.status_code}")
        except requests.exceptions.RequestException as e:
            print(f"Error connecting to backend: {e}")
            
        time.sleep(1.0 / EVENTS_PER_SECOND)
        
    print("Simulation finished.")

if __name__ == "__main__":
    print("Simulator is waiting for backend to start...")
    time.sleep(10)
    run_simulation()