#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//РАБОЧИЙ КОД!!!!!!!?!?!?!!?!?!?!??
#define ROWS 5
#define COLS 5

// Объявление функций
char *encrypt(char *input);
char *decrypt(char *input);

// Функция для шифрования текста
char *encrypt(char *input) {
    // Создание таблицы Полибия
    char key[ROWS][COLS] = {
        {'A', 'B', 'C', 'D', 'E'},
        {'F', 'G', 'H', 'I', 'K'},
        {'L', 'M', 'N', 'O', 'P'},
        {'Q', 'R', 'S', 'T', 'U'},
        {'V', 'W', 'X', 'Y', 'Z'}
    };
    int input_length = strlen(input);
    char *output = (char*)malloc((2 * input_length + 1) * sizeof(char)); // Выделение памяти под выходной текст
    int output_index = 0; // Индекс выходного текста

    for (int i = 0; i < input_length; i++) {
        // Если символ не входит в диапазон A-Z, то он копируется без изменений
        if (input[i] < 'A' || input[i] > 'Z') {
            output[output_index++] = input[i];
            continue;
        }

        // Поиск символа в таблице Полибия
        for (int j = 0; j < ROWS; j++) {
            for (int k = 0; k < COLS; k++) {
                if (key[j][k] == input[i]) {
                    // Запись координат символа в выходной текст
                    output[output_index++] = '1' + j;
                    output[output_index++] = '1' + k;
                    break;
                }
            }
        }
    }
    output[output_index] = '\0';

    return output;
}

// Функция для дешифрования текста
char *decrypt(char *input) {
    // Создание таблицы Полибия
    char key[ROWS][COLS] = {
        {'A', 'B', 'C', 'D', 'E'},
        {'F', 'G', 'H', 'I', 'K'},
        {'L', 'M', 'N', 'O', 'P'},
        {'Q', 'R', 'S', 'T', 'U'},
        {'V', 'W', 'X', 'Y', 'Z'}
    };
    int input_length = strlen(input);
    char *output = (char*)malloc((input_length / 2 + 1) * sizeof(char)); // Выделение памяти под выходной текст
    int output_index = 0; // Индекс выходного текста

    for (int i = 0; i < input_length; i += 2) {
        // Если символы не соответствуют координатам в таблице Полибия, то они копируются без изменений
        if (input[i] < '1' || input[i] > '5' || input[i+1] < '1' || input[i+1] > '5') {
        output[output_index++] = input[i];
            i--;
        continue;
    }   
        // Получение координат символа из входного текста
    int row = input[i] - '1';
    int col = input[i+1] - '1';

    // Запись символа в выходной текст
    output[output_index++] = key[row][col];
}
output[output_index] = '\0';

return output;
}
// Основная функция
int main() {
    char input[] = "HELLO WORLD AFTER DEAD"; // Текст для шифрования
    char *encrypted = encrypt(input); // Зашифрованный текст
    char *decrypted = decrypt(encrypted); // Расшифрованный текст
    printf("encrypted text: %s\n", encrypted);
    printf("Deciphered text: %s\n", decrypted);
    // Сравнение текста до и после шифрования-расшифрования
    if (strcmp(input, decrypted) == 0) {
        printf("Encryption and decryption successful!\n");
    } else {
        printf("Encryption and decryption failed!\n");
    }

    // Освобождение памяти
    free(encrypted);
    free(decrypted);

    return 0;
}
