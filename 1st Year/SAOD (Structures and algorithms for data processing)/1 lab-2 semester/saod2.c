#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

int getrand (int min, int max) {
return (double)rand() / (RAND_MAX + 1.0) * (max - min) + min;
}

void counting_sort(uint32_t *array, int n) {
uint32_t max = array[0], min = array[0];
for (int i = 1; i < n; i++) {
if (array[i] > max) max = array[i];
if (array[i] < min) min = array[i];
}
uint32_t range = max - min + 1;
uint32_t *count = calloc(range, sizeof(uint32_t));
for (int i = 0; i < n; i++) count[array[i] - min]++;
for (int i = 1; i < range; i++) count[i] += count[i - 1];
uint32_t *output = malloc(n * sizeof(uint32_t));
for (int i = n - 1; i >= 0; i--) {
output[count[array[i] - min] - 1] = array[i];
count[array[i] - min]--;
}
for (int i = 0; i < n; i++) array[i] = output[i];
free(count);
free(output);
}

void bubble_sort(uint32_t *array, int n) {
for (int i = 0; i < n - 1; i++) {
for (int j = 0; j < n - 1 - i; j++) {
if (array[j] > array[j + 1]) {
uint32_t tmp = array[j];
array[j] = array[j + 1];
array[j + 1] = tmp;
}
}
}
}

int partition(uint32_t *array, int low, int high) {
    uint32_t pivot = array[high];
    int i = low - 1;
    for (int j = low; j <= high - 1; j++) {
        if (array[j] < pivot) {
            i++;
            uint32_t temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
    }
    uint32_t temp = array[i + 1];
    array[i + 1] = array[high];
    array[high] = temp;
    return i + 1;
}

void quick_sort(uint32_t *array, int low, int high) {
    if (low < high) {
        int pi = partition(array, low, high);
        quick_sort(array, low, pi - 1);
        quick_sort(array, pi + 1, high);
    }
}

int main() {
int sizes[] = {50000, 100000, 150000, 200000, 250000, 300000, 350000, 400000, 450000, 500000, 550000, 600000, 650000, 700000, 750000, 800000, 850000, 900000, 950000, 1000000};
int num_sizes = sizeof(sizes) / sizeof(int);
uint32_t *array;
clock_t start, end;
double cpu_time_used;
for (int i = 0; i < num_sizes; i++) {
int n = sizes[i];
array = malloc(n * sizeof(uint32_t));

for (int j = 0; j < n; j++) {
array[j] = getrand(0, n);
}

start = clock();
counting_sort(array, n);
end = clock();
cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
printf("Counting Sort: %d elements sorted in %f seconds\n", n, cpu_time_used);

// start = clock();
// bubble_sort(array, n);
// end = clock();
// cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
// printf("Bubble Sort: %d elements sorted in %f seconds\n", n, cpu_time_used);

start = clock();
quick_sort(array, 0, n - 1);
end = clock();
cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
printf("Quick Sort: %d elements sorted in %f seconds\n", n, cpu_time_used);

free(array);
}
return 0;
}