#include <iostream>
#include <cmath>
#include <vector>
#include <iomanip>  // Для форматирования таблицы

using namespace std;

// Функция для вычисления корреляции
double correlation(const vector<int>& x, const vector<int>& y) {
    double sum = 0;
    for (size_t i = 0; i < x.size(); ++i) {
        sum += x[i] * y[i];
    }
    return sum;
}

// Функция для вычисления нормализованной корреляции
double normalizedCorrelation(const vector<int>& x, const vector<int>& y) {
    double xy_sum = 0, x_sum = 0, y_sum = 0;
    for (size_t i = 0; i < x.size(); ++i) {
        xy_sum += x[i] * y[i];
        x_sum += x[i] * x[i];
        y_sum += y[i] * y[i];
    }
    return xy_sum / (sqrt(x_sum) * sqrt(y_sum));
}

int main() {
    // Массивы для 4 варианта
    vector<int> a = {3, 4, 7, 8, 3, -2, -4, 0};
    vector<int> b = {2, 5, 8, 10, 4, -3, -1, 2};
    vector<int> c = {-2, 0, -3, -7, 2, -3, 5, 9};
    
    // Вычисление корреляций
    double corr_ab = correlation(a, b);
    double corr_ac = correlation(a, c);
    double corr_bc = correlation(b, c);
    
    // Вычисление нормализованных корреляций
    double norm_corr_ab = normalizedCorrelation(a, b);
    double norm_corr_ac = normalizedCorrelation(a, c);
    double norm_corr_bc = normalizedCorrelation(b, c);
    
    // Вывод таблицы корреляции
    cout << "\nCorrelation table:\n";
    cout << setw(5) << " " << setw(10) << "a" << setw(10) << "b" << setw(10) << "c" << endl;
    cout << setw(5) << "a" << setw(10) << "-" << setw(10) << corr_ab << setw(10) << corr_ac << endl;
    cout << setw(5) << "b" << setw(10) << corr_ab << setw(10) << "-" << setw(10) << corr_bc << endl;
    cout << setw(5) << "c" << setw(10) << corr_ac << setw(10) << corr_bc << setw(10) << "-" << endl;
    
    // Вывод таблицы нормализованной корреляции
    cout << "\nNormalized Correlation table:\n";
    cout << setw(5) << " " << setw(10) << "a" << setw(10) << "b" << setw(10) << "c" << endl;
    cout << setw(5) << "a" << setw(10) << "-" << setw(10) << norm_corr_ab << setw(10) << norm_corr_ac << endl;
    cout << setw(5) << "b" << setw(10) << norm_corr_ab << setw(10) << "-" << setw(10) << norm_corr_bc << endl;
    cout << setw(5) << "c" << setw(10) << norm_corr_ac << setw(10) << norm_corr_bc << setw(10) << "-" << endl;

    return 0;
}
