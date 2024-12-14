#!bin/bash

#Function that displays the help containing the instructions to execute the program
display_help(){
    echo ""
    echo "This project's goal is to make a data synthesis of an electricity ditribution system by analyzing the consumption of the companies or the individuals in terms of energy coming from each type of station (Power plants, HVB stations, HVA stations, LV posts)"
    echo "To execute the program you must add as arguments :"
    echo "1. The path to the file containing the stations data"
    echo "2. The type of station to process (hvb, hva, lv)"
    echo "3. The type of consumers to process (comp, indiv, all)"
    echo "4. The identifier of the power plant to process (optional)"
    echo "If there aren't any power plant identifier given as argument, the process is done on all the power plants of the input file"
    echo "Example : bash c-wire.sh /path/c-wire_v25.dat hvb comp 1"
    echo "!!! Keep in mind that the commands (hvb all, hvb indiv, hva all, hva indiv) are not valid beacause the HVA and HVB stations are not connected to individuals"
    echo ""
}

debut=$(date +%s)
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

if [ ! -f $1 ]
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
#The -q in the grep is to have the return value of the grep to know if the string to search exists in the file or not
#The -F in the grep is to consider the asterisks '*' as caracters in situations where the user types : 1*
#The -- tells the grep that the options are finished and all what is coming next isn't an option to avoid situations where the user types : -l

if [ -d "tmp" ]
then
    rm -rf tmp
    #Removes the tmp folder and all its files if it is already created
fi
mkdir tmp

if [ ! -d "tests" ]
then
    mkdir tests
fi

if [ ! -d "input" ]
then
    mkdir input
fi

if [ ! -d "graphs" ]
then
    mkdir graphs
fi

cp $1 input/inputStations.csv
#Copies the file containing the stations data given as an argument in the input folder

if [ "$2" = "hvb" ]
then
    
    if [ $# -eq 3 ]
    then
        tail -n+2 "$1" | awk '{ if($2 != "-" && $3 == "-") print $0; }' FS=";" | sort -k5 -t';' -n > tmp/hvbComp.csv

    else
        power="$4"
        tail -n+2 "$1" | awk -v idPowerPlant="$power" '{ if($1 == idPowerPlant && $2 != "-" && $3 == "-") print $0; }' FS=";" | sort -k5 -t';' -n > tmp/hvbComp.csv
    fi

    #It removes the first line with the tail command, then the awk command keeps only the lines containing the HVBs (connected to a specified power plant if it is given as an argument) and finally it sorts by the column containing the companies

    file="hvbComp.csv"

elif [ "$2" = "hva" ]
then
    
    if [ $# -eq 3 ]
    then
        tail -n+2 "$1" | awk '{ if($3 != "-" && $4 == "-") print $0; }' FS=";" | sort -k5 -t';' -n > tmp/hvaComp.csv

    else
        power="$4"
        tail -n+2 "$1" | awk -v idPowerPlant="$power" '{ if($1 == idPowerPlant && $3 != "-" && $4 == "-") print $0; }' FS=";" | sort -k5 -t';' -n > tmp/hvaComp.csv
    fi

    #It removes the first line with the tail command, then the awk command keeps only the lines containing the HVAs (connected to a specified power plant if it is given as an argument) and finally it sorts by the column containing the companies

    file="hvaComp.csv"

else

    if [ "$3" = "comp" ]
    then
        
        if [ $# -eq 3 ]
        then
            tail -n+2 "$1" | awk '{ if($4 != "-" && $6 == "-") print $0; }' FS=";" | sort -k5 -t';' -n > tmp/lvComp.csv

        else
            power="$4"
            tail -n+2 "$1" | awk -v idPowerPlant="$power" '{ if($1 == idPowerPlant && $4 != "-" && $6 == "-") print $0; }' FS=";" | sort -k5 -t';' -n > tmp/lvComp.csv
        fi
        
        #It removes the first line with the tail command, then the awk command keeps only the lines containing the LVs not connected to individuals (connected to a specified power plant if it is given as an argument) and finally it sorts by the column containing the companies

        file="lvComp.csv"

    elif [ "$3" = "indiv" ]
    then
        
        if [ $# -eq 3 ]
        then
            tail -n+2 "$1" | awk '{ if($4 != "-" && $5 == "-") print $0; }' FS=";" | sort -k6 -t';' -n > tmp/lvIndiv.csv

        else
            power="$4"
            tail -n+2 "$1" | awk -v idPowerPlant="$power" '{ if($1 == idPowerPlant && $4 != "-" && $5 == "-") print $0; }' FS=";" | sort -k6 -t';' -n > tmp/lvIndiv.csv
        fi

        #It removes the first line with the tail command, then the awk command keeps only the lines containing the LVs not connected to companies (connected to a specified power plant if it is given as an argument) and finally it sorts by the column containing the individuals

        file="lvIndiv.csv"

    else
        
        if [ $# -eq 3 ]
        then
            tail -n+2 "$1" | awk '{ if($4 != "-") print $0; }' FS=";" | sort -t';' -k6,6n -k5,5n > tmp/lvAll.csv
            #Sorting by the column containing the load takes more time because the values are huge

        else
            power="$4"
            tail -n+2 "$1" | awk -v idPowerPlant="$power" '{ if($1 == idPowerPlant && $4 != "-") print $0; }' FS=";" | sort -t';' -k6,6n -k5,5n > tmp/lvAll.csv
        fi
        
        #It removes the first line with the tail command, then the awk command keeps only the lines containing the LVs (connected to a specified power plant if it is given as an argument) and finally it sorts by the column containing the companies then by the column containing the individuals by keeping the stability

        file="lvAll.csv"

    fi

fi

cd codeC
#Opens the codeC folder to compile and execute the C program

make
#Compiles the C program

if [ $# -eq 3 ]
then
    ./CWire "../tmp/$file" "$2" "$3"

else
    ./CWire "../tmp/$file" "$2" "$3" "$4"

fi
#Executes the C program by giving as arguments : the processed file, the station type, the consumer type and the specified power plant if it is previously given by the user

cd ../tests
#Opens the tests folder

if [ $# -eq 3 ]
then
    fileName="$2_$3.csv"

else
    fileName="$2_$3_$4.csv"

fi

sort "$fileName" -k2 -t':' -n > sortTmp.csv
#Sorts the output file by the column containg the capacity

mv sortTmp.csv "$fileName"
#Moves the sorted file to the output file

if [ "$2" = "lv" ] && [ "$3" = "all" ]
then

    numberLines=$(wc -l < "$fileName")
    #Takes the number of lines in the lv_all.csv file 

    if [ $numberLines -gt 20 ]
    then

        tail -n+2 "$fileName" | sort -k4 -r -t':' -n > ../tmp/sortLvAll.csv
        #Sorts the posts LV by the column containing the production balance

        if [ $# -eq 3 ]
        then
            fileNameLV="lv_all_minmax.csv"

        else
            fileNameLV="lv_all_minmax_$4.csv"

        fi

        head -n1 "$fileName" > "$fileNameLV"
        #Adds the first line of the lv_all.csv file to the new file

        head -n10 ../tmp/sortLvAll.csv >> "$fileNameLV"
        #Keeps the 10 LVs with the higher balance 

        tail -n10 ../tmp/sortLvAll.csv >> "$fileNameLV"
        #Keeps the 10 LVs with the less balance 

        if [ $# -eq 3 ]
        then
            fileNameLVMin="lv_min"
            fileNameLVMax="lv_max"

        else
            fileNameLVMin="lv_min_$4"
            fileNameLVMax="lv_max_$4"

        fi

        tail -n+12 "$fileNameLV" > "../tmp/$fileNameLVMin.csv"
        tail -n+2 "$fileNameLV" | head -n10 > "../tmp/$fileNameLVMax.csv"

        cd ..
        
        gnuplot -e "ARG='$fileNameLVMin'" graph.gnuplot
        gnuplot -e "ARG='$fileNameLVMax'" graph.gnuplot
        #Creates two bar graphs with the minmax file by using a gnuplot script, the graphs contains the 10 posts LV with the higher/lower production balance in kwh
    
    else
        echo ""
        echo "The lv_all_minmax.csv file couldn't be created beacause there are less than 20 posts LV in the input file"

    fi

fi

end=$(date +%s)
#Stores the end time of the program to calculate the duration of all the process

echo ""
echo "The analysis was successful ! (Duration of the process : $((end-debut)) seconds)"
echo ""