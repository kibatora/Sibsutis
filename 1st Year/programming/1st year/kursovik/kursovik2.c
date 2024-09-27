#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_FILENAME_LENGTH 256
#define ALPHABET_SIZE 33 // Количество символов в квадрате Полибия
#define ROWS 6 // Количество строк в квадрате Полибия
#define COLS 6 // Количество столбцов в квадрате Полибия

char *polibiy[ROWS] = { "АБВГДЕ", "ЁЖЗИЙ", "КЛМНО", "ПРСТУ", "ФХЦЧШ", "ЩЪЫЬЭЮЯ" }; // Квадрат Полибия

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

void Polibi(char *input_file, char *output_file) {
    FILE *input, *output;
    char c;
    int i, j, row, col;

    // Вывод содержимого исходного файла на экран
    print_file(input_file);

    // Открытие файлов
    input = fopen(input_file, "r");
    output = fopen(output_file, "w");

    if (input == NULL || output == NULL) {
        printf("Ошибка открытия файла\n");
        return;
    }

    // Шифрование
    while ((c = fgetc(input)) != EOF) {
        if (c == '\n') {
            fputc(c, output);
            continue;
        }

        // Определение координат символа в квадрате Полибия
        for (i = 0; i < ROWS; i++) {
            for (j = 0; j < COLS; j++) {
                if (polibiy[i][j] == c || (c == 'Ё' && polibiy[i][j] == 'Е')) { // 'Ё' отображается на ту же ячейку, что и 'Е'
                    row = i + 1; // Нумерация строк начинается с 1
                    col = j + 1; // Нумерация столбцов начинается с 1
                    break;
                }
            }
        }

        // Запись координат в файл
        fprintf(output, "%d %d ", row, col);
    }

    // Закрытие файлов
    fclose(input);
    fclose(output);

    printf("Шифрование завершено.\n");

    // Вывод содержимого зашифрованного файла на экран
    print_file(output_file);
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
            fprintf(output, "%c", ' ');
        } else {
            fprintf(output, "%c", polibiy[row-1][col-1]);
        }
    }

    // Закрытие файлов
    fclose(input);
    fclose(output);

    printf("Расшифровка завершена.\n");

    // Вывод содержимого расшифрованного файла на экран
    print_file(output_file);
}

// Функция для сравнения двух файлов
void compare_files(char *input_file, char *output_file) {
FILE *input, *output;
char input_char, output_char;
// Открытие файлов
input = fopen(input_file, "r");
output = fopen(output_file, "r");

if (input == NULL || output == NULL) {
    printf("Ошибка открытия файла\n");
    return;
}

// Сравнение файлов
while ((input_char = fgetc(input)) != EOF && (output_char = fgetc(output)) != EOF) {
    if (input_char != output_char) {
        printf("Ошибка: исходный текст и дешифрованный текст не совпадают\n");
        return;
    }
}
// Закрытие файлов
fclose(input);
fclose(output);

printf("Исходный текст и дешифрованный текст совпадают.\n");
}

int main() {
// Выделение памяти под входные данные
char *input_file = (char *)malloc(MAX_FILENAME_LENGTH * sizeof(char));
char *output_file = (char *)malloc(MAX_FILENAME_LENGTH * sizeof(char));
// Ввод имени файла с исходным текстом
printf("Введите имя файла с исходным текстом: ");
scanf("%s", input_file);

// Ввод имени файла с зашифрованным текстом
printf("Введите имя файла с зашифрованным текстом: ");
scanf("%s", output_file);

// Шифрование и дешифрование
Polibi(input_file, "encrypted.txt");
DePolibi("encrypted.txt", "decrypted.txt");
compare_files(input_file, "decrypted.txt");

// Освобождение памяти
free(input_file);
free(output_file);

return 0;
}