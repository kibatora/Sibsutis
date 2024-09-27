#include <iostream>
#include <cmath>
using namespace std;

class Quadrilateral {
protected:
    double x1, y1, x2, y2, x3, y3, x4, y4;

public:
    Quadrilateral(double x1_, double y1_, double x2_, double y2_, double x3_, double y3_, double x4_, double y4_) {
        x1 = x1_; y1 = y1_;
        x2 = x2_; y2 = y2_;
        x3 = x3_; y3 = y3_;
        x4 = x4_; y4 = y4_;
    }

    double distance(double x1_, double y1_, double x2_, double y2_) {
        return sqrt(pow(x2_ - x1_, 2) + pow(y2_ - y1_, 2));
    }

    void displayInfo() {
        cout << "Coordinates: (" << x1 << "," << y1 << "), (" << x2 << "," << y2 << "), (" << x3 << "," << y3 << "), (" << x4 << "," << y4 << ")" << endl;
        cout << "Side lengths: " << distance(x1, y1, x2, y2) << ", " << distance(x2, y2, x3, y3) << ", " << distance(x3, y3, x4, y4) << ", " << distance(x4, y4, x1, y1) << endl;
        cout << "Diagonal lengths: " << distance(x1, y1, x3, y3) << ", " << distance(x2, y2, x4, y4) << endl;
        cout << "Perimeter: " << distance(x1, y1, x2, y2) + distance(x2, y2, x3, y3) + distance(x3, y3, x4, y4) + distance(x4, y4, x1, y1) << endl;
        cout << "Area: " << abs((x1*y2 + x2*y3 + x3*y4 + x4*y1) - (y1*x2 + y2*x3 + y3*x4 + y4*x1)) / 2 << endl;
    }
};

class IsoscelesTrapezoid : public Quadrilateral {
public:
    IsoscelesTrapezoid(double x1_, double y1_, double x2_, double y2_, double x3_, double y3_, double x4_, double y4_) : Quadrilateral(x1_, y1_, x2_, y2_, x3_, y3_, x4_, y4_) {
    }

    bool isIsosceles() {
        double topLength = distance(x1, y1, x2, y2);
        double bottomLength = distance(x3, y3, x4, y4);
        double sideLength1 = distance(x1, y1, x4, y4);
        double sideLength2 = distance(x2, y2, x3, y3);
        return (topLength == bottomLength) || (sideLength1 == sideLength2);
}
double getHeight() {
    double topLength = distance(x1, y1, x2, y2);
    double bottomLength = distance(x3, y3, x4, y4);
    double diagonalLength = distance(x1, y1, x3, y3);
    double height = sqrt(pow(diagonalLength, 2) - pow((topLength - bottomLength), 2)) / 2;
    return height;
}

double getArea() {
    double topLength = distance(x1, y1, x2, y2);
    double bottomLength = distance(x3, y3, x4, y4);
    double height = getHeight();
    return ((topLength + bottomLength) / 2) * height;
}
};
int main() {
IsoscelesTrapezoid it(0, 0, 0, 4, 3, 4, 6, 0);
it.displayInfo();
cout << "Isosceles: " << it.isIsosceles() << endl;
cout << "Height: " << it.getHeight() << endl;
cout << "Area: " << it.getArea() << endl;
return 0;
}
