#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int NegativeNumbers(int* mas, int size) 
{
    if (size == 0) { 
        return 0;
    }else {
    int count = NegativeNumbers(mas, size - 1); 
        if (mas[size - 1] < 0) { 
            count++; 
        }
        return count;
}
}

int main()
{
    int i, n, *mas;
    printf("massive razmer: ");
    scanf("%d", &n);
    srand(time(0));
    mas = malloc(n * sizeof(int));
    printf("massive:\n");
    for (i = 0; i < n; i++) {
        mas[i] = 67 - rand() % 100; 
        printf("%d ", mas[i]);
    }
    printf("\n otriz = %d\n",
        NegativeNumbers(mas, n));
    return 0;
}