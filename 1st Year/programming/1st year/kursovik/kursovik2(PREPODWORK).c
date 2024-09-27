#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ROWS 5
#define COLS 5

char *encrypt(char *input);
char *decrypt(char *input);

char *encrypt(char *input) {
    char *output = NULL;
    char key[ROWS][COLS] = {
        {'A', 'B', 'C', 'D', 'E'},
        {'F', 'G', 'H', 'I', 'K'},
        {'L', 'M', 'N', 'O', 'P'},
        {'Q', 'R', 'S', 'T', 'U'},
        {'V', 'W', 'X', 'Y', 'Z'}
    };
    int input_length, i, j, k;

    // Получение размера входного текста
    input_length = strlen(input);

    // Выделение памяти под выходной текст
    output = (char*)malloc((2 * input_length + 1) * sizeof(char));

    // Шифрование текста
    for (i = 0, k = 0; i < input_length; i++) {
        if (input[i] >= 'A' && input[i] <= 'Z') {
            // Поиск символа в таблице Полибия
            for (j = 0; j < ROWS; j++) {
                for (k = 0; k < COLS; k++) {
    if (key[j][k] == input[i]) {
    // Запись координат символа в выходной текст
    output[2 * i] = '1' + j;
    output[2 * i + 1] = '1' + k;
    break;
    }
    }
    }
    } else {
    // Копирование символа без шифрования
    output[2 * i] = input[i];
    output[2 * i + 1] = '\0';
    }
    }
    output[2 * i] = '\0';
    return output;
} 
char *decrypt(char *input) {
    char *output = NULL;
    char key[ROWS][COLS] = {
    {'A', 'B', 'C', 'D', 'E'},
    {'F', 'G', 'H', 'I', 'K'},
    {'L', 'M', 'N', 'O', 'P'},
    {'Q', 'R', 'S', 'T', 'U'},
    {'V', 'W', 'X', 'Y', 'Z'}
    };
    int input_length, i, j, k, row, col;
    // Получение размера входного текста
    input_length = strlen(input);

    // Выделение памяти под выходной текст
    output = (char*)malloc((input_length / 2 + 1) * sizeof(char));

    // Дешифрование текста
    for (i = 0, j = 0; i < input_length; i += 2, j++) {
        if (input[i] >= '1' && input[i] <= '5' && input[i+1] >= '1' && input[i+1] <= '5') {
            // Вычисление координат символа в таблице Полибия
            row = input[i] - '1';
            col = input[i+1] - '1';

            // Запись символа в выходной текст
            output[j] = key[row][col];
        } else {
            // Копирование символа без дешифрования
            output[j] = input[i];
            i--;
        }
    }
    output[j] = '\0';

    return output;
}

int main() {
    FILE *input_file;
    FILE *output_file;
    char *input_text = NULL;
    char *encrypted_text = NULL;
    char *decrypted_text = NULL;
    long input_size, output_size;

    // Чтение входного файла
    input_file = fopen("C:\\Games\\prog\\input.txt", "r");
    if (input_file) {
        fseek(input_file, 0, SEEK_END);
        input_size = ftell(input_file);
        fseek(input_file, 0, SEEK_SET);
        input_text = (char*)malloc(input_size * sizeof(char));
        if (input_text) {
            fread(input_text, sizeof(char), input_size, input_file);
        }
        fclose(input_file);
    }

    // Шифрование текста
    encrypted_text = encrypt(input_text);
    printf("Encrypted text: %s\n", encrypted_text);

    // Запись зашифрованного текста в файл
    output_file = fopen("encrypted.txt", "w");
    if (output_file) {
        output_size = strlen(encrypted_text);
        fwrite(encrypted_text, sizeof(char), output_size, output_file);
        fclose(output_file);
    }

    // Дешифрование текста
    decrypted_text = decrypt(encrypted_text);
    printf("Decrypted text: %s\n", decrypted_text);

    // Проверка того, что исходный текст и полученные после дешифровки совпадают
    if (strcmp(input_text, decrypted_text) == 0) {
        printf("Original text and decrypted text match.\n");
    } else {
        printf("Error: Original text and decrypted text do not match.\n");
    }

    // Освобождение выделенной памяти
    free(input_text);
    free(encrypted_text);
    free(decrypted_text);

    return 0;
}

                  
