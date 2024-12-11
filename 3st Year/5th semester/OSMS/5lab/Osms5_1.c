#include <stdio.h>
#include <string.h>
#include <stdlib.h> // Для генерации случайных данных
#include <time.h> // Для инициализации генератора случайных чисел

#define N 24 // Длина пакета данных
#define G 0xF7 // Порождающий полином (11110111)

// Функция для вычисления CRC
unsigned char calculate_crc(unsigned char *data, int length) {
    unsigned char crc = 0;
    for (int i = 0; i < length; i++) {
        crc ^= data[i];
        for (int j = 0; j < 8; j++) {
            if (crc & 0x80) {
                crc = (crc << 1) ^ G;
            } else {
                crc <<= 1;
            }
        }
    }
    return crc;
}

// Проверка на ошибки
int check_crc(unsigned char *data, int length, unsigned char received_crc) {
    unsigned char calculated_crc = calculate_crc(data, length);
    return calculated_crc == received_crc;
}

void print_binary(unsigned char *data, int bit_count) {
    for (int i = 0; i < bit_count; i++) {
        int byte_index = i / 8;
        int bit_index = i % 8;
        printf("%d", (data[byte_index] >> bit_index) & 1);
        // Пробел после каждого байта
         if ((i + 1) % 8 == 0 && i < bit_count -1) {
             printf(" "); 
        }
    }
    printf("\n");
}


void print_binary_byte(unsigned char byte) {
    for (int i = 7; i >= 0; i--) { // Вывод битов от старшего к младшему
        printf("%d", (byte >> i) & 1);
    }
}

void process_data(int bit_count) {
    int byte_count = (bit_count + 7) / 8;
    unsigned char data[byte_count];
    unsigned char data_with_crc[byte_count + 1];

    // Случайное заполнение данных
    for (int i = 0; i < byte_count; i++) {
        data[i] = rand() % 256;
    }

    // Обрезаем лишние биты, если bit_count не кратен 8
    if (bit_count % 8 != 0) {
        unsigned char mask = (1 << (bit_count % 8)) - 1;
        data[byte_count - 1] &= mask;
    }

    printf("Original %d-bit data: ", bit_count);
    print_binary(data, bit_count);

    // Вычисление и добавление CRC
    unsigned char crc = calculate_crc(data, byte_count);
    printf("Calculated CRC: ");
    print_binary_byte(crc);
    printf("\n");

    memcpy(data_with_crc, data, byte_count);
    data_with_crc[byte_count] = crc;

    printf("Transmitted data with CRC: ");
    print_binary(data_with_crc, bit_count + 8);


     // Проверка CRC
    unsigned char received_crc = data_with_crc[byte_count];
    if (check_crc(data_with_crc, byte_count, received_crc)) {
        printf("No errors detected in the received %d-bit packet.\n", bit_count + 8);
    } else {
        printf("Error detected in the received %d-bit packet.\n", bit_count + 8);
    }



    // Тестирование с искажением данных (только для bit_count == 250)
    if (bit_count == 250) {
        printf("\nStarting bit-by-bit corruption test...\n");
        int total_bits = bit_count + 8;
        int errors_detected = 0;
        int errors_missed = 0; // Возвращаем счетчики ошибок
        unsigned char temp_packet[byte_count + 1];

        for (int bit_position = 0; bit_position < total_bits; bit_position++) {
            memcpy(temp_packet, data_with_crc, byte_count + 1);

            // Искажение бита
            int byte_index = bit_position / 8;
            int bit_index = bit_position % 8;
            temp_packet[byte_index] ^= (1 << bit_index);


            // Проверка
            unsigned char corrupted_crc = temp_packet[byte_count];
            if (!check_crc(temp_packet, byte_count, corrupted_crc)) {
                errors_detected++;
            } else {
                errors_missed++;
            }
        }

        printf("Test results:\n");
        printf("Total bits tested: %d\n", total_bits);
        printf("Errors detected: %d\n", errors_detected);
        printf("Errors missed: %d\n", errors_missed); // Выводим общее количество
    }
    printf("\n");
}
//акселелятор для crc. посчитать количество не задектированных ошибок по оси y, по оси x размер полинома. три последовательности длиной 10000. три кривых



int main() {
    srand(time(NULL));

    process_data(24);
    process_data(250);

    return 0;
}