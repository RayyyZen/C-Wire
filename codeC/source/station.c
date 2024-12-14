#include "station.h"

//Function that creates a tree containing a station given as an argument and returns it
pTree createTree(Station newStation){
    pTree node=malloc(sizeof(Tree));
    if(node==NULL){
        printf("Dynamic allocation error !\n");
        exit(1);
    }
    node->station=newStation;
    node->balance=0;
    node->left=NULL;
    node->right=NULL;
    return node;
}