#include <iostream>
#include <vector>
#include <cmath>
#include <numeric>
#include <algorithm>

using namespace std;

const int REGISTER_SIZE = 5;
const int SEQUENCE_LENGTH = pow(2, REGISTER_SIZE) - 1;

// Генерация М-последовательности
vector<int> generateMSeq(const vector<int>& polynomial, const vector<int>& initial_state) {
    vector<int> register_ = initial_state;
    vector<int> output(SEQUENCE_LENGTH);

    for (int i = 0; i < SEQUENCE_LENGTH; ++i) {
        output[i] = register_.back();
        int feedback = 0;
        for (size_t j = 0; j < polynomial.size(); ++j) {
            if (polynomial[j] == 1) {
                feedback ^= register_[j];
            }
        }
        rotate(register_.begin(), register_.begin() + 1, register_.end());
        register_[0] = feedback;
    }
    return output;
}

// Функция для проверки баланса
bool isBalanced(const vector<int>& sequence) {
    int ones = 0;
    for (int x : sequence) {
        if (x == 1) {
            ones++;
        }
    }
    return abs(ones * 2 - SEQUENCE_LENGTH) <= 1;  // Строгое условие баланса
}


// Функция для вычисления автокорреляции (линейная)
vector<double> autocorrelate(const vector<int>& sequence) {
    vector<double> result(SEQUENCE_LENGTH);
    for (int shift = 0; shift < SEQUENCE_LENGTH; ++shift) {
        double corr = 0;
        for (int i = 0; i < SEQUENCE_LENGTH - shift; ++i) {
            corr += (sequence[i] * 2 - 1) * (sequence[i + shift] * 2 - 1);
        }
        result[shift] = corr / SEQUENCE_LENGTH;
    }
    return result;
}


bool isDeltaLike(const vector<double>& autocorr) {
    for (int shift = 1; shift < SEQUENCE_LENGTH; ++shift) {
        if (fabs(autocorr[shift]) > (1.0 + sqrt(SEQUENCE_LENGTH)) /SEQUENCE_LENGTH ) {  // корректный допуск
            return false;
        }
    }
    return true;
}



double crossCorrelation(const vector<int>& seq1, const vector<int>& seq2) {
    double max_corr = -1.0;

    for (int shift = 0; shift < SEQUENCE_LENGTH; ++shift) {
        double corr = 0;
        for (int i = 0; i < SEQUENCE_LENGTH; ++i) {
            corr += (seq1[i] * 2 - 1) * (seq2[(i + shift) % SEQUENCE_LENGTH] * 2 - 1);
        }
        corr /= SEQUENCE_LENGTH;
        max_corr = max(max_corr, fabs(corr));
    }
    return max_corr;
}

int main() {
    vector<int> polynomial1 = {1, 0, 1, 0, 0, 1}; // x^5 + x^3 + 1
    vector<int> polynomial2 = {1, 1, 1, 0, 1, 1}; // x^5 + x^4 + x^2 + x + 1
    vector<int> initial_state1 = {1, 0, 0, 0, 0};
    vector<int> initial_state2 = {1, 0, 0, 0, 0}; 

    vector<int> preferred_shifts = {5, 15, 17, 24};

    vector<int> mSeq1 = generateMSeq(polynomial1, initial_state1);
    vector<int> mSeq2 = generateMSeq(polynomial2, initial_state2);

    vector<vector<int>> gold_sequences;

    for (int shift : preferred_shifts) {
        vector<int> goldSeq(SEQUENCE_LENGTH);
        for (int i = 0; i < SEQUENCE_LENGTH; ++i) {
            goldSeq[i] = mSeq1[i] ^ mSeq2[(i + shift) % SEQUENCE_LENGTH];
        }

        gold_sequences.push_back(goldSeq);


                cout << "Gold Sequence (shift " << shift << "): ";
        for (int x : goldSeq) cout << x << " ";
        cout << endl;

        cout << "Balanced: " << isBalanced(goldSeq) << endl;


        vector<double> autocorr = autocorrelate(goldSeq);
        cout << "Autocorrelation is delta-like: " << isDeltaLike(autocorr) << endl;

        
        cout << endl;
    }

    for (size_t i = 0; i < gold_sequences.size(); ++i) {
        for (size_t j = i + 1; j < gold_sequences.size(); ++j) {
            double cross_corr = crossCorrelation(gold_sequences[i], gold_sequences[j]);
            cout << "Cross-correlation between Gold Sequence (shift " << preferred_shifts[i] << ") and Gold Sequence (shift " << preferred_shifts[j] << "): " << cross_corr << endl;

        }
    }


    return 0;
}