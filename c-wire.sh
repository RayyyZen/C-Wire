#!bin/bash

#Function that displays the help containing the instructions to execute the program
display_help(){
    echo ""
    echo "This project's goal is to make a data synthesis of an electricity ditribution system by analyzing the consumption of the companies or the individuals in terms of energy coming from each type of station (Power stations, HVA stations, HVB stations, LV stations)"
    echo "To execute the program you must add as arguments :"
    echo "1. The path to the file containing the stations data"
    echo "2. The type of station to process (hva, hvb, lv)"
    echo "3. The type of consumers to process (indiv, comp, all)"
    echo "Example : bash c-wire.sh /path/c-wire_v25.dat hva comp"
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

if [ $# -ne 3 ]
then
    echo "The analysis failed ! (Duration of the process : 0.0 seconds)"
    echo "Cause : Non valid number of arguments !"
    display_help
    exit 12
fi

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
    echo "Cause : Non valid command ! The hvb stations (high-voltage B) are not connected to individuals"
    display_help
    exit 16
fi

if [ "$2" = "hva" ] && { [ "$3" = "indiv" ] || [ "$3" = "all" ] ; }
then
    echo "The analysis failed ! (Duration of the process : 0.0 seconds)"
    echo "Cause : Non valid command ! The hva stations (high-voltage A) are not connected to individuals"
    display_help
    exit 17
fi

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
#It copies the file containing the stations data given as an argument in the input folder


cd tmp
#Opens the tmp folder

if [ "$2" = "hvb" ]
then
    tail -n+2 "../$1" | awk '{ if($2 != "-" && $3 == "-") print $0; }' FS=";" | sort -k5 -t';' -n > hvbComp.csv
    #It removes the first line with the tail command, then the awk command keeps only the lines containing the HVBs and finally it sorts the column containing the companies

elif [ "$2" = "hva" ]
then
    tail -n+2 "../$1" | awk '{ if($3 != "-" && $4 == "-") print $0; }' FS=";" | sort -k5 -t';' -n > hvaComp.csv
    #It removes the first line with the tail command, then the awk command keeps only the lines containing the HVAs and finally it sorts the column containing the companies

else

    if [ "$3" = "comp" ]
    then
        tail -n+2 "../$1" | awk '{ if($4 != "-" && $6 == "-") print $0; }' FS=";" | sort -k5 -t';' -n > lvComp.csv
        #It removes the first line with the tail command, then the awk command keeps only the lines containing the LVs not connected to individuals and finally it sorts by the column containing the companies

    elif [ "$3" = "indiv" ]
    then
        tail -n+2 "../$1" | awk '{ if($4 != "-" && $5 == "-") print $0; }' FS=";" | sort -k6 -t';' -n > lvIndiv.csv
        #It removes the first line with the tail command, then the awk command keeps only the lines containing the LVs not connected to companies and finally it sorts by the column containing the individuals

    else
        tail -n+2 "../$1" | awk '{ if($4 != "-") print $0; }' FS=";" | sort -k5 -t';' -n | sort -k6 -s -t';' -n > lvAll.csv
        #It removes the first line with the tail command, then the awk command keeps only the lines containing the LVs and finally it sorts by the column containing the companies then by the column containing the individuals by keeping the stability
    fi

fi

if [ "$2" = "hvb" ]
then
    file="hvbComp.csv"

elif [ "$2" = "hva" ]
then
    file="hvaComp.csv"

else
    if [ "$3" = "comp" ]
    then
        file="lvComp.csv"

    elif [ "$3" = "indiv" ]
    then
        file="lvIndiv.csv"

    else
        file="lvAll.csv"
    fi
fi


cd ../codeC
#Opens the codeC folder to compile and execute the C program

make

./CWire "../tmp/$file" "$2" "$3"


cd ../tests
#Opens the tests folder

sort "$2_$3.csv" -k2 -t':' -n > sortTmp.csv
#Sorts the output file by the column containg the capacity

mv sortTmp.csv "$2_$3.csv"
#Moves the sorted file to the output file

if [ "$2" = "lv" ] && [ "$3" = "all" ]
then
    tail -n+2 lv_all.csv | awk -F':' -v OFS=':' '{ val = ($2 > $3) ? ($2 - $3) : ($3 - $2); $NF=$NF ":" val; print }' > sortTmpLvAll.csv
    #It removes the first line with the tail command, then the awk command adds a new column containing the absolute value of the subtraction between the capacity and the consumption

    head -n1 lv_all.csv | awk -F':' -v OFS=':' '{ $NF=$NF ":" "Production balance"; print }' > lv_all_minmax.csv
    #Adds the title of the new column

    sort sortTmpLvAll.csv -k4 -r -t':' -n | head -n10 >> lv_all_minmax.csv
    #Sorts the LVs by the column containing the production balance and keeps the 10 LVs with the higher balance 

    sort sortTmpLvAll.csv -k4 -r -t':' -n | tail -n10 >> lv_all_minmax.csv
    #Sorts the LVs by the column containing the production balance and keeps the 10 LVs with the less balance 
fi

end=$(date +%s)
#Stores the end time of the program to calculate the duration of all the process

echo ""
echo "The analysis was successful ! (Duration of the process : $((end-debut)) seconds)"
echo ""