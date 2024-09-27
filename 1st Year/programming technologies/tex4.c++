#include <string>
#include <iostream>

using namespace std;

class MedicalInstitution {
// Fields
private:
string type;
string address;
// Constructor
public:
MedicalInstitution(string t, string a) {
    type = t;
    address = a;
}

// Methods for getting and setting type
public:
string getType() {
    return type;
}

void setType(string t) {
    type = t;
}

// Methods for getting and setting address
public:
string getAddress() {
    return address;
}

void setAddress(string a) {
    address = a;
}

// Method for outputting information to console
public:
void outputTo() {
    cout << "Type: " << type << endl;
    cout << "Address: " << address << endl;
}

// Main method for testing
public:
static void main() {
    MedicalInstitution pharmacy("apteka", "123 Boris. St.");
    MedicalInstitution clinic("Clinica", "456 Gogoliya St.");
    pharmacy.outputTo();
    clinic.outputTo();
    pharmacy.setType("anestetic-store");
    clinic.setAddress("789 ploshad Pushkina .");
    cout << "apteka type: " << pharmacy.getType() << endl;
    cout << "Clinica address: " << clinic.getAddress() << endl;
    pharmacy.outputTo();
    clinic.outputTo();
}
};

int main() {
MedicalInstitution::main();
return 0;
}