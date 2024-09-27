#include <stdio.h>
#include <math.h>

struct Cone {
    float r; 
    float h; 
};

float obiem(struct Cone c){
    float obiem = (1.0/3.0) * M_PI * c.r * c.r * c.h;
    return obiem;
}
float ploshad(struct Cone c){
    float area = M_PI * c.r * (c.r + sqrt(c.h * c.h + c.r * c.r));
    return area;
}

int main(){
    int N; 
    printf("vvedite chislo conusov: ");
    scanf("%d", &N);

    struct Cone cone[N]; 

    for(int i=0; i<N; i++){
        printf("vvedite radius i visoty conusa %d: ", i+1);
        scanf("%f %f", &cone[i].r, &cone[i].h);
    }

    printf("\n");

    for(int i=0; i<N; i++){
        printf("conus %d:\n", i+1);
        printf("obiem: %.2f\n", obiem(cone[i]));
        printf("ploshad: %.2f\n", ploshad(cone[i]));
        printf("\n");
    }

    return 0;
}