#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_FILENAME_LENGTH 256
#define ALPHABET_SIZE 26 // Количество символов в английском алфавите
#define ROWS 5 // Количество строк в квадрате Полибия
#define COLS 5 // Количество столбцов в квадрате Полибия

char *polibiy[ROWS] = {"ABCDE", "FGHIK", "LMNOP", "QRSTU", "VWXYZ"}; // Квадрат Полибия

// Функция для чтения файла и вывода его содержимого на экран
void print_file(char *filename) {
    FILE *file = fopen(filename, "r");
    char c;
    printf("Содержимое файла %s:\n", filename);
    while ((c = fgetc(file)) != EOF) {
        printf("%c", c);
    }
    printf("\n");
    fclose(file);
}

void Polibi(char *input_file) {
    FILE *input, *output;
    int encrypted_data[MAX_INPUT_SIZE], size = 0;
    char c;
    int i, j, row, col, index;
    int encrypted_data_index = 0;
    // Вывод содержимого исходного файла на экран
    print_file(input_file);

    // Открытие файлов
    input = fopen(input_file, "r");
    if (input == NULL) {
        printf("Ошибка открытия файла\n");
        return;
    }

    // Вычисление размера входного файла
    fseek(input, 0L, SEEK_END);
    long int input_size = ftell(input);
    fseek(input, 0L, SEEK_SET);

    // Выделение памяти под входные данные
    char *input_data = (char *) malloc(input_size + 1);
    if (input_data == NULL) {
        printf("Ошибка выделения памяти\n");
        return;
    }

    // Чтение входных данных в память
    fread(input_data, sizeof(char), input_size, input);
    input_data[input_size] = '\0';

    // Закрытие входного файла
    fclose(input);

    // Выделение памяти под выходные данные
    char *output_data = (char *) malloc((input_size * 3) + 1);
    if (output_data == NULL) {
        printf("Ошибка выделения памяти\n");
        return;
    }

    // Шифрование
    for (i = 0, j = 0; i < input_size; i++) {
        c = input_data[i];
        if (c == '\n') {
            output_data[j++] = c;
            continue;
        } else if (c == ' ') {
            output_data[j++] = ' ';
            continue;
        }
        index = c - 'A';
        if (index < 0 || index >= ALPHABET_SIZE) {
            printf("Недопустимый символ: %c\n", c);
            free(input_data);
            free(output_data);
            return;
        }
        row = index / COLS;
        col = index % COLS;
        output_data[j++] = polibiy[row][col];
    }

    // Запись зашифрованных данных в файл
    char *output_file = "output.txt";
    output = fopen(output_file, "w");
    if (output == NULL) {
        printf("Ошибка при открытии файла для записи");
    }

    // Записываем зашифрованные данные в файл
    for (int i = 0; i < size; i++) {
        fprintf(output, "%d ", encrypted_data[i]);
    }

    // Закрываем файл
    fclose(output);

    printf("Зашифрованные данные записаны в файл: %s\n", output_file);
}

   
// Функция для расшифровки текста
void DePolibi(char *input_file, char *output_file) {
    FILE *input, *output;
    int row, col;
    char c;

    // Вывод содержимого зашифрованного файла на экран
    print_file(output_file);

    // Открытие файлов
    input = fopen(output_file, "r");
    output = fopen(input_file, "w");

    if (input == NULL || output == NULL) {
        printf("Ошибка открытия файла\n");
        return;
    }

    // Расшифровка
    while (fscanf(input, "%d %d", &row, &col) == 2) {
        if (row < 1 || row > ROWS || col < 1 || col > COLS) {
            printf("Неверный формат зашифрованного файла\n");
            fclose(input);
            fclose(output);
            return;
        }

        // Получение символа по координатам из квадрата Полибия
        c = polibiy[row - 1][col - 1];

        // Запись символа в файл
        fputc(c, output);
    }

    // Закрытие файлов
    fclose(input);
    fclose(output);

    printf("Дешифровка завершена.\n");

    // Вывод содержимого дешифрованного файла на экран
    print_file(input_file);
}
int main() {
    char input_file[MAX_FILENAME_LENGTH];
    char output_file[MAX_FILENAME_LENGTH];

    // Запрос имени файла с исходным текстом
    printf("Введите имя файла с исходным текстом: ");
    scanf("%s", input_file);

    // Запрос имени файла для сохранения зашифрованного текста
    printf("Введите имя файла для сохранения зашифрованного текста: ");
    scanf("%s", output_file);

    // Шифрование текста
    Polibi(input_file, output_file);

    // Дешифрование текста
    DePolibi(input_file, output_file);

    // Сравнение исходного текста и дешифрованного текста
    printf("Проверка результатов...\n");
    if (compare_files(input_file, output_file)) {
        printf("Исходный текст и дешифрованный текст совпадают.\n");
    } else {
        printf("Исходный текст и дешифрованный текст не совпадают.\n");
    }

    return 0;
}
