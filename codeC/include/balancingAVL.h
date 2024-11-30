#ifndef BALANCINGAVL_H
#define BALANCINGAVL_H

#include "station.h"

int max2(int number1, int number2);
int max3(int number1, int number2, int number3);
int min2(int number1, int number2);
int min3(int number1, int number2, int number3);

pTree rightRotation(pTree node);
pTree leftRotation(pTree node);
pTree doubleLeftRotation(pTree node);
pTree doubleRightRotation(pTree node);
pTree balanceAVL(pTree node);

#endif