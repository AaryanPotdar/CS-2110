#ifndef DATA_LIB_H
#define DATA_LIB_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Person {
    char *name;
    int age;
} Person;

// Comparators
int int_comparator(const void *a, const void *b);
int double_comparator(const void *a, const void *b);
int str_comparator(const void *a, const void *b);
int person_comparator(const void *a, const void *b);


//Destructors
void int_destructor(void *data);
void double_destructor(void *data);
void str_destructor(void *data);
void person_destructor(void *data);

//Printers
void int_printer(FILE *f, void *data);
void double_printer(FILE *f, void *data);
void str_printer(FILE *f, void *data);
void person_printer(FILE *f, void *data);


#endif
