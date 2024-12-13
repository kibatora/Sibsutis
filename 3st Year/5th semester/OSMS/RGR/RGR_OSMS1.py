import matplotlib.pyplot as plt
import numpy as np

# Функция для перевода строки в последовательность бит
# Преобразует строку в массив бит с помощью ASCII-кодов. 

def text_to_bit_sequence(input_string):
    bit_sequence = []  # Создаем пустой список для хранения битов
    for character in input_string:
        binary_repr = bin(ord(character))[2:].zfill(8)  # Преобразуем символ в ASCII-код, затем в двоичный вид (8 бит)
        bit_sequence.extend([int(bit) for bit in binary_repr])  # Добавляем биты в массив
    return bit_sequence  # Возвращаем массив бит

# Функция для вывода таблицы ASCII-кодов
# Печатает символы, их десятичный и двоичный эквиваленты

def print_ascii_table(text):
    print("\nТаблица ASCII-кодов:")  # Заголовок таблицы
    for char in text:
        ascii_code = ord(char)  # Получаем ASCII-код символа
        binary_representation = f"{ascii_code:08b}"  # Преобразуем в двоичный вид
        print(f"'{char}': {ascii_code} (десятичное), {binary_representation} (двоичное)")  # Печатаем информацию

# Функция для визуализации последовательности бит
# Рисует ступенчатый график значений бит

def plot_bit_sequence(bits, title="Визуализация битов"):
    fig, ax = plt.subplots(figsize=(10, 2))  # Создаем график с размером 10x2
    ax.step(range(len(bits)), bits, where='post')  # Рисуем ступенчатый график
    ax.set_ylim([-0.5, 1.5])  # Устанавливаем границы оси Y
    ax.set_xlabel("Индекс бита")  # Подпись оси X
    ax.set_ylabel("Значение бита")  # Подпись оси Y
    ax.set_title(title)  # Заголовок графика
    ax.grid(True)  # Включаем сетку
    plt.show()  # Показываем график

# Функция для вычисления CRC (циклический избыточный код)
# Делает побитовое деление по модулю 2 и возвращает остаток

def crc_cal(data, divisor):
    data_length = len(data)
    divisor_length = len(divisor)
    padded_data = data + [0] * (divisor_length - 1)  # Добавляем нули в конец данных для деления

    for i in range(data_length):  # Итерируем по каждому биту данных
        if padded_data[i] == 1:  # Если текущий бит равен 1, выполняем XOR с делителем
            for j in range(divisor_length):
                padded_data[i + j] ^= divisor[j]  # Побитовый XOR

    crc_remainder = padded_data[data_length:]  # Оставшийся остаток — это CRC
    return crc_remainder

# Функция для генерации последовательности Голда
# Использует два регистра сдвига для создания последовательности

def goldSequence(reg1_init, reg2_init, seq_length):
    reg1 = reg1_init[:]  # Создаем копии начальных регистров
    reg2 = reg2_init[:]
    gold_sequence = []

    for _ in range(seq_length):
        out_reg1 = reg1[4]  # Получаем выходной бит первого регистра
        out_reg2 = reg2[4]  # Получаем выходной бит второго регистра

        feedback1 = reg1[1] ^ reg1[4]  # XOR для обратной связи
        reg1 = [feedback1] + reg1[:-1]  # Обновляем регистр 1

        feedback2 = reg2[0] ^ reg2[1] ^ reg2[2]  # XOR для обратной связи
        reg2 = [feedback2] + reg2[:-1]  # Обновляем регистр 2

        gold_sequence.append(out_reg1 ^ out_reg2)  # Добавляем XOR выходов в последовательность

    return gold_sequence

# Функция для преобразования бит в временные отсчёты
# Каждый бит преобразуется в N одинаковых отсчётов

def timings(bits, samples_per_bit):
    time_samples = []
    for bit in bits:
        time_samples.extend([bit] * samples_per_bit)  # Повторяем каждый бит samples_per_bit раз
    return time_samples

# Функция для выполнения корреляции
# Сравнивает сигнал с образцом и возвращает результат корреляции

def correlation(signal, pattern):
    correlation = np.correlate(signal, pattern, mode='valid')  # Вычисляем корреляцию
    return correlation

# Функция для декодирования временных отсчётов в биты
# Среднее значение отсчётов используется для определения 0 или 1

def decode_time_series(samples, samples_per_bit, threshold):
    decoded_bits = []
    for i in range(0, len(samples) - (len(samples) % samples_per_bit), samples_per_bit):  # Разбиваем отсчеты на группы
        chunk = samples[i:i + samples_per_bit]
        mean_value = np.mean(chunk)  # Считаем среднее значение
        decoded_bits.append(1 if mean_value > threshold else 0)  # Определяем бит
    return decoded_bits

# Функция проверки ошибок с использованием CRC
# Проверяет, остались ли ненулевые биты в CRC

def error_catch(data, divisor):
    computed_crc = crc_cal(data, divisor)
    return all(bit == 0 for bit in computed_crc)

# Функция для преобразования последовательности бит в строку
# Преобразует массив бит обратно в текст, используя ASCII-коды

def bits_to_string(bit_sequence):
    output_string = ""
    for i in range(0, len(bit_sequence), 8):  # Обрабатываем по 8 бит (1 байт)
        byte = bit_sequence[i:i+8]
        char_code = int("".join(str(bit) for bit in byte), 2)  # Преобразуем в символ
        output_string += chr(char_code)
    return output_string

# Функция для визуализации спектра сигнала
# Использует преобразование Фурье для анализа частотных компонентов

def plot_signal_spectrum(signal, fs, label):
    freq = np.fft.rfftfreq(len(signal), d=1/fs)
    spectrum = np.abs(np.fft.rfft(signal))
    plt.plot(freq, spectrum, label=label)

if __name__ == "__main__":
    # Ввод имени и фамилии
    full_name = input("Введите ваше имя и фамилию (по латински): ")
    bit_sequence = text_to_bit_sequence(full_name)

    # Вывод таблицы ASCII
    print_ascii_table(full_name)

    # Визуализация битовой последовательности
    print("\nБитовая последовательность:", bit_sequence)
    plot_bit_sequence(bit_sequence, "Битовая последовательность")

    # Вычисление CRC и добавление к последовательности
    crc_divisor = [1, 1, 1, 1, 0, 1, 1, 1]
    crc_remainder = crc_cal(bit_sequence, crc_divisor)
    print("\nCRC Полином:", crc_divisor)
    print("Вычисленный CRC:", crc_remainder)
    bit_sequence_with_crc = bit_sequence + crc_remainder

    # Генерация последовательности Голда
    reg1_init = [1, 0, 1, 0, 1]
    reg2_init = [1, 1, 1, 0, 1]
    gold_length = 31
    gold_seq = goldSequence(reg1_init, reg2_init, gold_length)
    print("\nПоследовательность Голда:", gold_seq)

    # Итоговая последовательность с Голдом и CRC
    final_sequence = gold_seq + bit_sequence_with_crc
    print("\nИтоговая последовательность (Голд + Данные + CRC):", final_sequence)
    plot_bit_sequence(final_sequence, "Итоговая последовательность (Голд + Данные + CRC)")

    # Преобразование в временные отсчёты
    #N по варианту 24
    samples_per_bit = 24
    time_samples = timings(final_sequence, samples_per_bit)

    # Вычисление параметров длины
    #L — длина битовой последовательности,
    #M — длина CRC,
    #G — длина последовательности Голда,
    #N — количество отсчетов на бит.

    # Длина сигнала по заданию
    signal_length = 2 * samples_per_bit * (len(bit_sequence) + len(crc_remainder) + len(gold_seq))
    shifted_signal = [0] * signal_length

    # Ввод сдвига и формирование сигнала с Голдом и данными
    shift = int(input(f"Введите сдвиг от 0 до {samples_per_bit * (len(bit_sequence) + len(crc_remainder) + len(gold_seq))}: "))
    shifted_signal[shift:shift + len(time_samples)] = time_samples
    plot_bit_sequence(shifted_signal, "Сигнал до зашумления с учетом сдвига")

    # Добавление шума к сигналу
    noise_std_dev = float(input("Введите стандартное отклонение шума (sigma): "))
    noise = np.random.normal(0, noise_std_dev, len(shifted_signal))
    noisy_signal = (np.array(shifted_signal) + noise).tolist()
    plot_bit_sequence(noisy_signal, "Сигнал с шумом")

    # Корреляция для поиска начала синхронизации
    gold_samples = timings(gold_seq, samples_per_bit)
    correlation_result = correlation(noisy_signal, gold_samples)
    gold_start_index = np.argmax(correlation_result)
    print(f"Последовательность Голда начинается с индекса: {gold_start_index}")

    # Декодирование данных
    received_samples = noisy_signal[gold_start_index:]
    decoded_bits = decode_time_series(received_samples, samples_per_bit, threshold=0.5)
    print(f"Декодированные биты (с Голд и CRC): {decoded_bits}")

    # Удаление Голда и проверка CRC
    decoded_bits_without_gold = decoded_bits[len(gold_seq):]
    print(f"Декодированные биты (без Голд, с CRC): {decoded_bits_without_gold}")

    if error_catch(decoded_bits_without_gold[:-len(crc_remainder)], crc_divisor):
        print("Ошибок не обнаружено!")
        decoded_data_bits = decoded_bits_without_gold[:-len(crc_remainder)]
        decoded_string = bits_to_string(decoded_data_bits)
        print("Декодированная строка:", decoded_string)
    else:
        print("Обнаружены ошибки!")

    # Спектральный анализ
    fs = 1000  # Частота дискретизации
    plt.figure(figsize=(12, 6))

    # Графики спектров на одном графике
    plot_signal_spectrum(time_samples, fs, "Переданный сигнал")
    plot_signal_spectrum(noisy_signal, fs, "Принятый зашумленный сигнал")
    time_samples_short = timings(final_sequence, samples_per_bit // 2)
    time_samples_long = timings(final_sequence, samples_per_bit * 2)
    plot_signal_spectrum(time_samples_short, fs, "Сигнал с короткими символами")
    plot_signal_spectrum(time_samples_long, fs, "Сигнал с длинными символами")
    plt.xlabel("Частота (Гц)")
    plt.ylabel("Амплитуда")
    plt.title("Спектральный анализ сигналов")
    plt.legend()
    plt.grid()
    plt.show()

    # Отдельные графики спектров
    plt.figure()
    plot_signal_spectrum(time_samples, fs, "Переданный сигнал")
    plt.xlabel("Частота (Гц)")
    plt.ylabel("Амплитуда")
    plt.title("Спектр переданного сигнала")
    plt.grid()
    plt.show()

    plt.figure()
    plot_signal_spectrum(noisy_signal, fs, "Принятый зашумленный сигнал")
    plt.xlabel("Частота (Гц)")
    plt.ylabel("Амплитуда")
    plt.title("Спектр зашумленного сигнала")
    plt.grid()
    plt.show()

    plt.figure()
    plot_signal_spectrum(time_samples_short, fs, "Сигнал с короткими символами")
    plt.xlabel("Частота (Гц)")
    plt.ylabel("Амплитуда")
    plt.title("Спектр сигнала с короткими символами")
    plt.grid()
    plt.show()

    plt.figure()
    plot_signal_spectrum(time_samples_long, fs, "Сигнал с длинными символами")
    plt.xlabel("Частота (Гц)")
    plt.ylabel("Амплитуда")
    plt.title("Спектр сигнала с длинными символами")
    plt.grid()
    plt.show()