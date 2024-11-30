#include "insertionAVL.h"

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

void addConsumption(pTree root, int identifier, int consumption){
    if(root!=NULL){
        if(root->station.identifier==identifier){
            root->station.consumption+=consumption;
            return ;
        }
        else if(root->station.identifier<identifier){
            addConsumption(root->right,identifier,consumption);
        }
        else{
            addConsumption(root->left,identifier,consumption);
        }
    }
}