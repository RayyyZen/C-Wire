#ifndef STATION_H
#define STATION_H

#include "library.h"

typedef struct{
    int identifier;//The identifier of the station which is unique
    long int capacity;//The capacity of the station in kwh
    long int consumption;//The sum of the consumption of all the consumers directly connected to the station in kwh
}Station;

typedef struct tree{
    Station station;//The station contained in the node
    int balance;//The balance of the node
    struct tree* left;//The left child of the node
    struct tree* right;//The right child of the node
}Tree;

typedef Tree* pTree;

pTree createTree(Station station);

#endif