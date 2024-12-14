#include "deleteTree.h"

//Function that deletes the under left tree of a tree
void deleteLeft(pTree root){
    if(root!=NULL && root->left!=NULL){
        if(root->left->left!=NULL){
            deleteLeft(root->left);
        }
        if(root->left->right!=NULL){
            deleteRight(root->left);
        }
        free(root->left);
        root->left=NULL;
    }
}

//Function that deletes the under right tree of a tree
void deleteRight(pTree root){
    if(root!=NULL && root->right!=NULL){
        if(root->right->left!=NULL){
            deleteLeft(root->right);
        }
        if(root->right->right!=NULL){
            deleteRight(root->right);
        }
        free(root->right);
        root->right=NULL;
    }
}

//Function that deletes all the tree
void deleteAllTree(pTree *root){
    if(root!=NULL){
        deleteLeft(*root);
        deleteRight(*root);
        free(*root);
        *root=NULL;
    }
}