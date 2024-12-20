#include "insertionAVL.h"

//Function that inserts a station in a balanced binary search tree respecting the balance of the nodes
pTree insertAVL(pTree root, Station station, int *h){
    if(root==NULL){
        (*h)=1;
        return createTree(station);
    }
    else if(root->station.identifier>station.identifier){
        root->left=insertAVL(root->left,station,h);
        (*h)=-(*h);
    }
    else if(root->station.identifier<station.identifier){
        root->right=insertAVL(root->right,station,h);
    }
    else{
        (*h)=0;
        //If root->station.identifier is equal to station.identifier then it will add the load to the station contained in the node
        if(root->station.capacity==0){
            root->station.capacity=station.capacity;
        }
        root->station.consumption+=station.consumption;
        return root;
    }
    if((*h)!=0){
        root->balance+=(*h);
        root=balanceAVL(root);
        if(root->balance==0){
            (*h)=0;
        }
        else{
            (*h)=1;
        }
    }
    return root;
}