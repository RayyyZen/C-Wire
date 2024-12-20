#ifndef FILE_H
#define FILE_H

#include "insertionAVL.h"

#define INFOS 3

#define IDENTIFIER 0
#define CAPACITY 1
#define LOAD 2

void saveLineInfos(char *line, long int infos[INFOS]);
pTree processStation(pTree root, long int infos[INFOS]);
long int absoluteValue(long int number1, long int number2);
void fillOutputFile(FILE *file, pTree root);

#endif