#include <stdarg.h>
#include <stdbool.h>
#include <limits.h>
#include "../bst.h"
#include "../data_lib.h"
//#include "test_utils.c" why do this? -- Rohan
#include "test.h"
#include "test_utils.h"

/* Global struct referring to a string stream to write debugging
 * output to. */
struct {
    FILE *file;
    char *buf;
    size_t size;
} info;

static void setup_info(void)
{
    info.file = open_memstream(&info.buf, &info.size);
    fputs("\n\n", info.file);
}

static void teardown_info(void)
{
    fclose(info.file);
    free(info.buf);
}

/**
 * Assert that cond is true.  If not, print an error message
 * consisting of the contents of info followed by the formatted string
 * specified by fmt and the varargs.
 */
static void assert_with_info(bool cond, const char *fmt, ...)
{
    if (!cond) {
        va_list args;
        va_start(args, fmt);
        vfprintf(info.file, fmt, args);
        va_end(args);

        fputc('\n', info.file);
        fflush(info.file);
        ck_abort_msg("%s", info.buf);
    }
}

static void verify_tree_helper(const Node *node, void **items,
                               size_t count, bool *accounted,
                               void *low_lim, void *high_lim,
                               int (*comparator)(const void*, const void*),
                               void (*printer)(FILE *f, void *))
{
    size_t i;
    for (i=0; i<count; ++i)
        if (node->data == items[i])
            break;
    if (i == count) {
        /* Unknown data found in binary search tree. */
        fputs("Unexpected item ", info.file);
        printer(info.file, node->data);
        fputs(" in binary search tree.", info.file);
        assert_with_info(false, "");
    }
    if (accounted[i]) {
        /* Data is duplicate. */
        fputs("Duplicate item ", info.file);
        printer(info.file, node->data);
        fputs(" in binary search tree.", info.file);
        assert_with_info(false, "");
    }
    accounted[i] = true;
    if (comparator(node->data, low_lim)<0) {
        /* Data lower than low_lim. */
        fputs("Node ", info.file);
        printer(info.file, node->data);
        fputs(" is misplaced (less than ", info.file);
        printer(info.file, low_lim);
        fputs(").", info.file);
        assert_with_info(false, "");
    }
    if (comparator(node->data, high_lim)>0) {
        /* Data higher than high_lim. */
        fputs("Node ", info.file);
        printer(info.file, node->data);
        fputs(" is misplaced (greater than ", info.file);
        printer(info.file, high_lim);
        fputs(").", info.file);
        assert_with_info(false, "");
    }

    if (node->left)
        verify_tree_helper(node->left, items, count, accounted, low_lim,
                           node->data, comparator, printer);
    if (node->right)
        verify_tree_helper(node->right, items, count, accounted, node->data,
                           high_lim, comparator, printer);
}

static void verify_tree(const binary_search_tree *tree, void **items,
                        size_t count, size_t n_present,
                        void *low_lim, void *high_lim)
{
    assert_with_info(n_present==tree->num_nodes,
                     "tree->num_nodes is %zu, expected %zu.",
                     tree->num_nodes, n_present);

    /* Vector of count bools to store whether each element in items
     * was accounted for. */
    bool *accounted = calloc(count, 1);
    ck_assert_ptr_ne(accounted, NULL);

    if (tree->root)
        verify_tree_helper(tree->root, items, count, accounted, low_lim,
                           high_lim, tree->comparator, tree->printer);

    for (size_t i=0; i<count; ++i)
        if (!accounted[i] && items[i]) {
            /* Element i not in tree. */
            fputs("Item ", info.file);
            tree->printer(info.file, items[i]);
            fputs(" not found in binary search tree.", info.file);
            assert_with_info(false, "");
        }

    free(accounted);
}

/**
 * Test init_tree correctly returns NULL on malloc failure.
 */
START_TEST(test_init_tree_malloc_failure)
{
    force_malloc_fail();
    binary_search_tree *tree = init_tree(int_comparator, int_destructor, int_printer);
    ck_assert_msg(!tree, "init_tree() returned %p on malloc failure, expected NULL", (void *) tree);
}
END_TEST

/**
 * Test init_tree with the int virtual functions.
 */
START_TEST(test_init_tree_int)
{
    allow_malloc();
    const char *debug_info = "\n\ntree = init_tree(int_comparator, int_destructor, int_printer)\n";
    binary_search_tree *tree = init_tree(int_comparator, int_destructor, int_printer);
    ck_assert_msg(!tree->root,
                  "%stree->root is %p, expected NULL\n",
                  debug_info, (void *) tree->root);
    ck_assert_msg(tree->comparator==int_comparator,
                  "%stree->comparator != int_comparator\n",
                  debug_info);
    ck_assert_msg(tree->destructor==int_destructor,
                  "%stree->destructor != int_destructor\n",
                  debug_info);
    ck_assert_msg(tree->printer==int_printer,
                  "%stree->printer != int_printer\n",
                  debug_info);
    assert_with_info(!tree->num_nodes, "tree->num_nodes is %zu, expected 0",
                     tree->num_nodes);
    free(tree);
}
END_TEST

/**
 * Test init_tree with the str virtual functions.
 */
START_TEST(test_init_tree_str)
{
    allow_malloc();
    const char *debug_info = "\n\ntree = init_tree(str_comparator, str_destructor, str_printer);\n";
    binary_search_tree *tree = init_tree(&str_comparator, &str_destructor, &str_printer);
    ck_assert_msg(!tree->root,
                  "%stree->root is %p, expected NULL\n",
                  debug_info, (void *) tree->root);
    ck_assert_msg(tree->comparator==str_comparator,
                  "%stree->comparator != str_comparator\n",
                  debug_info);
    ck_assert_msg(tree->destructor==str_destructor,
                  "%stree->destructor != str_destructor\n",
                  debug_info);
    ck_assert_msg(tree->printer==str_printer,
                  "%stree->printer != str_printer\n",
                  debug_info);
    assert_with_info(!tree->num_nodes, "tree->num_nodes is %zu, expected 0",
                     tree->num_nodes);
    free(tree);
}
END_TEST

/**
 * Test create_node correctly returns NULL with NULL data.
 */
START_TEST(test_create_node_null_data)
{
    allow_malloc();
    Node *node = create_node((void *) NULL);
    ck_assert_msg(!node, "create_node() returned %p with NULL data, expected NULL", (void *) node);
}
END_TEST

/**
 * Test create_node correctly returns NULL on malloc failure.
 */
START_TEST(test_create_node_malloc_failure)
{
    force_malloc_fail();
    int x;
    Node *node = create_node((void *) &x);
    ck_assert_msg(!node, "create_node() returned %p on malloc failure, expected NULL", (void *) node);
}
END_TEST

/**
 * Test create_node correctly creates node with int data.
 */
START_TEST(test_create_node)
{
    allow_malloc();
    int x;                      // only needed to get a pointer
    fprintf(info.file, "node = create_node(%p);\n", (void *) &x);
    Node *node = create_node((void *) &x);
    assert_with_info(node, "node is NULL, expected an allocated Node");
    assert_with_info(node->data == &x, "node->data is %p, expected %p",
                     node->data, (void *) &x);
    assert_with_info(!node->left, "node->left is %p, expected NULL",
                     node->left);
    assert_with_info(!node->right, "node->right is %p, expected NULL",
                     node->right);
    free(node);
}
END_TEST

/**
 * Test insert_node correctly returns 0 with NULL tree.
 */
START_TEST(test_insert_node_null_tree)
{
    allow_malloc();
    int x;
    int ret = insert_node((binary_search_tree *) NULL, (void *) &x);
    ck_assert_msg(!ret, "insert_node() returned %d, expected 0", ret);
}
END_TEST

/**
 * Test insert_node correctly returns 0 with NULL data.
 */
START_TEST(test_insert_node_null_data)
{
    allow_malloc();
    binary_search_tree *tree = H_init_tree(false, tree_type_int);
    int ret = insert_node(tree, (void *) NULL);
    ck_assert_msg(!ret, "insert_node() returned %d, expected 0", ret);
    H_destroy_tree(tree);
}
END_TEST

/**
 * Test insert_node correctly returns 0 on create_node failure.
 */
START_TEST(test_insert_node_malloc_failure)
{
    force_malloc_fail();
    int x;
    binary_search_tree *tree = H_init_tree(false, tree_type_int);
    int ret = insert_node(tree, (void *) &x);
    ck_assert_msg(!ret, "insert_node() returned %d, expected 0", ret);
    H_destroy_tree(tree);
}
END_TEST

/**
 * Test insert_node of several elements into BST.
 */
START_TEST(test_insert_node_int)
{
    allow_malloc();
    binary_search_tree *tree = H_init_tree(false, tree_type_int);
    ck_assert_ptr_ne(tree, NULL);

    fputs("Creating empty tree.\n", info.file);

    int items_to_insert[] = { 16, 7, 13, 12, 19, 18, 8, 5, 17, 10 };
    /* Duplicated so that we can see if the student changed an item
     * for some reason */
    int true_items[] = { 16, 7, 13, 12, 19, 18, 8, 5, 17, 10 };
    void *items[ARR_SIZE(items_to_insert)];

    for (size_t i = 0; i < ARR_SIZE(items_to_insert); ++i) {
        items[i] = items_to_insert+i;

        fprintf(info.file, "\nInserting %d into tree.\n",
                items_to_insert[i]);

        int ret = insert_node(tree, items[i]);
        assert_with_info(ret==1, "insert_node returned %d, expected 1.", ret);

        assert_with_info(items_to_insert[i] == true_items[i],
                         "insert_node modified item from %d to %d.",
                         true_items[i], items_to_insert[i]);

        fputs("New state of tree:\n", info.file);
        print_tree(info.file, tree);

        static int int_min = INT_MIN, int_max = INT_MAX;
        verify_tree(tree, items, i+1, i+1, &int_min, &int_max);
    }

    H_destroy_tree(tree);
}
END_TEST

START_TEST(test_insert_node_str)
{
    allow_malloc();
    binary_search_tree *tree = H_init_tree(false, tree_type_str);
    ck_assert_ptr_ne(tree, NULL);

    fputs("Creating empty tree.\n", info.file);

    char *items_to_insert[] = { "The", "quick", "brown", "fox", "jumped",
                                "over", "the", "lazy", "dog" };
    /* Duplicated so that we can see if the student changed an item
     * for some reason */
    char *true_items[] = { "The", "quick", "brown", "fox", "jumped",
                           "over", "the", "lazy", "dog" };
    void *items[ARR_SIZE(items_to_insert)];

    for (size_t i = 0; i < ARR_SIZE(items_to_insert); ++i) {
        items[i] = items_to_insert[i];

        fprintf(info.file, "\nInserting \"%s\" into tree.\n",
                items_to_insert[i]);

        int ret = insert_node(tree, items[i]);
        assert_with_info(ret==1, "insert_node returned %d, expected 1.", ret);

        assert_with_info(items_to_insert[i] == true_items[i],
                         "insert_node modified item from \"%s\" to \"%s\".",
                         true_items[i], items_to_insert[i]);

        fputs("New state of tree:\n", info.file);
        print_tree(info.file, tree);

        static char *str_min = "", *str_max = "\177";
        verify_tree(tree, items, i+1, i+1, str_min, str_max);
    }

    H_destroy_tree(tree);
}
END_TEST

/**
 * Test insert_node of duplicate data fails.
 */
START_TEST(test_insert_node_duplicate_data_int)
{
    allow_malloc();
    binary_search_tree *tree = H_create_prefilled_int_tree(false);
    ck_assert_ptr_ne(tree, NULL);

    fputs("Using tree:\n", info.file);
    print_tree(info.file, tree);

    int duplicate_data = 15;

    fprintf(info.file, "\n Inserting %d (duplicate data) into tree.\n", duplicate_data);

    int ret = insert_node(tree, (void *) &duplicate_data);

    ck_assert_msg(!ret, "insert_node() returned %d, expected 0", ret);

    H_destroy_tree(tree);
}
END_TEST

/**
 * Test contains correctly returns 0 with NULL tree.
 */
START_TEST(test_contains_null_tree)
{
    allow_malloc();
    int x;
    int ret = contains((binary_search_tree *) NULL, (void *) &x);
    ck_assert_msg(!ret, "contains() returned %d, expected 0", ret);
}
END_TEST

/**
 * Test contains correctly returns 0 with NULL data.
 */
START_TEST(test_contains_null_data)
{
    allow_malloc();
    binary_search_tree *tree = H_init_tree(false, tree_type_int);
    int ret = contains(tree, (void *) NULL);
    ck_assert_msg(!ret, "contains() returned %d, expected 0", ret);
    H_destroy_tree(tree);
}
END_TEST

/*
 * Test contains of several elements into BST.
 */
START_TEST(test_contains_int)
{
    allow_malloc();
    int data[] = { 11, 1, 10, 2, 13, 19, 8, 12, 16, 3, 15, 0, 6, 18, 14, 4, 5,
                   17, 7, 9 };
    bool elements_in[ARR_SIZE(data)] = { 0 };
    binary_search_tree *tree = H_create_random_tree(data, ARR_SIZE(data),
                                                    elements_in, false,
                                                    tree_type_int);
    ck_assert_ptr_ne(tree, NULL);

    fputs("Using tree:\n", info.file);
    print_tree(info.file, tree);

    int data_copy[ARR_SIZE(data)];
    memcpy(data_copy, data, sizeof data);
    for (size_t i=0; i<ARR_SIZE(data); ++i) {
        fprintf(info.file, "Checking whether %d is in tree.\n", data[i]);
        int ret = contains(tree, data_copy+i);
        assert_with_info(ret==elements_in[i],
                         "contains() returned %d (=> %d%s in tree),\n"
                         "           expected %d (=> %d%s in tree).",
                         ret, data[i], ret?"":" not",
                         elements_in[i], data[i], elements_in[i]?"":" not");
    }

    H_destroy_tree(tree);
}
END_TEST

START_TEST(test_contains_str)
{
    allow_malloc();
    char *data[] = { "One", "morning,", "when", "Gregor", "Samsa", "woke",
                     "from", "troubled", "dreams,", "he", "found", "himself",
                     "transformed", "in", "his", "bed", "into", "a", "horrible",
                     "vermin." };
    bool elements_in[ARR_SIZE(data)] = { 0 };
    binary_search_tree *tree = H_create_random_tree(data, ARR_SIZE(data),
                                                    elements_in, false,
                                                    tree_type_str);
    ck_assert_ptr_ne(tree, NULL);

    fputs("Using tree:\n", info.file);
    print_tree(info.file, tree);

    for (size_t i=0; i<ARR_SIZE(data); ++i) {
        fprintf(info.file, "Checking whether \"%s\" is in tree.\n", data[i]);
        char *dup = strdup(data[i]);
        int ret = contains(tree, dup);
        free(dup);
        assert_with_info(ret==elements_in[i],
                         "contains() returned %d (=> \"%s\"%s in tree),\n"
                         "           expected %d (=> \"%s\"%s in tree).",
                         ret, data[i], ret?"":" not",
                         elements_in[i], data[i], elements_in[i]?"":" not");
    }

    H_destroy_tree(tree);
}
END_TEST

/**
 * Test preorder_traversal correctly returns NULL with NULL tree.
 */
START_TEST(test_preorder_traversal_null_tree)
{
    allow_malloc();
    void **preorder = preorder_traversal((binary_search_tree *) NULL);
    ck_assert_msg(!preorder, "preorder_traversal() returned %p with NULL tree, expected NULL", (void *) preorder);
}
END_TEST

/**
 * Test preorder_traversal correctly returns NULL on malloc failure.
 */
START_TEST(test_preorder_traversal_malloc_failure)
{
    force_malloc_fail();
    binary_search_tree *tree = H_init_tree(false, tree_type_int);
    void **preorder = preorder_traversal(tree);
    ck_assert_msg(!preorder, "preorder_traversal() returned %p on malloc failure, expected NULL", (void *) preorder);
    H_destroy_tree(tree);
}
END_TEST

/*
 * Test preorder_traversal for a BST.
 */
START_TEST(test_preorder_traversal)
{
    allow_malloc();
    int data[] = { 15, 19, 17, 4, 12, 11, 5, 14, 7, 6, 18, 0, 3, 8, 16, 9, 1, 2,
                   10, 13 };
    bool elements_in[ARR_SIZE(data)] = { 0 };
    void *preorder[ARR_SIZE(data)];
    binary_search_tree *tree = H_create_random_tree_and_preorder_traversal(
        data, ARR_SIZE(data), elements_in, preorder, tree_type_int);

    fputs("Using tree:\n", info.file);
    print_tree(info.file, tree);
    fputs("Running preorder traversal on tree.\n", info.file);
    void **actual_preorder = preorder_traversal(tree);

    fputs("Expecting preorder traversal:\n", info.file);
    for (size_t i=0; i<tree->num_nodes; ++i)
        fprintf(info.file, "%d ", *(int *)preorder[i]);

    fputs("\nActual preorder traversal:\n", info.file);
    for (size_t i=0; i<tree->num_nodes; ++i)
        fprintf(info.file, "%d ", *(int *)actual_preorder[i]);

    fputc('\n', info.file);
    for (size_t i=0; i<tree->num_nodes; ++i)
        assert_with_info(preorder[i]==actual_preorder[i],
                         "Elements at index %zu do not match.", i);

    free(actual_preorder);
    H_destroy_tree(tree);
}
END_TEST

/**
 * Test duplicate_without correctly returns NULL with NULL tree.
 */
START_TEST(test_duplicate_without_null_tree)
{
    allow_malloc();
    int x;
    binary_search_tree *ret_tree = duplicate_without((binary_search_tree *) NULL, (void *) &x);
    ck_assert_msg(!ret_tree, "duplicate_without() returned %p with NULL tree, expected NULL", (void *) ret_tree);
}
END_TEST

/**
 * Test duplicate_without correctly returns NULL with NULL data_removed.
 */
START_TEST(test_duplicate_without_null_data_removed)
{
    allow_malloc();
    binary_search_tree *tree = H_init_tree(false, tree_type_int);
    binary_search_tree *ret_tree = duplicate_without(tree, (void *) NULL);
    ck_assert_msg(!ret_tree, "duplicate_without() returned %p with NULL data_removed, expected NULL", (void *) ret_tree);
    H_destroy_tree(tree);
}
END_TEST

START_TEST(test_duplicate_without_malloc_failure)
{
    // At least 3 mallocs are needed
    binary_search_tree *tree = H_create_prefilled_int_tree(false);
    force_malloc_fail();
    int x=0;
    binary_search_tree *ret_tree = duplicate_without(tree, &x);
    ck_assert_msg(!ret_tree, "duplicate_without() returned %p on malloc failure,"
                  " expected NULL", (void *) ret_tree);

    allow_n_mallocs(1);
    ret_tree = duplicate_without(tree, &x);
    ck_assert_msg(!ret_tree, "duplicate_without() returned %p on malloc failure,"
                  " expected NULL", (void *) ret_tree);

    allow_n_mallocs(2);
    ret_tree = duplicate_without(tree, &x);
    ck_assert_msg(!ret_tree, "duplicate_without() returned %p on malloc failure,"
                  " expected NULL", (void *) ret_tree);
    H_destroy_tree(tree);
}
END_TEST

START_TEST(test_duplicate_without_not_present)
{
    allow_malloc();
    int data[] = {19, 15, 8, 7, 5, 1, 14, 6, 9, 10, 13, 18, 4, 16, 3, 12, 11, 2,
                  17, 0};
    bool elements_in[ARR_SIZE(data)];
    binary_search_tree *tree = H_create_random_tree(data, ARR_SIZE(data),
                                                    elements_in, false,
                                                    tree_type_int);

    /* Find element not in tree to remove. */
    size_t remove_index = rand()%ARR_SIZE(data);
    while (elements_in[remove_index])
        remove_index = (remove_index+1) % ARR_SIZE(data);

    fputs("Using tree:\n", info.file);
    print_tree(info.file, tree);

    fprintf(info.file, "\nDuplicating tree without %d.\n", data[remove_index]);
    int to_remove = data[remove_index];
    binary_search_tree *ret = duplicate_without(tree, &to_remove);

    assert_with_info(!ret, "duplicate_without() returned %p, expected NULL",
                     ret);

    H_destroy_tree(tree);
}
END_TEST

START_TEST(test_duplicate_without_int)
{
    allow_malloc();
    int data[] = {19, 15, 8, 7, 5, 1, 14, 6, 9, 10, 13, 18, 4, 16, 3, 12, 11, 2,
                  17, 0};
    bool elements_in[ARR_SIZE(data)];
    binary_search_tree *tree = H_create_random_tree(data, ARR_SIZE(data),
                                                    elements_in, false,
                                                    tree_type_int);
    ck_assert_ptr_ne(tree, NULL);

    /* Find element in tree to remove. */
    size_t remove_index = rand()%ARR_SIZE(data);
    while (!elements_in[remove_index])
        remove_index = (remove_index+1) % ARR_SIZE(data);

    fputs("Using tree:\n", info.file);
    print_tree(info.file, tree);

    int (*old_comparator)(const void *, const void *) = tree->comparator;
    void (*old_destructor)(void *) = tree->destructor;
    void (*old_printer)(FILE *f, void *) = tree->printer;

    fprintf(info.file, "Duplicating tree without %d.\n", data[remove_index]);
    int to_remove = data[remove_index];
    size_t orig_size = tree->num_nodes;
    tree = duplicate_without(tree, &to_remove);

    assert_with_info(tree, "duplicate_without() returned NULL, expected an "
                     "allocated binary_search_tree");

    assert_with_info(tree->comparator==old_comparator,
                     "Duplicated tree's comparator does not match "
                     "original tree's comparator.");
    assert_with_info(tree->destructor==old_destructor,
                     "Duplicated tree's destructor does not match "
                     "original tree's destructor.");
    assert_with_info(tree->printer==old_printer,
                     "Duplicated tree's printer does not match "
                     "original tree's printer.");

    fputs("New tree:\n", info.file);
    print_tree(info.file, tree);

    void *item_ptrs[ARR_SIZE(data)];
    for (size_t i = 0; i < ARR_SIZE(data); ++i)
        item_ptrs[i] = (!elements_in[i] || i==remove_index) ? NULL : data+i;
    static int int_min = INT_MIN, int_max = INT_MAX;
    verify_tree(tree, item_ptrs, ARR_SIZE(data), orig_size-1, &int_min,
                &int_max);

    H_destroy_tree(tree);
}
END_TEST

START_TEST(test_duplicate_without_str)
{
    allow_malloc();
    char *data[] = { "One", "morning,", "when", "Gregor", "Samsa", "woke",
                     "from", "troubled", "dreams,", "he", "found", "himself",
                     "transformed", "in", "his", "bed", "into", "a", "horrible",
                     "vermin." };
    bool elements_in[ARR_SIZE(data)] = { 0 };
    binary_search_tree *tree = H_create_random_tree(data, ARR_SIZE(data),
                                                    elements_in, false,
                                                    tree_type_str);
    ck_assert_ptr_ne(tree, NULL);

    /* Find element in tree to remove. */
    size_t remove_index = rand()%ARR_SIZE(data);
    while (!elements_in[remove_index])
        remove_index = (remove_index+1) % ARR_SIZE(data);

    fputs("Using tree:\n", info.file);
    print_tree(info.file, tree);

    int (*old_comparator)(const void *, const void *) = tree->comparator;
    void (*old_destructor)(void *) = tree->destructor;
    void (*old_printer)(FILE *f, void *) = tree->printer;

    fprintf(info.file, "Duplicating tree without \"%s\".\n", data[remove_index]);
    char *to_remove = strdup(data[remove_index]);
    size_t orig_size = tree->num_nodes;
    tree = duplicate_without(tree, to_remove);
    free(to_remove);

    assert_with_info(tree, "duplicate_without() returned NULL, expected an "
                     "allocated binary_search_tree");

    assert_with_info(tree->comparator==old_comparator,
                     "Duplicated tree's comparator does not match "
                     "original tree's comparator.");
    assert_with_info(tree->destructor==old_destructor,
                     "Duplicated tree's destructor does not match "
                     "original tree's destructor.");
    assert_with_info(tree->printer==old_printer,
                     "Duplicated tree's printer does not match "
                     "original tree's printer.");

    fputs("New tree:\n", info.file);
    print_tree(info.file, tree);

    void *item_ptrs[ARR_SIZE(data)];
    for (size_t i = 0; i < ARR_SIZE(data); ++i)
        item_ptrs[i] = (!elements_in[i] || i==remove_index) ? NULL : data[i];
    static char *str_min = "", *str_max = "\177";
    verify_tree(tree, item_ptrs, ARR_SIZE(data), orig_size-1, str_min,
                str_max);

    H_destroy_tree(tree);
}
END_TEST

/*
 * Test destroy_tree that doesn't destroy data.
 */
START_TEST(test_destroy_tree_not_data)
{
    allow_malloc();
    /* This tree did not dynamically allocate its elements, so they
     * should not be freed. */
    binary_search_tree *tree = H_create_prefilled_int_tree(false);
    destroy_tree(tree, 0);
}
END_TEST

/*
 * Test destroy_tree that destroys data.
 */
START_TEST(test_destroy_tree_and_data)
{
    allow_malloc();
    /* This tree did dynamically allocate its elements, so they should
     * be freed. */
    binary_search_tree *tree = H_create_prefilled_int_tree(true);
    H_setup_destroy_tracker(tree);
    fputs("Using tree:\n", info.file);
    print_tree(info.file, tree);
    fputs("Destroying tree.\n", info.file);
    destroy_tree(tree, 1);
    assert_with_info(!H_get_elements_not_destroyed(), "%d nodes not destroyed.",
                     H_get_elements_not_destroyed());
}
END_TEST

/* create test suite */
Suite *bst_suite(void)
{
    Suite *s = suite_create("BST");

    tcase_add (s, setup_info, teardown_info, test_init_tree_malloc_failure);
    tcase_add (s, setup_info, teardown_info, test_init_tree_int);
    tcase_add (s, setup_info, teardown_info, test_init_tree_str);

    tcase_add (s, setup_info, teardown_info, test_create_node_null_data);
    tcase_add (s, setup_info, teardown_info, test_create_node_malloc_failure);
    tcase_add (s, setup_info, teardown_info, test_create_node);

    tcase_add (s, setup_info, teardown_info, test_insert_node_null_tree);
    tcase_add (s, setup_info, teardown_info, test_insert_node_null_data);
    tcase_add (s, setup_info, teardown_info, test_insert_node_malloc_failure);
    tcase_add (s, setup_info, teardown_info, test_insert_node_int);
    tcase_add (s, setup_info, teardown_info, test_insert_node_str);
    tcase_add (s, setup_info, teardown_info, test_insert_node_duplicate_data_int);

    tcase_add (s, setup_info, teardown_info, test_contains_null_tree);
    tcase_add (s, setup_info, teardown_info, test_contains_null_data);
    tcase_add (s, setup_info, teardown_info, test_contains_int);
    tcase_add (s, setup_info, teardown_info, test_contains_str);

    tcase_add (s, setup_info, teardown_info, test_preorder_traversal_null_tree);
    tcase_add (s, setup_info, teardown_info, test_preorder_traversal_malloc_failure);
    tcase_add (s, setup_info, teardown_info, test_preorder_traversal);

    tcase_add (s, setup_info, teardown_info, test_duplicate_without_null_tree);
    tcase_add (s, setup_info, teardown_info, test_duplicate_without_null_data_removed);
    tcase_add (s, setup_info, teardown_info, test_duplicate_without_malloc_failure);
    tcase_add (s, setup_info, teardown_info, test_duplicate_without_not_present);
    tcase_add (s, setup_info, teardown_info, test_duplicate_without_int);
    tcase_add (s, setup_info, teardown_info, test_duplicate_without_str);

    tcase_add (s, setup_info, teardown_info, test_destroy_tree_not_data);
    tcase_add (s, setup_info, teardown_info, test_destroy_tree_and_data);

    return s;
}
