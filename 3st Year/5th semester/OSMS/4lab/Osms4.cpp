#include <iostream>
#include <cmath>
#include <iomanip>
#include <map> // Добавили заголовок map

using namespace std;

//доказать что это реальная n последовательность. Нормализованная корреляция
const int REGISTER_SIZE = 5;

//shift x registers (x^5 + x^4 + 1)
void shiftX(int x[REGISTER_SIZE]){
  int8_t shiftedElement = (x[0] + x[1]) % 2; // x4 и x5 - x[0] и x[1]

  for (int i = 0; i < REGISTER_SIZE; i++){
    x[REGISTER_SIZE - 1 - i] = x[REGISTER_SIZE - 2 - i];
  }
  x[0] = shiftedElement;
}

//shift y registers (x^5 + x^3 + 1)
void shiftY(int y[REGISTER_SIZE]){
  int8_t shiftedElement = (y[2] + y[4]) % 2;  // y2 и y5 - y[2] и y[4]

  for (int i = 0; i < REGISTER_SIZE; i++){
    y[REGISTER_SIZE - 1 - i] = y[REGISTER_SIZE - 2 - i];
  }
  y[0] = shiftedElement;
}

void goldSequence(int x[REGISTER_SIZE], int y[REGISTER_SIZE], 
                  int result[], int length){
  for(int i = 0; i < length; i++){
    result[i] = (x[4] + y[4]) % 2;
    shiftX(x);
    shiftY(y);
  }
}

void shiftElements(int a[], int length){
  int8_t shiftedElement = a[length - 1];

  for (int i = 0; i < length - 1; i++){
    a[length - 1 - i] = a[length - 2 - i];
  }
  a[0] = shiftedElement;
}

void autocorrelation(int sequence[], int length, double result[]) {
  for (int i = 0; i < length+1; i++) {
    int shiftedSequence[length];

    for (int j = 0; j < length; j++) {
      shiftedSequence[j] = sequence[j];
    }

    for (int k = 0; k < i; k++) {
      shiftElements(shiftedSequence, length);
    }

    double correlation = 0;
    for (int j = 0; j < length; j++) {
      correlation += sequence[j] * shiftedSequence[j];
    }

    double sumSqA = 0, sumSqB = 0;
    for (int j = 0; j < length; j++) {
      sumSqA += sequence[j] * sequence[j];
      sumSqB += shiftedSequence[j] * shiftedSequence[j];
    }

    result[i] = correlation / sqrt(sumSqA * sumSqB); 
  }
}

double correlation(int x[], int y[], int length){
    double sum = 0;
    double sumSqX = 0;
    double sumSqY = 0;

    for(int i = 0; i < length; i++){
        sum += x[i] * y[i];
        sumSqX += x[i] * x[i];
        sumSqY += y[i] * y[i];
    }

    return sum / sqrt(sumSqX * sumSqY);
}

void printAutocorrelationTable(int sequence[], int length, double autocorr[]) {
    cout << "\n Shift| sequence ";
    for (int i = 0; i < length; ++i) cout << "  "; // Заполняем пробелами вместо номеров последовательности
    cout << "| Autocorr" << endl;

    for (int shift = 0; shift <= length; ++shift) {
        cout << setw(5) << shift << " | ";
        for (int i = 0; i < length; ++i) {
            cout << sequence[(i + shift) % length] << " ";
        }
        cout << "| " << fixed << setprecision(3) << autocorr[shift] << endl;
    }
     // Проверка на "дельтообразность" автокорреляции
    double maxAutocorr = -1.0;
    for (int shift = 0; shift <= length; ++shift) {
        if (autocorr[shift] > maxAutocorr) {
            maxAutocorr = autocorr[shift];
        }
    }

    bool deltaLike = true;
    for (int shift = 1; shift <= length; ++shift) {
        if (autocorr[shift] > maxAutocorr/3) {  // Можно варьировать порог
            deltaLike = false;
            break;
        }
    }

    if (deltaLike) {
        cout << "Autocorrelation is delta-like." << endl;
    } else {
        cout << "Autocorrelation is NOT delta-like." << endl;
    }
}

void checkBalance(int sequence[], int length) {
    int ones = 0;
    for (int i = 0; i < length; ++i) {
        if (sequence[i] == 1) {
            ones++;
        }
    }
    int zeros = length - ones;
    cout << "Ones: " << ones << ", Zeros: " << zeros << endl;
    if (abs(ones - zeros) <= 1) {
        cout << "Sequence is balanced." << endl;
    } else {
        cout << "Sequence is not balanced." << endl;
    }
}

// Функция для проверки цикличности
void checkCycles(int sequence[], int length) {
    map<int, int> cycleLengths;
    int currentCycleLength = 1;

    for (int i = 1; i < length; ++i) {
        if (sequence[i] == sequence[i - 1]) {
            currentCycleLength++;
        } else {
            cycleLengths[currentCycleLength]++;
            currentCycleLength = 1;
        }
    }
    cycleLengths[currentCycleLength]++; // Последний цикл

    cout << "Cycle Length Distribution:" << endl;
    for (auto const& [length, count] : cycleLengths) {
        cout << "Length " << length << ": " << count << " times" << endl;
    }

     // Проверка примерного соотношения длин циклов (для PN-последовательностей)
    if (cycleLengths.size() > 1) { // Проверяем, есть ли циклы разной длины
        bool approximatelyCorrect = true;

        if (abs(cycleLengths[1] - length / 2.0) > 2) approximatelyCorrect = false; // Примерно половина - длина 1
        if (cycleLengths.count(2) > 0 && abs(cycleLengths[2] - length / 4.0) > 2) approximatelyCorrect = false; // Примерно четверть - длина 2
        if (cycleLengths.count(3) > 0 && abs(cycleLengths[3] - length / 8.0) > 2) approximatelyCorrect = false; // Примерно 1/8 - длина 3

        if (approximatelyCorrect) {
            cout << "The run length distribution is close to what you would expect from a PN sequence" << endl;
        }
        else {
            cout << "The run length distribution is not close to a PN sequence" << endl;
        }

    }

}

int main(){
  int registerX[REGISTER_SIZE] = {0, 0, 1, 0, 0}; // x
  int registerY[REGISTER_SIZE] = {0, 1, 0, 1, 1}; // x + 7

  int registerX1[REGISTER_SIZE] = {0, 0, 1, 0, 1}; // x + 1
  int registerY1[REGISTER_SIZE] = {0, 0, 1, 1, 0}; // y - 5

  int length = pow(2,REGISTER_SIZE) - 1;
  int goldSeq1[length];
  int goldSeq2[length];
  goldSequence(registerX, registerY, goldSeq1, length);
  goldSequence(registerX1, registerY1, goldSeq2, length);

  cout<<"\n\n\n";
  cout << "Gold sequence: ";
  for (int i = 0; i < length; i++)
  {
    cout << goldSeq1[i] << " ";
  }

  double autocorr1[length+1];
  autocorrelation(goldSeq1, length, autocorr1);

  int goldSeq1Shift[length];
  for (int i = 0; i < length; i++) {
    goldSeq1Shift[i] = goldSeq1[i];
        // cout << goldSeq1Shift[i] << " ";
  }
  
  printAutocorrelationTable(goldSeq1, length, autocorr1);

  cout<<"\n\n\n";
  cout << "New gold sequence: ";
  for (int i = 0; i < length; i++)
  {
    cout << goldSeq2[i] << " ";
  }
  
  double autocorr2[length+1];
  autocorrelation(goldSeq2, length, autocorr2);

  printAutocorrelationTable(goldSeq2, length, autocorr2);

 cout<<endl; 
  double result;
  result = correlation(goldSeq1, goldSeq2, length);
  cout << "Gold1 and Gold2 correlation: " <<result << endl;

  checkBalance(goldSeq1, length);
  checkBalance(goldSeq2, length);
  checkCycles(goldSeq1, length);
  checkCycles(goldSeq2, length);
}