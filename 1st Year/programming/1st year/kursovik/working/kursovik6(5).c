#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//ДА, РАБОЧИЙ КОД! ЮХУ!!! осталось сделать функции и на русский язык
#define ROWS 5
#define COLS 5

char *encrypt(char *input);
char *decrypt(char *input);

int main() {
    // Чтение текста из файла
    FILE *input_file = fopen("C:\\Games\\prog\\input.txt", "r");
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
    char *encrypted = encrypt(input);

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
    char *decrypted = decrypt(encrypted_text);

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

char *encrypt(char *input) {
    char key[ROWS][COLS] = {
        {'A', 'B', 'C', 'D', 'E'},
        {'F', 'G', 'H', 'I', 'K'},
        {'L', 'M', 'N', 'O', 'P'},
        {'Q', 'R', 'S', 'T', 'U'},
        {'V', 'W', 'X', 'Y', 'Z'}
    };
    int len = strlen(input);
    // Удаление символа переноса строки
    if (input[len - 1] == '\n') {
        input[len - 1] = '\0';
        len--;
    }
    // Шифрование строки
    char *encrypted = (char*)malloc((len + 1) * sizeof(char));
    int index = 0;
    for (int i = 0; i < len; i++) {
        char c = toupper(input[i]);
        if (c >= 'A' && c <= 'Z') {
            int row, col;
            for (row = 0; row < ROWS; row++) {
                for (col = 0; col < COLS; col++) {
                    if (key[row][col] == c) {
                        encrypted[index++] = row + '1';
                        encrypted[index++] = col + '1';
                    }
                }
            }
        } else if (c != ' ') { // Пропустить пробелы
            encrypted[index++] = c;
        }
    }
    encrypted[index] = '\0';
    return encrypted;
}


char *decrypt(char *input) {
    char key[ROWS][COLS] = {
        {'A', 'B', 'C', 'D', 'E'},
        {'F', 'G', 'H', 'I', 'K'},
        {'L', 'M', 'N', 'O', 'P'},
        {'Q', 'R', 'S', 'T', 'U'},
        {'V', 'W', 'X', 'Y', 'Z'}
    };
    int len = strlen(input);
    // Расшифрование строки
    char *decrypted = (char*)malloc((len + 1) * sizeof(char));
    int index = 0;
    for (int i = 0; i < len; i += 2) {
        if (input[i] >= '1' && input[i] <= '5' && input[i+1] >= '1' && input[i+1] <= '5') {
            // Расшифровываем пару символов из входной строки
int row = input[i] - '1';
int col = input[i+1] - '1';
decrypted[index] = key[row][col];
index++;
}
}
decrypted[index] = '\0'; // Добавляем завершающий нулевой символ
return decrypted;
}
// Функция для удаления пробелов и знаков препинания из текста
void strip_punct_and_spaces(char *text) {
    char *dst = text;
    for (char *src = text; *src; ++src) {
        if (!ispunct((unsigned char)*src) && !isspace((unsigned char)*src)) {
            *dst++ = tolower((unsigned char)*src);
        }
    }
    *dst = '\0';
}