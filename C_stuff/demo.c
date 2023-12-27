#include <string.h>
#include <stdio.h>
// #define num = 8
// #define product (a,b) ((a)*(b))

int main() {
    // long a = 2;
    // int b = a;
    // printf("%d\n", b);

    // char a[5];
    // char b[5] = "Hell\0";
    // char *name = "four";
    // char test[] = "hello";
    // printf(strcpy(a, name)); // doesn't work

    // char name[] = {'h','i','\0'};
    // printf("%d",sizeof(name));

    // int (*cat)[5];

    // char a[] = {'H','e','l','l','o','\0'};
    // char b[] = "Hello";
    // int val = strcmp(a, b);
    // printf("%d\n", val);

    // long a = 2147483647;
    // // long a = 2147483647;
    // int b = a;
    // printf("%d\n",b);

    char *str = "Hello";
    // *(str + 2) = 'c';
    str[2] = 'c';
    printf("%s", str);
    return 0;
}
