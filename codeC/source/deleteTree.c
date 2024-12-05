#include "deleteTree.h"

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

void deleteAllTree(pTree *root){
    if(root!=NULL){
        deleteLeft(*root);
        deleteRight(*root);
        free(*root);
        *root=NULL;
    }
}