#!/bin/sh
#
# gnuplot script to plot roots of an equation

equation=$1
if [ "x$equation" = "x" ]; then equation="z**6-1"; fi

/usr/bin/gnuplot -geometry 500x500 -persist <<EOF
#cat > cyclo.out <<EOF

unset ztics
set ticslevel 0
set grid
set zeroaxis lt 3

min(a,b) = a>b ? b : a

set isosamples 500,500

set view 0,0

set key off
set size 1.4,1.4
set origin -0.2,-0.2

strength = 1.0
poly(z) = (strength * ($equation))

splot [-2:2] [-2:2] [5:100] min(abs(1/poly(x+{0,1}*y)),10)

bind Up "strength = strength * 2; replot"
bind Down "strength = strength / 2; replot"

EOF
