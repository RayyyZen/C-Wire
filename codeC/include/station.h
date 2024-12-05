#ifndef STATION_H
#define STATION_H

#include "library.h"

typedef struct{
    int identifier;
    long int capacity;
    long int consumption;
}Station;

typedef struct tree{
    Station station;
    int balance;
    struct tree* left;
    struct tree* right;
}Tree;

typedef Tree* pTree;

pTree createTree(Station station);

#endif