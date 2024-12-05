#ifndef FILE_H
#define FILE_H

#include "insertionAVL.h"

#define INFOS 8

#define POWER 0
#define HVB 1
#define HVA 2
#define LV 3
#define COMPANY 4
#define INDIVIDUAL 5
#define CAPACITY 6
#define LOAD 7

void saveLineInfos(char *line, long int infos[INFOS]);
pTree processStation(pTree root, char *typeStation, char *typeConsumer, long int infos[INFOS]);
void fillOutputFile(FILE *file, pTree root);

#endif