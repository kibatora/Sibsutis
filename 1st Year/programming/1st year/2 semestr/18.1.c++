#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class MedicalInstitution {
public:
    // поля
    string type;
    string address;

    // конструктор
    MedicalInstitution(string t, string a) : type(t), address(a) {}

    // Способ вывода информации на консоль
    void outputTo() const {
        cout << "Type: " << type << endl;
        cout << "Address: " << address << endl;
    }
};

bool sortByAddress(const MedicalInstitution& a, const MedicalInstitution& b) {
    return a.address < b.address;
}

int main() {
    unsigned int size; // измененный тип переменной i
    cout << "Enter vector size: ";
    cin >> size;

    // Создать вектор объектов медицинского учреждения
    vector<MedicalInstitution> medicalInstitutions;
    for (unsigned int i = 0; i < size; i++) { // измененный тип переменной i
        string type, address;
        cout << "Enter type and address for Medical Institution " << i + 1 << ": ";
        cin >> type >> address;
        medicalInstitutions.emplace_back(type, address);
    }

    // Создайте новый вектор и скопируйте выбранные элементы
    vector<MedicalInstitution> newVector;
    for (unsigned int i = 0; i < medicalInstitutions.size(); i++) { // измененный тип переменной i
        if (medicalInstitutions[i].type == "clinic") {
            newVector.push_back(medicalInstitutions[i]);
        }
    }

    // проверка пуст ли новый вектор
    if (newVector.empty()) {
        cout << "New vector is empty" << endl;
        return 0;
    }

    // Отсортировать новый вектор по адресу
    sort(newVector.begin(), newVector.end(), sortByAddress); // добавлен вызов sort

    // Вывести новый вектор
    cout << "New vector size: " << newVector.size() << endl;
    for (unsigned int i = 0; i < newVector.size(); i++) { // измененный тип переменной i
        newVector[i].outputTo();
    }

    // Найти максимальный адрес в новом векторе
    MedicalInstitution maxAddress = newVector[0];
    for (unsigned int i = 1; i < newVector.size(); i++) { // измененный тип переменной i
        if (newVector[i].address > maxAddress.address) {
            maxAddress = newVector[i];
        }
    }
    cout << "Max address in new vector: " << maxAddress.address << endl;

    return 0;
}
