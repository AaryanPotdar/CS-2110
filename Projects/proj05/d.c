#include <stdio.h>

int main() {
    // char *ptr1 = (char *) 0x401E;
    // char *ptr2 = (char *) 0x4009;
    // char *ptr3 = (char *) (int *) 0x4005 + 2;
    // char *ptr4 = (char *) ((short *) ptr2 + 3);

    // int a = sizeof();

    // printf("%d\n", a);

    struct Student {
        char letter;
        char name[20];
        int age;
    };

    struct Student delulu;
    delulu.letter = 'A';
    *(delulu.name) = 'B';

    printf("%c\n", delulu.letter);
    printf("%c\n", delulu.name[0]);
}