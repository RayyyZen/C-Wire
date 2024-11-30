#!bin/bash

if [ $# -le 0 ]
then
    echo "There is no argument !"
    exit 10
fi

for i in $@
do
    if [ "$i" = "-h" ]
    then
        echo ""
        echo "This project's goal is to make a data synthesis of an electricity ditribution system by analyzing the consumption of the companies or the individuals in terms of energy coming from each type of station (Power stations, HVA stations, HVB stations, LV stations) "
        echo "To execute the program you must add as arguments :"
        echo "The path to the .csv file containing the stations data then the type of station to process (hva, hvb, lv) and finally the type of consumers to process (indiv, comp, all) "
        echo "Example : bash c-wire.sh input/c-wire_v00.dat hva comp"
        echo "!!! Keep in mind that the commands (hvb all, hvb indiv, hva all, hva indiv) returns an error beacause the HVA and HVB stations are not connected to individuals"
        echo ""
        exit 11
    fi
done

if [ $# -ne 3 ]
then
    echo "Non valid number of arguments !"
    exit 12
fi

if [ ! -f $1 ]
then
    echo "The file to process is not found !"
    exit 13
fi

if [ "$2" != "hvb" ] && [ "$2" != "hva" ] && [ "$2" != "lv" ]
then
    echo "Non valid type of station !"
    exit 14
fi

if [ "$3" != "comp" ] && [ "$3" != "indiv" ] && [ "$3" != "all" ]
then
    echo "Non valid type of consumer !"
    exit 15
fi

if [ "$2" = "hvb" ] && { [ "$3" = "indiv" ] || [ "$3" = "all" ] ; }
then
    echo "Non valid command ! The hvb stations (high-voltage B) are not connected to individuals"
    exit 16
fi

if [ "$2" = "hva" ] && { [ "$3" = "indiv" ] || [ "$3" = "all" ] ; }
then
    echo "Non valid command ! The hva stations (high-voltage A) are not connected to individuals"
    exit 17
fi

if [ "$2" = "hvb" ]
then
    col=2
elif [ "$2" = "hva" ]
then
    col=3
else
    col=4
fi

tail -n+2 $1 | sort -k"$col" -t';' -h > tmp/stations.csv 
#Sorts the file containing all the datas after removing the first line

cd tmp

cut -d';' -f"$col" stations.csv > stationsColumn.csv
#Takes just the column that is refering to the station that we want to process

stationsCounter=1
for i in `cat stationsColumn.csv`
do
    if [ "$i" = "1" ]
    then
        break
    fi
    stationsCounter=$((stationsCounter+1))
done
#To know from which line the station to process is present in the file

col=$((col-1))

if [ $col -eq 1 ]
then
    tail -n+$stationsCounter stations.csv | sort -k"$col" -t';' -h > "$2.csv"
else
    tail -n+$stationsCounter stations.csv | sort -k"$col" -r -t';' -h > "$2.csv"
fi
#Remove the lines where there is not the station to process and sort the file

count=0
if [ "$2" = "hvb" ]
then
    sort -k3 -t';' -h hvb.csv > hvbCompTmp.csv
    cut -d';' -f3 hvbCompTmp.csv > hvbColumn.csv
    for i in `cat hvbColumn.csv`
    do
        if [ "$i" != "-" ]
        then
            break
        fi
        count=$((count+1))
    done
    head -n$count hvbCompTmp.csv |  sort -k1 -t';' -h > hvbComp.csv

elif [ "$2" = "hva" ]
then
    sort -k4 -t';' -h hva.csv > hvaCompTmp.csv 
    cut -d';' -f4 hvaCompTmp.csv > hvaColumn.csv
    for i in `cat hvaColumn.csv`
    do
        if [ "$i" != "-" ]
        then
            break
        fi
        count=$((count+1))
    done
    head -n$count hvaCompTmp.csv |  sort -k2 -r -t';' -h > hvaComp.csv

else
    cut -d';' -f6 lv.csv > indiv.csv
    cut -d';' -f5 lv.csv > comp.csv
    ind=0
    com=0

    for i in `cat indiv.csv`
    do
        if [ "$i" != "-" ]
        then
            break
        fi
        ind=$((ind+1))
    done

    for i in `cat comp.csv`
    do
        if [ "$i" != "-" ]
        then
            break
        fi
        com=$((com+1))
    done
    
    #The two loops are used to count the lines where there are just the informations about the lv stations capacity

    if [ $com -gt $ind ]
    then
        post=$ind
    else
        post=$com
    fi

    head -n$post lv.csv > lvPost.csv

    if [ "$3" = "indiv" ]
    then
        cat lvPost.csv > lvIndiv.csv
        sort lv.csv -k6 -t';' -h | cut -d';' -f6 > lvIndivColumn.csv

        countIndiv=1
        for i in `cat lvIndivColumn.csv`
        do
            if [ "$i" != "-" ]
            then
                break
            fi
            countIndiv=$((countIndiv+1))
        done

        sort lv.csv -k6 -t';' -h | tail -n+$countIndiv | sort -k3 -r -t';' -h >> lvIndiv.csv

    elif [ "$3" = "comp" ]
    then
        cat lvPost.csv > lvComp.csv
        sort lv.csv -k5 -t';' -h | cut -d';' -f5 > lvCompColumn.csv

        countComp=1
        for i in `cat lvCompColumn.csv`
        do
            if [ "$i" != "-" ]
            then
                break
            fi
            countComp=$((countComp+1))
        done
        sort lv.csv -k5 -t';' -h | tail -n+$countComp | sort -k3 -r -t';' -h >> lvComp.csv
    
    else
        cat lv.csv > lvAll.csv
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

cd ..

cd codeC

make

./CWire "../tmp/$file" "$2" "$3"

cd ..