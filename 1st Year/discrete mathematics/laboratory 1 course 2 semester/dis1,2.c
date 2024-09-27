#include <stdio.h>

#define MAX_SIZE 100

void printSet(int set[], int size)
{
    printf("{ ");
    for (int i = 0; i < size; i++) {
        printf("%d ", set[i]);
    }
    printf("}\n");
}

int inputSet(int set[])
{
    int n;
    printf("Enter the size of the set: ");
    scanf("%d", &n);

    printf("Enter the elements of the set:\n");
    for (int i = 0; i < n; i++) {
        scanf("%d", &set[i]);
    }

    return n;
}

void entry(int set1[], int set2[], int n1, int n2)
{
    int set3[MAX_SIZE];
    int n3 = 0;

    for (int i = 0; i < n1; i++) {
        for (int j = 0; j < n2; j++) {
            if (set1[i] == set2[j]) {
                set3[n3] = set1[i];
                n3++;
            }
        }
    }

    printf("The entry of the sets is: ");
    printSet(set3, n3);
}

void unionSet(int set1[], int set2[], int n1, int n2)
{
    int set3[MAX_SIZE];
    int n3 = 0;

    for (int i = 0; i < n1; i++) {
        set3[n3] = set1[i];
        n3++;
    }

    for (int i = 0; i < n2; i++) {
        int isDuplicate = 0;
        for (int j = 0; j < n1; j++) {
            if (set2[i] == set1[j]) {
                isDuplicate = 1;
                break;
            }
        }

        if (!isDuplicate) {
            set3[n3] = set2[i];
            n3++;
        }
    }

    printf("The union of the sets is: ");
    printSet(set3, n3);
}

void intersection(int set1[], int set2[], int n1, int n2)
{
    int set3[MAX_SIZE];
    int n3 = 0;

    for (int i = 0; i < n1; i++) {
        for (int j = 0; j < n2; j++) {
            if (set1[i] == set2[j]) {
                set3[n3] = set1[i];
                n3++;
                break;
            }
        }
    }

    printf("The intersection of the sets is: ");
    printSet(set3, n3);
}

void difference(int set1[], int set2[], int n1, int n2)
{
    int set3[MAX_SIZE];
    int n3 = 0;

    for (int i = 0; i < n1; i++) {
        int isDifferent = 1;
        for (int j = 0; j < n2; j++) {
            if (set1[i] == set2[j]) {
                isDifferent = 0;
                break;
            }
        }

        if (isDifferent) {
            set3[n3] = set1[i];
            n3++;
        }
    }

    printf("The difference of the sets is: ");
    printSet(set3, n3);
}
int main()
{
    int set1[MAX_SIZE], set2[MAX_SIZE];
    int n1 = 0, n2 = 0;
    int operation = 0;
    int isExit = 0;

    while (!isExit) {
        printf("Choose an operation:\n");
        printf("1. Entry\n");
        printf("2. Union\n");
        printf("3. Intersection\n");
        printf("4. Difference\n");
        printf("5. Exit\n");

        scanf("%d", &operation);

        switch (operation) {
        case 1:
            printf("Enter the first set:\n");
            n1 = inputSet(set1);

            printf("Enter the second set:\n");
            n2 = inputSet(set2);

            entry(set1, set2, n1, n2);
            break;
        case 2:
            printf("Enter the first set:\n");
            n1 = inputSet(set1);

            printf("Enter the second set:\n");
            n2 = inputSet(set2);

            unionSet(set1, set2, n1, n2);
            break;
        case 3:
            printf("Enter the first set:\n");
            n1 = inputSet(set1);

            printf("Enter the second set:\n");
            n2 = inputSet(set2);

            intersection(set1, set2, n1, n2);
            break;
        case 4:
            printf("Enter the first set:\n");
            n1 = inputSet(set1);

            printf("Enter the second set:\n");
            n2 = inputSet(set2);

            difference(set1, set2, n1, n2);
            break;
        case 5:
            isExit = 1;
            break;
        default:
            printf("Invalid operation\n");
            break;
        }

        if (!isExit) {
            printf("\nPress 1 to choose another operation or 2 to enter new sets, or any other number to exit: ");
            int choice;
            scanf("%d", &choice);

            if (choice == 1) {
                printf("\n");
                continue;
            } else if (choice == 2) {
                n1 = 0;
                n2 = 0;
                printf("\n");
                continue;
            } else {
                break;
            }
        }
    }

    return 0;
}

