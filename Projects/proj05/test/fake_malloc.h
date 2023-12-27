// Need stdlib.h #included before #defines, otherwise the preprocessor expands
// the malloc and calloc prototypes when they're #included later.
#include <stdlib.h>

#define malloc    fakemalloc
#define calloc    fakecalloc
#define realloc   fakerealloc

void *fakemalloc(size_t);
void *fakecalloc(size_t, size_t);
void *fakerealloc(void *, size_t);
