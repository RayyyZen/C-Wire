#include "file.h"

void saveLineInfos(char *line, long int infos[INFOS]){
    char string[50];
    int indexInfos=0,indexLine=0,indexString=0;

    if(line==NULL){
        printf("Error : process of an empty line !\n");
        exit(30);
    }

    while(line[indexLine]!='\0'){
        if(line[indexLine]==';'){
            string[indexString]='\0';
            if(string[0]=='-'){
                infos[indexInfos]=0;
            }
            else{
                infos[indexInfos]=strtoll(string,NULL,10);
                //The strtoll() function transforms a string to an integer with hyge values
            }
            indexInfos++;
            indexString=0;
        }
        else{
            string[indexString]=line[indexLine];
            indexString++;
        }
        indexLine++;
    }
    string[indexString]='\0';
    if(string[0]=='-'){
        infos[indexInfos]=0;
    }
    else{
        infos[indexInfos]=strtoll(string,NULL,10);
    }
}

pTree processStation(pTree root, char *typeStation, char *typeConsumer, long int infos[INFOS]){
    Station station={0};
    int h=0;

    if(typeStation==NULL || typeConsumer==NULL){
        printf("Error : process of a NULL station !\n");
        exit(31);
    }

    if(strcmp(typeStation,"hvb")==0){
        if(infos[COMPANY]==0){
            station.identifier=infos[HVB];
            station.capacity=infos[CAPACITY];
            station.consumption=0;
            root=insertAVL(root,station,&h);
        }
        else{
            addConsumption(root,infos[HVB],infos[LOAD]);
        }
    }
    else if(strcmp(typeStation,"hva")==0){
        if(infos[COMPANY]==0){
            station.identifier=infos[HVA];
            station.capacity=infos[CAPACITY];
            station.consumption=0;
            root=insertAVL(root,station,&h);
        }
        else{
            addConsumption(root,infos[HVA],infos[LOAD]);
        }
    }
    else{
        if(strcmp(typeConsumer,"comp")==0){
            if(infos[COMPANY]==0){
                station.identifier=infos[LV];
                station.capacity=infos[CAPACITY];
                station.consumption=0;
                root=insertAVL(root,station,&h);
            }
            else{
                addConsumption(root,infos[LV],infos[LOAD]);
            }
        }
        else if(strcmp(typeConsumer,"indiv")==0){
            if(infos[INDIVIDUAL]==0){
                station.identifier=infos[LV];
                station.capacity=infos[CAPACITY];
                station.consumption=0;
                root=insertAVL(root,station,&h);
            }
            else{
                addConsumption(root,infos[LV],infos[LOAD]);
            }
        }
        else{
            if(infos[INDIVIDUAL]==0 && infos[COMPANY]==0){
                station.identifier=infos[LV];
                station.capacity=infos[CAPACITY];
                station.consumption=0;
                root=insertAVL(root,station,&h);
            }
            else{
                addConsumption(root,infos[LV],infos[LOAD]);
            }
        }
    }
    return root;
}

void fillOutputFile(FILE *file, pTree root){
    if(root!=NULL){
        fprintf(file,"%d:%ld:%ld\n",root->station.identifier,root->station.capacity,root->station.consumption);
        fillOutputFile(file,root->left);
        fillOutputFile(file,root->right);
    }
}