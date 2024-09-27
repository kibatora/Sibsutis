#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SIZE 10

void swap(char *x, char *y)
{
    char temp = *x;
    *x = *y;
    *y = temp;
}

void reverse(char *str, int start, int end)
{
    while (start < end)
    {
        swap(&str[start], &str[end]);
        start++;
        end--;
    }
}

int next_permutation(char *str, int n)
{
    int i, j;
    for (i = n - 2; i >= 0; i--)
    {
        if (str[i] < str[i + 1])
        {
            break;
        }
    }
    if (i < 0)
    {
        return 0;
    }
    for (j = n - 1; j > i; j--)
    {
        if (str[j] > str[i])
        {
            break;
        }
    }
    swap(&str[i], &str[j]);
    reverse(str, i + 1, n - 1);
    return 1;
}

int factorial(int n)
{
    int i, result = 1;
    for (i = 2; i <= n; i++)
    {
        result *= i;
    }
    return result;
}

int main()
{
    char set[MAX_SIZE];
    int n, i, j, count = 0, limit = 20;
    int choice;
    printf("Enter a set of up to 10 distinct characters: ");
    scanf("%s", set);
    n = strlen(set);
    for (i = 0; i < n; i++)
    {
        for (j = i + 1; j < n; j++)
        {
            if (set[i] == set[j])
            {
                printf("Error: The set contains repeating elements.\n");
                return 1;
            }
        }
    }
    printf("The set entered is: %s\n", set);
    printf("The number of distinct elements in the set is: %d\n", n);
    printf("The number of permutations of the set is: %d\n", factorial(n));
    printf("Choose the starting point of the ordering of sets:\n");
    printf("1. Minimum set (ascending order)\n");
    printf("2. User-defined set\n");
    printf("Enter your choice: ");
    scanf("%d", &choice);
    if (choice == 1)
    {
        // Use the minimum set as the starting point
        for (i = 0; i < n; i++)
        {
            for (j = i + 1; j < n; j++)
            {
                if (set[i] > set[j])
                {
                    swap(&set[i], &set[j]);
                }
            }
        }
    }
    else if (choice == 2)
    {
        // Use the user-defined set as the starting point
        printf("Enter a set in the order you want to start with: ");
        scanf("%s", set);
        n = strlen(set);
    }
    else
    {
        printf("Error: Invalid choice.\n");
        return 1;
    }
    if (factorial(n) > limit)
    {
        FILE *fp = fopen("permutations.txt", "w");
        if (fp == NULL)
        {
            printf("Error: Could not open file.\n");
            return 1;
        }
        do
        {
            fprintf(fp, "%s\n", set);
            count++;
        } while (next_permutation(set, n) && count < limit);
        fclose(fp);
        printf("There are too many permutations to display on the screen.\n");
        printf("The first %d permutations have been saved to the file 'permutations.txt'.\n", limit);
        printf("Press any key to exit.\n");
        getchar();
        getchar();
    }
    else
    {
        do
        {
            printf("%s\n", set);
            count++;
        } while (next_permutation(set, n));
        printf("There are %d permutations in total.\n", count);
        printf("Press any key to exit.\n");
        getchar();
        getchar();
    }
    return 0;
}
