#!bin/bash

head -n1 input/$1 > tmp/fichier.txt
tail -n+2 input/$1 | sort -k2 -t';' -h >> tmp/fichier.txt 

cd codeC
make

./CWire
cd ..