#include <stdio.h>

int main() {
    FILE *fp;
    char filename[] = "C:\\Games\\prog\\input1.txt";
    char ch;

    fp = fopen(filename, "r"); // открытие файла для чтения

    if (fp == NULL) {
        printf("Не удалось открыть файл\n");
        return 1;
    }

    // вывод содержимого файла на экран
    while ((ch = fgetc(fp)) != EOF) {
        printf("%c", ch);
    }

    fclose(fp); // закрытие файла

    return 0;
}
