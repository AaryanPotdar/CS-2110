#include <stdio.h>
#include <string.h>
struct Person
{
    char name[64];
    int age;
}; // 64+4 = 68 bytes. each char is 1 byte

int main(int argc, char *argv[]) {

    struct Person people[100];

    struct Person *p_person = &people[0]; //p_person points to first person

    int i = 0;
    for (i = 0; i < 100; i++) {
        p_person->age = 0;
        // p_person += sizeof(struct Person); --> wrong
        p_person += 1; // C compiler does the math for you
        // p_person->name[0] = 0; // terminate is as cull character hit
        //need to strcpy to write name;
        char *nameOfP = "Bob";
        strcpy(p_person->name, nameOfP);
        printf("%s\n", p_person->name);
    }

    return 0;
}
