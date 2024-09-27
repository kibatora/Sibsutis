#include <stdio.h>
#include <math.h>

struct Cone {
    double r;
    double h;
};
float masiv(*N){
    int N = 12;
    struct Cone array[N];

    for (int i = 0; i < N; i++) {
        array[i].r = i + 1;
        array[i].h = array[i].r * 1.5;
    }
}


int main() {
    const double PI = 3.14159;
    double *N
    

    double v, s;
    for (int i = 0; i < N; i++) {
        double r2 = pow(array[i].r, 2); 

        v = PI * r2 * array[i].h / 3.0;
        s = (PI * r2) + (PI * array[i].r * sqrt(r2 + pow(array[i].h, 2)));

        printf("konus: radius osnovania: %lf, visota: %lf\n obiem: %lf\n ploshad poverhnosti: %lf\n\n",
            array[i].r, array[i].h, v, s);
    }

    return 0;
}