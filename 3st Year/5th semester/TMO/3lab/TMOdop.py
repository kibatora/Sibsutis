import numpy as np

# Определение матрицы переходов
P = np.array([
    [0.2, 0.7, 0.1],  # Состояние 1
    [0.1, 0.6, 0.3],  # Состояние 2
    [0.5, 0.3, 0.2]   # Состояние 3
])

# Начальное состояние
initial_state = 0  # Индекс начального состояния (от 0)

# Количество шагов симуляции
num_steps = 10

# Симуляция цепи Маркова
current_state = initial_state
states = [current_state]  # Список для хранения посещенных состояний

for _ in range(num_steps):
    # Выбор следующего состояния на основе матрицы переходов
    next_state = np.random.choice(len(P), p=P[current_state])
    
    # Обновление текущего состояния и добавление в список
    current_state = next_state
    states.append(current_state)

# Вывод результата
print("Посещенные состояния:", states)