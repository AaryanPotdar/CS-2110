
#ifndef BINARY_TREE_H
#define BINARY_TREE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define UNUSED(x) ((void)x)
#define ERROR 0
#define SUCCESS 1

typedef struct Node {
    void *data;
    struct Node *left;
    struct Node *right;
} Node;

typedef struct binary_search_tree {
    Node *root;
    int (*comparator)(const void *, const void*); // comparator function - takes in the two data to compare
    void (*destructor)(void *); // destructor - takes in the data pointer
    void (*printer)(FILE *, void *);
    size_t num_nodes;
} binary_search_tree;


// BST functions
binary_search_tree *init_tree(int (*comparator)(const void *, const void*), void (*destructor)(void *),
                                void (*printer)(FILE *f, void *));
Node *create_node(void *data);
int insert_node(binary_search_tree *tree, void *data);
int contains(binary_search_tree *tree, void *data);
void **preorder_traversal(binary_search_tree *tree);
binary_search_tree *duplicate_without(binary_search_tree *tree, void *data_removed);
void destroy_node(void (*destructor)(void *), Node *node, int destroy_data);
void destroy_tree(binary_search_tree *tree, int destroy_data);

void print_tree(FILE *f, binary_search_tree *tree); //Already implemented for you

#endif