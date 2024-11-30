#ifndef INSERTIONAVL_H
#define INSERTIONAVL_H

#include "balancingAVL.h"

pTree insertAVL(pTree root, Station station, int *h);
void addConsumption(pTree root, int identifier, int consumption);

#endif