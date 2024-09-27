#include <iostream>
#include <algorithm>

using namespace std;

int main() {
    int N;
    cout << "Enter the size of the array: ";
    cin >> N;

    int* X = new int[N];
    int* Z = new int[N];
    int min_index, max_index;
    cout << "Enter " << N << " integers: ";
    for (int i = 0; i < N; i++) {
        cin >> X[i];
    }

    min_index = min_element(X, X + N) - X;
    max_index = max_element(X, X + N) - X;

    int j = 0;
    for (int i = 0; i < N; i++) {
        if (i <= min_index || i >= max_index) {
            Z[j] = X[i];
            j++;
        }
    }

    int sum_before = 0, sum_after = 0;
    for (int i = 0; i < N; i++) {
        sum_before += X[i];
    }
    for (int i = 0; i < j; i++) {
        sum_after += Z[i];
    }

    double mean_before = (double) sum_before / N;
    double mean_after = (double) sum_after / j;

    cout << "Array elements before deletion: ";
    for (int i = 0; i < N; i++) {
        cout << X[i] << " ";
    }
    cout << endl;

    cout << "Array elements after deletion: ";
    for (int i = 0; i < j; i++) {
        cout << Z[i] << " ";
    }
    cout << endl;

    cout << "Arithmetic mean before deletion: " << mean_before << endl;
    cout << "Arithmetic mean after deletion: " << mean_after << endl;

    delete[] X;
    delete[] Z;

    return 0;
}