#include "file.h"
#include "deleteTree.h"

int main(int argc, char** argv){
    
    if(argc!=4 && argc!=5){
        printf("Non valid number of arguments given by the shell scirpt to the c program !\n");
        exit(150);
    }
    //If argc is equal to 4 it means that the user has not given a specified power plant to process, but if it is equal to 5 it means that he has given one
    
    pTree root=NULL;
    long int infos[INFOS]={0};
    //The use of an array of long integers is due to the capacity and load having sometimes very huge values surpassing the limits of simple integers
    char line[50];
    char fileName[20];
    FILE *file=fopen(argv[1],"r");
    
    if(file==NULL){
        printf("input file couldn't be opened !\n");
        exit(20);
    }

    while(fscanf(file,"%s",line)!=EOF){
        saveLineInfos(line,infos);
        root=processStation(root,argv[2],infos);
    }

    fclose(file);

    strcpy(fileName,"../tests/");
    strcat(fileName,argv[2]);
    strcat(fileName,"_");
    strcat(fileName,argv[3]);
    if(argc==5){
        //If the condition is true it means that the user indicated a specified power plant to process
        strcat(fileName,"_");
        strcat(fileName,argv[4]);
    }
    strcat(fileName,".csv");

    FILE *output=fopen(fileName,"w");

    if(output==NULL){
        printf("Output file couldn't be opened !\n");
        exit(21);
    }
    
    fprintf(output,"Station %s:Capacity in kWh:Consumption in kWh (%s):Production balance in kWh\n",argv[2],argv[3]);

    fillOutputFile(output,root);
    
    fclose(output);

    deleteAllTree(&root);

    return 0;
}