import random
import numpy as np
#код хэминнга. разбивать по 4, и вычисляю последовательность 7. декодировать. 
#поскольку знаем количество ошибок, должны вывести сколько смогли их найти.
#добавить шумы. сравнить между началом и концом, а также до и после работы хэминнга

def text_to_bits(text):
    bits = []
    for char in text:
        char_bits = list(int(bit) for bit in bin(ord(char))[2:].zfill(8))
        bits.extend(char_bits)
    return bits

def hamming_encode(data):
    if len(data) != 4:
        raise ValueError("Входные данные должны быть длиной 4 бита")
    p1 = data[0] ^ data[1] ^ data[3]
    p2 = data[0] ^ data[2] ^ data[3]
    p3 = data[1] ^ data[2] ^ data[3]
    return [p1, p2, data[0], p3, data[1], data[2], data[3]]

def hamming_decode(coded_data):
    if len(coded_data) != 7:
        raise ValueError("Входные данные должны быть длиной 7 бит")

    coded_data_copy = coded_data[:]
    p1, p2, d1, p3, d2, d3, d4 = coded_data_copy

    s1 = p1 ^ d1 ^ d2 ^ d4
    s2 = p2 ^ d1 ^ d3 ^ d4
    s3 = p3 ^ d2 ^ d3 ^ d4

    error_pos = s1 + (s2 << 1) + (s3 << 2)

    if error_pos != 0:
        coded_data_copy[error_pos - 1] ^= 1
        d1, d2, d3, d4 = coded_data_copy[2], coded_data_copy[4], coded_data_copy[5], coded_data_copy[6]

    return [d1, d2, d3, d4], error_pos

def bits_to_text(bits):
    text = ""
    for i in range(0, len(bits), 8):
        byte = bits[i:i+8]
        if len(byte) == 8:
           text += chr(int("".join(map(str, byte)), 2))
    return text


# Основная часть программы
text = input("Введите текст: ")


original_bits = text_to_bits(text)
print(f"Исходные биты: {original_bits}")

# Дополнение нулями
padded_bits = original_bits[:]
while len(padded_bits) % 4 != 0:
    padded_bits.append(0)

# 3. Кодирование Хэмминга
encoded_bits = []
for i in range(0, len(padded_bits), 4):
    encoded_bits.extend(hamming_encode(padded_bits[i:i+4]))

print(f"Все закодированные биты: {encoded_bits}")

# --- ДОБАВЛЕНИЕ ШУМА ---
try:
    noise_std_dev = float(input("Введите стандартное отклонение шума (sigma): "))
    noise = np.random.normal(0, noise_std_dev, len(encoded_bits))
    noisy_encoded_bits = (np.array(encoded_bits) + noise).tolist()
    noisy_encoded_bits = [1 if bit > 0.5 else 0 for bit in noisy_encoded_bits]
    print(f"Закодированные биты с шумом: {noisy_encoded_bits}")

except ValueError as e:
    print(f"Ошибка: {e}. Шум не добавлен.")
    noisy_encoded_bits = encoded_bits

# 4. Внесение ОШИБКИ (одна ошибка на блок)
errors_introduced = 0
for i in range(0, len(noisy_encoded_bits), 7):
    if len(noisy_encoded_bits[i:i+7]) == 7:
        error_position = (i + 2) % 7
        noisy_encoded_bits[i + error_position] ^= 1
        errors_introduced += 1
        print(f"Внесена ошибка в позицию {i + error_position}, Биты с ошибками и шумом: {noisy_encoded_bits}")


# 5. Декодирование Хэмминга и исправление ошибок
decoded_bits = []
errors_corrected = 0
for i in range(0, len(noisy_encoded_bits), 7):
    if len(noisy_encoded_bits[i:i+7]) == 7:
        decoded_block, error_pos = hamming_decode(noisy_encoded_bits[i:i+7])
        decoded_bits.extend(decoded_block)
        if error_pos != 0:
            errors_corrected += 1


# Обрезка до исходной длины и преобразование в текст
decoded_bits = decoded_bits[:len(original_bits)]
decoded_text = bits_to_text(decoded_bits)

print("Декодированный текст:", decoded_text)
print("Введено ошибок:", errors_introduced)
print("Исправлено ошибок:", errors_corrected)

def compare_bits(bits1, bits2):
    differences = 0
    for i in range(min(len(bits1), len(bits2))):
        if bits1[i] != bits2[i]:
            differences += 1
    return differences

differences_after = compare_bits(original_bits, decoded_bits)

print(f"Различий между исходными и декодированными битами (после Хэмминга): {differences_after}")