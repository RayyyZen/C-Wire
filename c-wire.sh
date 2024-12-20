#!bin/bash

#Function that displays the help containing the instructions to execute the program
display_help(){
    echo ""
    echo "This project's goal is to make a data synthesis of an electricity ditribution system by analyzing the consumption of the companies or the individuals in terms of electricity coming from each type of station (Power plants, HVB stations, HVA stations, LV posts)"
    echo "To execute the program you must add :"
    echo "1. The execution command of the Shell script : bash c-wire.sh"
    echo "2. The path to the file containing the stations data"
    echo "3. The type of station to process (hvb, hva, lv)"
    echo "4. The type of consumer to process (comp, indiv, all)"
    echo "5. The identifier of the power plant to process (optional)"
    echo "If there aren't any power plant identifier given as argument, the process is done on all the power plants of the input file"
    echo "Example : bash c-wire.sh /path/c-wire_v25.dat hvb comp 1"
    echo "!!! Keep in mind that the commands (hvb all, hvb indiv, hva all, hva indiv) are not valid beacause the HVA and HVB stations are not connected to individuals"
    echo ""
}

start=$(date +%s)
#Stores the start time of the program to calculate the duration of the process in the end

if [ $# -le 0 ]
then
    echo "The analysis failed ! (Duration of the process : 0.0 seconds)"
    echo "Cause : No arguments !"
    display_help
    exit 10
fi

for i in $@
do
    if [ "$i" = "-h" ]
    then
        display_help
        exit 11
    fi
done

if [ $# -ne 3 ] && [ $# -ne 4 ]
then
    echo "The analysis failed ! (Duration of the process : 0.0 seconds)"
    echo "Cause : Non valid number of arguments !"
    display_help
    exit 12
fi
#If the number of arguments is equal to 3 it means that the user didn't give a specified power plant to process as an argument
#If the number of arguments is equal to 4 it means that the user gave a specified power plant to process as an argument

if [ ! -f "$1" ]
then
    echo "The analysis failed ! (Duration of the process : 0.0 seconds)"
    echo "Cause : The file to process is not found !"
    display_help
    exit 13
fi

if [ "$2" != "hvb" ] && [ "$2" != "hva" ] && [ "$2" != "lv" ]
then
    echo "The analysis failed ! (Duration of the process : 0.0 seconds)"
    echo "Cause : Non valid type of station !"
    display_help
    exit 14
fi

if [ "$3" != "comp" ] && [ "$3" != "indiv" ] && [ "$3" != "all" ]
then
    echo "The analysis failed ! (Duration of the process : 0.0 seconds)"
    echo "Cause : Non valid type of consumer !"
    display_help
    exit 15
fi

if [ "$2" = "hvb" ] && { [ "$3" = "indiv" ] || [ "$3" = "all" ] ; }
then
    echo "The analysis failed ! (Duration of the process : 0.0 seconds)"
    echo "Cause : Non valid command ! The HVB stations (High-voltage B) are not connected to individuals"
    display_help
    exit 16
fi

if [ "$2" = "hva" ] && { [ "$3" = "indiv" ] || [ "$3" = "all" ] ; }
then
    echo "The analysis failed ! (Duration of the process : 0.0 seconds)"
    echo "Cause : Non valid command ! The HVA stations (High-voltage A) are not connected to individuals"
    display_help
    exit 17
fi

if [ $# -eq 4 ] && ! tail -n+2 "$1" | cut -d';' -f1 | grep -q -F -- "$4"
then
    echo "The analysis failed ! (Duration of the process : 0.0 seconds)"
    echo "Cause : The specified power plant doesn't exist in the file !"
    display_help
    exit 18
fi
#The -q in the grep is to keep just the return value of the grep to know if the string to search exists in the file or not
#The -F in the grep is to consider the asterisks '*' as caracters in situations where the user types : 1*
#The -- tells the grep that the options are finished and all what is coming next isn't an option to avoid situations where the user types : -l

if [ -d "tmp" ]
then
    rm -rf "tmp"
    #Removes the tmp folder and all its files if it is already created
fi
mkdir "tmp"

if [ ! -d "tests" ]
then
    mkdir "tests"
fi

if [ ! -d "input" ]
then
    mkdir "input"
fi

if [ ! -d "graphs" ]
then
    mkdir "graphs"
fi

#Creates the folders that are not already created

cp "$1" "input/inputStations.csv"
#Copies the file containing the stations data given as an argument in the input folder

if [ "$2" = "hvb" ]
then
    
    if [ $# -eq 3 ]
    then
        tail -n+2 "$1" | cut -d';' -f2,3,7,8 | awk '{ if($1 != "-" && $2 == "-") print $0; }' FS=";" | cut -d';' -f1,3,4 > "tmp/hvbComp.csv"
        #It removes the first line of the input file then it takes only the columns containing the identifiers of the HVB stations, their capacity and the load of the companies directly connected to them

    else
        power="$4"
        tail -n+2 "$1" | cut -d';' -f1,2,3,7,8 | awk -v idPowerPlant="$power" '{ if($1 == idPowerPlant && $2 != "-" && $3 == "-") print $0; }' FS=";" | cut -d';' -f2,4,5 > "tmp/hvbComp.csv"
        #It removes the first line of the input file then it takes only the columns containing the identifiers of the HVB stations, their capacity and the load of the companies directly connected to them, connected to a specified power plant
    fi

    file="hvbComp.csv"
    #The name of the file that will be given to the C program

elif [ "$2" = "hva" ]
then
    
    if [ $# -eq 3 ]
    then
        tail -n+2 "$1" | cut -d';' -f3,4,7,8 | awk '{ if($1 != "-" && $2 == "-") print $0; }' FS=";" | cut -d';' -f1,3,4 > "tmp/hvaComp.csv"
        #It removes the first line of the input file then it takes only the columns containing the identifiers of the HVA stations, their capacity and the load of the companies directly connected to them

    else
        power="$4"
        tail -n+2 "$1" | cut -d';' -f1,3,4,7,8 | awk -v idPowerPlant="$power" '{ if($1 == idPowerPlant && $2 != "-" && $3 == "-") print $0; }' FS=";" | cut -d';' -f2,4,5 > "tmp/hvaComp.csv"
        #It removes the first line of the input file then it takes only the columns containing the identifiers of the HVA stations, their capacity and the load of the companies directly connected to them, connected to a specified power plant
    fi

    file="hvaComp.csv"
    #The name of the file that will be given to the C program

else

    if [ "$3" = "comp" ]
    then
        
        if [ $# -eq 3 ]
        then
            tail -n+2 "$1" | cut -d';' -f4,6,7,8 | awk '{ if($1 != "-" && $2 == "-") print $0; }' FS=";" | cut -d';' -f1,3,4 > "tmp/lvComp.csv"
            #It removes the first line of the input file then it takes only the columns containing the identifiers of the LV posts, their capacity and the load of the companies directly connected to them

        else
            power="$4"
            tail -n+2 "$1" | cut -d';' -f1,4,6,7,8 | awk -v idPowerPlant="$power" '{ if($1 == idPowerPlant && $2 != "-" && $3 == "-") print $0; }' FS=";" | cut -d';' -f2,4,5 > "tmp/lvComp.csv"
            #It removes the first line of the input file then it takes only the columns containing the identifiers of the LV posts, their capacity and the load of the companies directly connected to them, connected to a specified power plant
        fi
        
        file="lvComp.csv"
        #The name of the file that will be given to the C program

    elif [ "$3" = "indiv" ]
    then
        
        if [ $# -eq 3 ]
        then
            tail -n+2 "$1" | cut -d';' -f4,5,7,8 | awk '{ if($1 != "-" && $2 == "-") print $0; }' FS=";" | cut -d';' -f1,3,4 > "tmp/lvIndiv.csv"
            #It removes the first line of the input file then it takes only the columns containing the identifiers of the LV posts, their capacity and the load of the individuals directly connected to them

        else
            power="$4"
            tail -n+2 "$1" | cut -d';' -f1,4,5,7,8 | awk -v idPowerPlant="$power" '{ if($1 == idPowerPlant && $2 != "-" && $3 == "-") print $0; }' FS=";" | cut -d';' -f2,4,5 > "tmp/lvIndiv.csv"
            #It removes the first line of the input file then it takes only the columns containing the identifiers of the LV posts, their capacity and the load of the individuals directly connected to them, connected to a specified power plant
        fi

        file="lvIndiv.csv"
        #The name of the file that will be given to the C program

    else
        
        if [ $# -eq 3 ]
        then
            tail -n+2 "$1" | cut -d';' -f4,7,8 | awk '{ if($1 != "-") print $0; }' FS=";" > "tmp/lvAll.csv"
            #It removes the first line of the input file then it takes only the columns containing the identifiers of the LV posts, their capacity and the load of all the consumers directly connected to them

        else
            power="$4"
            tail -n+2 "$1" | cut -d';' -f1,4,7,8 | awk -v idPowerPlant="$power" '{ if($1 == idPowerPlant && $2 != "-") print $0; }' FS=";" | cut -d';' -f2,3,4 > "tmp/lvAll.csv"
            #It removes the first line of the input file then it takes only the columns containing the identifiers of the LV posts, their capacity and the load of all the consumers directly connected to them, connected to a specified power plant
        fi
        
        file="lvAll.csv"
        #The name of the file that will be given to the C program

    fi
fi

cd "codeC"
#Opens the codeC folder to compile and execute the C program

make
#Compiles the C program

if [ $? -ne 0 ]
then
    end=$(date +%s)
    #Stores the end time of the program to calculate the duration of all the process
    echo "The analysis failed ! (Duration of the process : $((end-start)) seconds)"
    echo "Cause : The compilation failed !"
    display_help
    exit 19
fi
# $? is the return code of the make command (It returns 0 if it was a success)

if [ ! -x "CWire" ]
then
    end=$(date +%s)
    #Stores the end time of the program to calculate the duration of all the process
    echo "The analysis failed ! (Duration of the process : $((end-start)) seconds)"
    echo "Cause : CWire is not executable or does not exist !"
    display_help
    exit 20
fi

if [ $# -eq 3 ]
then
    ./CWire "../tmp/$file" "$2" "$3"

else
    ./CWire "../tmp/$file" "$2" "$3" "$4"
fi
#Executes the C program by giving as arguments : the processed file, the station type, the consumer type and the specified power plant if it is previously given by the user

cd "../tests"
#Opens the tests folder

if [ $# -eq 3 ]
then
    fileName="$2_$3.csv"

else
    fileName="$2_$3_$4.csv"
fi

head -n1 "$fileName" > "../tmp/sortTmp.csv"
tail -n+2 "$fileName" | sort -k2 -t':' -n >> "../tmp/sortTmp.csv"
#Sorts the output file by the column containg the capacity

cp "../tmp/sortTmp.csv" "$fileName"
#Copies the sorted file in the output file

if [ "$2" = "lv" ] && [ "$3" = "all" ]
then

    numberLines=$(wc -l < "$fileName")
    #Takes the number of lines in the lv all result file 

    if [ $numberLines -gt 20 ]
    then

        tail -n+2 "$fileName" | sort -k3 -r -t':' -n > "../tmp/sortLvAll.csv"
        #Sorts the LV posts by the column containing the consumption

        head -n10 "../tmp/sortLvAll.csv" > "../tmp/sortLvTmp.csv"
        #Keeps the 10 LVs with the higher consumption

        tail -n10 "../tmp/sortLvAll.csv" >> "../tmp/sortLvTmp.csv"
        #Keeps the 10 LVs with the lower consumption

        if [ $# -eq 3 ]
        then
            fileNameLV="lv_all_minmax.csv"
            fileNameLVMinMax="lv_all_minmax"

        else
            fileNameLV="lv_all_minmax_$4.csv"
            fileNameLVMinMax="lv_all_minmax_$4"
        fi

        head -n1 "$fileName" > "$fileNameLV"

        sort -k4 -t':' -n "../tmp/sortLvTmp.csv" >> "$fileNameLV"
        #Sorts the output file by the column containg the production balance

        cd ..

        gnuplot -e "ARG='$fileNameLVMinMax'" graph.gnuplot
        #Creates a bar graph with the minmax file by using a gnuplot script
    
    else
        echo ""
        echo "The lv_all_minmax.csv file couldn't be created beacause there are less than 20 posts LV in the input file"

    fi

fi

end=$(date +%s)
#Stores the end time of the program to calculate the duration of all the process

echo ""
echo "The analysis was successful ! (Duration of the process : $((end-start)) seconds)"
echo ""