#include "balancingAVL.h"

int max2(int number1, int number2){
    return number1>number2 ? number1 : number2;
}

int max3(int number1, int number2, int number3){
    return max2(max2(number1,number2),max2(number2,number3));
}

int min2(int number1, int number2){
    return number1<number2 ? number1 : number2;
}

int min3(int number1, int number2, int number3){
    return min2(min2(number1,number2),min2(number2,number3));
}

pTree rightRotation(pTree node){
    if(node==NULL || node->left==NULL){
        return node;
    }
    pTree pivot=node->left;
    node->left=pivot->right;
    pivot->right=node;
    int balance_node=node->balance;
    int balance_pivot=pivot->balance;
    node->balance=balance_node-min2(balance_pivot,0)+1;
    pivot->balance=max3(balance_node+2,balance_node+balance_pivot+2,balance_pivot+1);
    return pivot;
}

pTree leftRotation(pTree node){
    if(node==NULL || node->right==NULL){
        return node;
    }
    pTree pivot=node->right;
    node->right=pivot->left;
    pivot->left=node;
    int balance_node=node->balance;
    int balance_pivot=pivot->balance;
    node->balance=balance_node-max2(balance_pivot,0)-1;
    pivot->balance=min3(balance_node-2,balance_node+balance_pivot-2,balance_pivot-1);
    return pivot;
}

pTree doubleLeftRotation(pTree node){
    if(node==NULL){
        return node;
    }
    node->right=rightRotation(node->right);
    return leftRotation(node);
}

pTree doubleRightRotation(pTree node){
    if(node==NULL){
        return node;
    }
    node->left=leftRotation(node->left);
    return rightRotation(node);
}

pTree balanceAVL(pTree node){
    if(node==NULL){
        return NULL;
    }
    if(node->balance>=2){
        if(node->right->balance>=0){
            return leftRotation(node);
        }
        else{
            return doubleLeftRotation(node);
        }
    }
    else if(node->balance<=-2){
        if(node->left->balance<=0){
            return rightRotation(node);
        }
        else{
            return doubleRightRotation(node);
        }
    }
    return node;
}