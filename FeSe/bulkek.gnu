set terminal pngcairo enhanced color font ",24"
set palette defined ( 0  "green", 5 "yellow", 10 "red" )
set output 'bulkek.png' 
set style data linespoints
unset key
set pointsize 0.8
#set xtics font ",24"
#set ytics font ",24"
#set ylabel font ",24"
set ylabel offset 0.5,0
set xrange [0:    0.96351]
emin=   -0.2
emax=    0.2
set ylabel "Energy (eV)"
set yrange [ emin : emax ]
set xtics ("M' "    0.00000,"G  "    0.48176,"M  "    0.96351)
set arrow from    0.48176, emin to    0.48176, emax nohead
# please comment the following lines to plot the fatband 
plot 'bulkek.dat' u 1:2  w lp lw 2 pt 7  ps 0.2 lc rgb 'black', 0 w l lw 2
 
# uncomment the following lines to plot the fatband 
#plot 'bulkek.dat' u 1:2:3  w lp lw 2 pt 7  ps 0.2 lc palette, 0 w l lw 2
# uncomment the following lines to plot the spin if necessary
#plot 'bulkek.dat' u 1:2 w lp lw 2 pt 7  ps 0.2, \
     'bulkek.dat' u 1:2:($3/6):($4/6) w vec
