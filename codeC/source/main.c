#include "insertionAVL.h"
#include "file.h"

void prefixe(pTree root){
    if(root!=NULL){
        printf("%d/%d/%ld\n",root->station.identifier,root->balance,root->station.consumption);
        prefixe(root->left);
        prefixe(root->right);
    }
}

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

    strcpy(fileName,argv[2]);
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