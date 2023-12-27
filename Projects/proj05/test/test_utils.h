#include "../bst.h"

#include <stdbool.h>


/* allow allow setters */
void allow_malloc(void);
void force_malloc_fail(void);
void allow_n_mallocs(int n);
void force_realloc_fail_but_allow_malloc(void);
void force_realloc_and_malloc_fail(void);

enum tree_type { tree_type_int, tree_type_str };

binary_search_tree *H_init_tree(bool destructor, enum tree_type);
void H_destroy_tree(binary_search_tree *tree);
binary_search_tree *H_create_random_tree(void *data, size_t count,
                                         bool *elements_in,
                                         bool destructor,
                                         enum tree_type);
binary_search_tree *H_create_random_tree_and_preorder_traversal(
    int *data, size_t count, bool *elements_in, void **preorder,
    enum tree_type);
binary_search_tree *H_create_prefilled_int_tree(bool dynamic);
int H_get_elements_not_destroyed(void);
void H_setup_destroy_tracker(binary_search_tree *tree);
