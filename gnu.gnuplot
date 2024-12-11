# Input file
datafile = "tests/lv_all_minmax.csv"

# Output settings
set terminal pngcairo size 1000,600 enhanced font 'Arial,12'
set output "graphs/lv_all_minmax_graph.png"

# Title and labels
set title "LV Capacity and Consumption" font ",14"
set xlabel "LV Identifiers" font ",12"
set ylabel "kWh" font ",12"

# Rotate x-axis labels for clarity
set xtics rotate by -45 font ",10"

# Set style for bar chart
set style data histogram
set style histogram cluster gap 1
set style fill solid 0.7 border -1
set boxwidth 0.9

# Legend
set key outside top center horizontal

# Datafile separator
set datafile separator ":"

# Plot the bar chart
plot datafile using 2:xtic(1) title "Capacity (kWh)" linecolor rgb "blue", \
     '' using 3 title "Consumption (kWh)" linecolor rgb "red"