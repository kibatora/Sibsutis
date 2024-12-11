#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <zlib.h> // Для функций crc32

// Полиномы для CRC
typedef struct {
    const char *name;
    uLong polynomial;
} CRC_Polynomial;

CRC_Polynomial polynomials[] = {
    {"CRC-8", 0x07},         // Полином для CRC-8
    {"CRC-16", 0x8005},      // Полином для CRC-16
    {"CRC-32", 0x04C11DB7}   // Полином для CRC-32
};

// Функция для генерации случайной последовательности
void generate_random_sequence(unsigned char *data, int bit_count) {
    int byte_count = (bit_count + 7) / 8;
    for (int i = 0; i < byte_count; i++) {
        data[i] = rand() % 256; // Заполняем случайными байтами
    }

    // Убираем лишние биты, если длина последовательности не кратна 8
    if (bit_count % 8 != 0) {
        unsigned char mask = (1 << (bit_count % 8)) - 1;
        data[byte_count - 1] &= mask;
    }
}

// Функция для проверки ошибок при изменении битов(многобитные ошибки)
int test_crc_errors(unsigned char *data, int bit_count, uLong polynomial) {
    int byte_count = (bit_count + 7) / 8;
    unsigned char temp_data[byte_count];
    memcpy(temp_data, data, byte_count);

    uLong original_crc = crc32(0L, data, byte_count); // Начальное значение = 0

    int errors_detected = 0;
    int errors_missed = 0;

    for (int bit_position = 0; bit_position < bit_count; bit_position++) {
        memcpy(temp_data, data, byte_count);

        // Искажение двух битов
        int byte_index = bit_position / 8;
        int bit_index = bit_position % 8;
        temp_data[byte_index] ^= (1 << bit_index);

        if (bit_position + 1 < bit_count) {
            int next_byte_index = (bit_position + 1) / 8;
            int next_bit_index = (bit_position + 1) % 8;
            temp_data[next_byte_index] ^= (1 << next_bit_index);
        }

        // Проверяем CRC
        uLong corrupted_crc = crc32(0L, temp_data, byte_count);
        if (corrupted_crc != original_crc) {
            errors_detected++;
        } else {
            errors_missed++;
        }
    }

    return errors_missed; // Возвращаем количество пропущенных ошибок
}

void save_results_to_file(const char *filename, const char **names, const int *missed_errors, int count) {
    FILE *file = fopen(filename, "w");
    if (!file) {
        perror("Error opening file");
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < count; i++) {
        fprintf(file, "%s %d\n", names[i], missed_errors[i]);
    }

    fclose(file);
}

int main() {
    srand(time(NULL));

    const int sequence_length = 10000; // Длина последовательности в битах
    unsigned char sequence[sequence_length / 8];

    const int num_polynomials = sizeof(polynomials) / sizeof(polynomials[0]);
    int missed_errors[num_polynomials];

    for (int i = 0; i < num_polynomials; i++) {
        generate_random_sequence(sequence, sequence_length);
        missed_errors[i] = test_crc_errors(sequence, sequence_length, polynomials[i].polynomial);
        printf("Polynomial: %s, Missed errors: %d\n", polynomials[i].name, missed_errors[i]);
    }

    const char *names[num_polynomials];
    for (int i = 0; i < num_polynomials; i++) {
        names[i] = polynomials[i].name;
    }

    save_results_to_file("results.txt", names, missed_errors, num_polynomials);

    // Запускаем Gnuplot для построения графика
    FILE *gnuplot = popen("gnuplot -persistent", "w");
    if (gnuplot) {
        fprintf(gnuplot, "set terminal png size 800,600\n");
        fprintf(gnuplot, "set output 'graph.png'\n");
        fprintf(gnuplot, "set title 'CRC Error Detection'\n");
        fprintf(gnuplot, "set xlabel 'Polynomial'\n");
        fprintf(gnuplot, "set ylabel 'Missed Errors'\n");
        fprintf(gnuplot, "plot 'results.txt' using 2:xtic(1) with linespoints title 'Missed Errors'\n");
        pclose(gnuplot);
    }

    return 0;
}
