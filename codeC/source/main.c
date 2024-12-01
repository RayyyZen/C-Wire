#include "insertionAVL.h"
#include "file.h"

/*
int main(int argc, char** argv){
    pTree root=NULL;
    int infos[INFOS]={0};
    char line[50];
    char fileName[10];
    FILE *file=fopen(argv[1],"r");
    
    if(file==NULL){
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
        exit(21);
    }
    
    fprintf(output,"Station %s:Capacity in kWh:Consumption in kWh (%s)\n",argv[2],argv[3]);

    fillOutputFile(output,root);
    
    fclose(output);

    return 0;
}
*/

int main(int argc, char** argv){
    pTree root=NULL;
    int infos[INFOS]={0};
    char fileName[20];
    
    for(int i=3;i<argc;i++){
        saveLineInfos(argv[i],infos);
        root=processStation(root,argv[1],argv[2],infos);
    }
    


    strcpy(fileName,"../tests/");
    strcat(fileName,argv[1]);
    strcat(fileName,"_");
    strcat(fileName,argv[2]);
    strcat(fileName,".csv");

    FILE *output=fopen(fileName,"w");

    if(output==NULL){
        exit(21);
    }
    
    fprintf(output,"Station %s:Capacity in kWh:Consumption in kWh (%s)\n",argv[1],argv[2]);

    fillOutputFile(output,root);
    
    fclose(output);

    return 0;
}