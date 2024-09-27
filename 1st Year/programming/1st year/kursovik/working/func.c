#include <func.h>

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
