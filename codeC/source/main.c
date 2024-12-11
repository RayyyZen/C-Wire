#include "insertionAVL.h"
#include "deleteTree.h"
#include "file.h"

int main(int argc, char** argv){
    
    if(argc!=4){
        printf("Non valid number of arguments given by the shell scirpt to the c program !\n");
        exit(150);
    }
    
    pTree root=NULL;
    long int infos[INFOS]={0};
    char line[50];
    char fileName[10];
    FILE *file=fopen(argv[1],"r");
    
    if(file==NULL){
        printf("input file couldn't be opened !\n");
        exit(20);
    }

    while(fscanf(file,"%s",line)!=EOF){
        saveLineInfos(line,infos);
        root=processStation(root,argv[2],argv[3],infos);
    }

    fclose(file);

    strcpy(fileName,"../tests/");
    strcat(fileName,argv[2]);
    strcat(fileName,"_");
    strcat(fileName,argv[3]);
    strcat(fileName,".csv");

    FILE *output=fopen(fileName,"w");

    if(output==NULL){
        printf("Output file couldn't be opened !\n");
        exit(21);
    }
    
    fprintf(output,"Station %s:Capacity in kWh:Consumption in kWh (%s)\n",argv[2],argv[3]);

    fillOutputFile(output,root);
    
    fclose(output);

    deleteAllTree(&root);

    return 0;
}