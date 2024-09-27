#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define ROWS 5
#define COLS 5

char *Polibi(char *input);
char *DePolibi(char *input);
void strip_punct_and_spaces(char *str);

int main(int argc, char *argv[]) {
    // Проверка количества аргументов
    if (argc != 2) {
        printf("Usage: %s input_file\n", argv[0]);
        return 1;
    }

    // Открытие файла
    FILE *input_file = fopen(argv[1], "r");
    if (!input_file) {
        printf("Error: Could not open input file\n");
        return 1;
    }

    // Определение размера файла
    fseek(input_file, 0L, SEEK_END);
    int file_size = ftell(input_file);
    fseek(input_file, 0L, SEEK_SET);

    // Выделение памяти и чтение текста из файла
    char *input = (char*)malloc((file_size + 1) * sizeof(char));
    fgets(input, file_size + 1, input_file);
    fclose(input_file);

    // Вывод исходного текста
    printf("Input text: %s\n", input);

    // Шифрование текста
    char *encrypted = Polibi(input);

    // Запись зашифрованного текста в файл
    FILE *output_file = fopen("encrypted.txt", "w");
    if (!output_file) {
        printf("Error: Could not open output file\n");
        return 1;
    }
    fprintf(output_file, "%s", encrypted);
    fclose(output_file);

    // Вывод зашифрованного текста
    printf("Encrypted text: %s\n", encrypted);

    // Расшифрование текста из файла
    FILE *encrypted_file = fopen("encrypted.txt", "r");
    if (!encrypted_file) {
        printf("Error: Could not open encrypted file\n");
        return 1;
    }

    // Определение размера файла
    fseek(encrypted_file, 0L, SEEK_END);
    int encrypted_size = ftell(encrypted_file);
    fseek(encrypted_file, 0L, SEEK_SET);

    // Выделение памяти и чтение текста из файла
    char *encrypted_text = (char*)malloc((encrypted_size + 1) * sizeof(char));
    fgets(encrypted_text, encrypted_size + 1, encrypted_file);
    fclose(encrypted_file);

    // Расшифрование текста
    char *decrypted = DePolibi(encrypted_text);

    // Вывод расшифрованного текста
    printf("Decrypted text: %s\n", decrypted);

    //удаляем пробелы и знаки препинания из текста
    strip_punct_and_spaces(input);
    strip_punct_and_spaces(decrypted);

    // Сравнение исходного текста с расшифрованным текстом
    if (strcmp(input, decrypted) == 0) {
        printf("Encryption and decryption successful!\n");
    } else {
        printf("Encryption and decryption failed!\n");
    }

    // Освобождение памяти
    free(input);
    free(encrypted);
    free(encrypted_text);
    free(decrypted);
    return 0;
}
// Шифрование текста с помощью таблицы Полибия
char *Polibi(char *input) {
    char *output = (char*)malloc((2 * strlen(input) + 1) * sizeof(char));
    int i, j, k;
    for (i = 0, k = 0; input[i]; i++) {
        if (!isspace(input[i])) {
            if (input[i] == 'J') {
                input[i] = 'I';
            }
            if (islower(input[i])) {
                input[i] = toupper(input[i]);
            }
            j = input[i] - 'A';
            output[k++] = '1' + j / 5;
            output[k++] = '1' + j % 5;
        }
    }
    output[k] = '\0';
    return output;
}

// Расшифрование текста с помощью таблицы Полибия
char *DePolibi(char *input) {
    char *output = (char*)malloc((strlen(input) / 2 + 1) * sizeof(char));
    int i, j, k;
    for (i = 0, k = 0; input[i]; i += 2) {
        j = (input[i] - '1') * 5 + input[i + 1] - '1';
        output[k++] = 'A' + j;
    }
    output[k] = '\0';
    return output;
}

// Удаление пробелов и знаков препинания из строки
void strip_punct_and_spaces(char *str) {
int i, j;
for (i = 0, j = 0; str[i]; i++) {
if (!isspace(str[i]) && !ispunct(str[i])) {
str[j++] = toupper(str[i]);
}
}
str[j] = '\0';
}
