#include <func.h>

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