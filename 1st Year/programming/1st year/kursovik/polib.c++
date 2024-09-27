#include<iostream>
#include<string.h>
using namespace std;

char table[5][5];

string encrypt(string pt) {
    string encpt = "";
    int l = pt.length();
    char encpt1[l+1];
    strcpy(encpt1, pt.c_str());
    for(int i=0; i<l; i++)
        for(int j=0; j<5; j++)
            for(int k=0; k<5; k++)
                if(encpt1[i] == table[j][k]) {
                    char ch = j+48+1;
                    string row(1, ch);
                    encpt = encpt + row;
                    ch = k+48+1;
                    string col(1, ch);
                    encpt = encpt + col;
                }
    return encpt;
}

string decrypt(string encpt) {
    string decpt = "";
    int l = encpt.length();
    char decpt1[l+1];
    strcpy(decpt1, encpt.c_str());
    for(int i=0; i<l; i=i+2) {
        int row, col;
        row = decpt1[i];
        row -= 48;
        col = decpt1[i+1];
        col -= 48;
        string s(1, table[row-1][col-1]);
        decpt = decpt + s;
    }
    return decpt;
}

int main() {
    int num = 65, i=0;
while(num<=90) {
    if(num=='J') {
        num++;
        continue;
    }
    int j = i/5;
    char ch = num;
    table[j][i%5] = ch;
    i++;
    num++;
}
    string pt, encpt, decpt;
    cout<<"Enter plaintext: ";
    getline(cin, pt);
    encpt = encrypt(pt);
    cout<<"Encrypted text: "<<encpt;
    decpt = decrypt(encpt);
    cout<<"\nDecrypted text: "<<decpt;
    return 0;
}
