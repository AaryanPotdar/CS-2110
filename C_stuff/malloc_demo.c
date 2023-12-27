#include <stdio.h>
#include <stdlib.h>

int main () {
    char *str;

   /* Initial memory allocation */
   str = malloc(15);
   printf("Address = %x\n", str);

   /* Reallocating memory */
   str = (char *) realloc(str, 25);
   strcat(str, ".com");
   printf("String = %s,  Address = %u\n", str, str);

   free(str);
   
   return 0;
}