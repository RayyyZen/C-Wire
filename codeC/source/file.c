#include "file.h"

//Function that fills an array with the informations of a line of the input file
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
                //The strtoll() function transforms a string to an integer with huge values
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

//Function that processes an array by either adding a new node to the tree or adding a consumption to a node according to the infos
pTree processStation(pTree root, char *typeStation, long int infos[INFOS]){
    Station station={0};
    int h=0,STATION=-1;

    if(typeStation==NULL){
        printf("Error : process of a NULL station !\n");
        exit(31);
    }

    if(strcmp(typeStation,"hvb")==0){
        STATION=HVB;
    }
    else if(strcmp(typeStation,"hva")==0){
        STATION=HVA;
    }
    else{
        STATION=LV;
    }

    if(infos[COMPANY]==0 && infos[INDIVIDUAL]==0){
        station.identifier=infos[STATION];
        station.capacity=infos[CAPACITY];
        station.consumption=0;
        root=insertAVL(root,station,&h);
    }
    else{
        addConsumption(root,infos[STATION],infos[LOAD]);
    }

    return root;
}

//Function that returns the absolute value of the subtraction of 2 numbers
long int absoluteValue(long int number1, long int number2){
    return number1>number2 ? number1-number2 : number2-number1;
}

//Functions that fills the output file with the identifier of the station, the capacity, the consumption of the consumers connected directly to the station and the production balance of the station
void fillOutputFile(FILE *file, pTree root){
    if(root!=NULL){
        fprintf(file,"%d:%ld:%ld:%ld\n",root->station.identifier,root->station.capacity,root->station.consumption,absoluteValue(root->station.capacity,root->station.consumption));
        fillOutputFile(file,root->left);
        fillOutputFile(file,root->right);
    }
}