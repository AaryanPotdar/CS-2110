#include "data_lib.h"

/************************************************************
 ********************* COMPARATORS **************************
************************************************************/

/*
 Integer comaprator - provided
 Returns 0 if a == b
 Returns -ve if a<b
 Returns +ve if a>b
*/
int int_comparator(const void *a, const void *b) {
    return *(int *)a - *(int *)b;
}

int double_comparator(const void *a, const void *b) {
    return *(double *)a - *(double *)b;
}

int str_comparator(const void *a, const void *b) {
    return strcmp((const char*)a, (const char *)b);
}

int person_comparator(const void *a, const void *b) {
    Person* p1 = (Person *)a;
    Person* p2 = (Person *)b;
    if (p1->age != p2->age) {
        return p1->age - p2->age;
    } else {
        return strcmp(p1->name, p2->name);
    }
}



/************************************************************
 ********************* DESTRUCTORS **************************
************************************************************/
void int_destructor(void *data) {
    free((int *)data);
}

void double_destructor(void *data) {
    free((double *)data);
}

void str_destructor(void *data) {
    free((char *)data);
}

void person_destructor(void *data) {
    free((char *) ((Person*) data)->name);
    free((Person*) data);
}


/************************************************************
 ********************** PRINTERS ***************************
************************************************************/

void int_printer(FILE *f, void *data) {
    fprintf(f, "%d", *(int*)data);
}

void double_printer(FILE *f, void *data) {
    fprintf(f, "%f", *(double*)data);
}

void str_printer(FILE *f, void *data) {
    fprintf(f, "%s", (char*)data);
}

void person_printer(FILE *f, void *data) {
    fprintf(f, "%s is %d years old.", (char*)((Person*)data)->name, (int)((Person*)data)->age);
}
