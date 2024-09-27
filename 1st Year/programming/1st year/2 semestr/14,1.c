#include <stdio.h>
#include <string.h>

#define MAX_LENGTH 1000
#define NAME "-Ivan-"

int main() {
    FILE *file = fopen("inputt.txt", "w");
    if (file == NULL) {
        printf("Failed to create input file.");
        return 1;
    }

    fprintf(file, "this is secret.\n");
    fclose(file);

    file = fopen("inputt.txt", "r");
    if (file == NULL) {
        printf("Failed to open input file.");
        return 1;
    }

    char line[MAX_LENGTH];
    char new_line[MAX_LENGTH];
    while (fgets(line, MAX_LENGTH, file)) {
        int longest_word_length = 0;
        int longest_word_start = -1;
        int word_length = 0;
        int word_start = -1;

        for (int i = 0; i < strlen(line); i++) {
            if (line[i] == ' ' || line[i] == '\n') {
                word_length = i - word_start;
                if (word_length > longest_word_length) {
                    longest_word_length = word_length;
                    longest_word_start = word_start;
                }
                word_start = i + 1;
            }
        }

        if (longest_word_start == -1) {
            continue;
        }

        strncpy(new_line, line, longest_word_start);
        new_line[longest_word_start] = '\0';
        strcat(new_line, NAME);
        strcat(new_line, line + longest_word_start + longest_word_length);
        printf("%s", new_line);
    }

    fclose(file);

    return 0;
}
