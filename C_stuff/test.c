#include <stdio.h>

int a = 10;
int b = 6;
int *pa = &a;
int *pb = &b;
int **ppa = &pa;
int **ppb = &pb;

int main() {
    pb = 0;
    printf("%d\n", **ppb);
    return 0;
}