#include "station.h"

pTree createTree(Station newStation){
    pTree node=malloc(sizeof(Tree));
    if(node==NULL){
        printf("Erreur d'allocation dynamique !\n");
        exit(1);
    }
    node->station=newStation;
    node->balance=0;
    node->left=NULL;
    node->right=NULL;
    return node;
}