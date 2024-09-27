#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

void print_subset(int subset, int n, int count) {
    printf("%d: {", count);
    for (int i = 0; i < n; i++) {
        if (subset & (1 << i)) {
            printf("%d ", i+1);
        }
    }
    printf("} Subset: {");
    bool first = true;
    for (int i = 0; i < n; i++) {
        if (subset & (1 << i)) {
            if (first) {
                printf("%d", i+1);
                first = false;
            } else {
                printf(",%d", i+1);
            }
        }
    }
    printf("}\n");
}

void generate_subsets(int* set, int n) {
    int total = 1 << n; 
    int subset = 0;
    int count = 0;
    print_subset(subset, n, count);
    count++;

    for (int i = 0; i < total-1; i++) {
        if (i % 2 == 0) {
            subset ^= 1;
        } else {
            int j = 0;
            while ((subset & (1 << j)) != 0) {
                j++;
            }
            subset ^= 1 << j;
        }
        print_subset(subset, n, count);
        count++;
    }
}

int main() {
    int n;
    printf("Enter the cardinality of the set: ");
    scanf("%d", &n);
    int* set = (int*) malloc(n * sizeof(int));
    printf("Enter the elements of the set: ");
    for (int i = 0; i < n; i++) {
        scanf("%d", &set[i]);
    }
    printf("Generating all subsets...\n");
    generate_subsets(set, n);
    free(set);

    return 0;
}
