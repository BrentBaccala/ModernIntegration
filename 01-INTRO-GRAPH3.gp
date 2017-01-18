#!/bin/sh

# m4 <<EOF
(m4 | gnuplot -persist /dev/stdin) <<EOF

set terminal postscript color

    unset key
    set ytics 1
    set xtics 6
    set grid xtics ytics linestyle 4
    set samples 1000
    set xrange [-6:6]
    E(x) = sqrt(3.1415)/2*erf(x)
    tangent(x,x0,y,slope) = abs(x-x0) < 1 ? (y + slope*(x-x0)) : 1/0
    tangent2(x,x0) = tangent(x,x0,E(x0),exp(-x0**2))
    set yrange [-1:1]
    plot E(x), tangent2(x,1) lt 1 lc 0 lw 2, tangent2(x,-1.5) lt 1 lc 0 lw 2

EOF
