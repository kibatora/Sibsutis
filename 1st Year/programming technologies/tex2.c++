#include <iostream>
#include <algorithm>

// Функция удаления элемента из массива
void removeElement(int arr[], int& size, int index) {
    if (index < 0 || index >= size) {
        std::cout << "Неверный индекс элемента для удаления." << std::endl;
        return;
    }

    for (int i = index; i < size - 1; i++) {
        arr[i] = arr[i + 1];
    }

    size--;
}

// Функция поиска индекса минимального элемента в массиве
int findMinIndex(const int arr[], int size) {
    int minIndex = 0;

    for (int i = 1; i < size; i++) {
        if (arr[i] < arr[minIndex]) {
            minIndex = i;
        }
    }

    return minIndex;
}

// Функция поиска индекса максимального элемента в массиве
int findMaxIndex(const int arr[], int size) {
    int maxIndex = 0;

    for (int i = 1; i < size; i++) {
        if (arr[i] > arr[maxIndex]) {
            maxIndex = i;
        }
    }

    return maxIndex;
}

// Функция вычисления среднего арифметического элементов массива
double calculateAverage(const int arr[], int size) {
    if (size == 0) {
        return 0.0;
    }

    int sum = 0;
    for (int i = 0; i < size; i++) {
        sum += arr[i];
    }

    return static_cast<double>(sum) / size;
}

int main() {
    int size;
    std::cout << "Enter the size of the array: ";
    std::cin >> size;

    int* X = new int[size];

    std::cout << "Enter array elements:" << std::endl;
    for (int i = 0; i < size; i++) {
        std::cout << "X[" << i << "]: ";
        std::cin >> X[i];
    }

    int minIndex = findMinIndex(X, size);
    int maxIndex = findMaxIndex(X, size);

    if (minIndex > maxIndex) {
        std::swap(minIndex, maxIndex);
    }

    // Удаление элементов между минимальным и максимальным
    int elementsToRemove = maxIndex - minIndex - 1;
    for (int i = 0; i < elementsToRemove; i++) {
        removeElement(X, size, minIndex + 1);
    }

    // Вычисление среднего арифметического элементов до и после удаления
    double averageBefore = calculateAverage(X, size);
    double averageAfter = calculateAverage(X, size - elementsToRemove);

    std::cout << "Arithmetic mean of elements before removal: " << averageBefore << std::endl;
    std::cout << "Arithmetic mean of elements after deletion: " << averageAfter << std::endl;

    delete[] X;

    return 0;
}
