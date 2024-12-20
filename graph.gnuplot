# Input file
datafile = sprintf("tests/%s.csv", ARG)

set terminal pngcairo size 1000,600 enhanced font 'Arial,12'
set output sprintf("graphs/%s_graph.png", ARG)

set title "LV posts bar graph" font ",14"
set xlabel "LV posts identifiers" font ",12"
set ylabel "Energy in kWh" font ",12"

set xtics rotate by -45 font ",10"

set style data histogram
set style histogram cluster gap 1
set style fill solid 0.7 border -1
set boxwidth 0.9

set key outside top center horizontal

set datafile separator ":"

plot datafile using 4:xtic(1) title "Production balance" linecolor rgb "blue", \