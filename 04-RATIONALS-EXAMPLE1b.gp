#!/bin/sh

(m4 | gnuplot -persist /dev/stdin) <<EOF

set terminal postscript color

set isosamples 20,200

set parametric
set hidden3d offset 0 trianglepattern 3
set nokey

set xrange [-1.25:1.25]
set yrange [-1.25:1.25]
set zrange [-10:40]

set xtics -1,1,1
set ytics -1,1,1

set zeroaxis
set ticslevel -0.2

set style line 1 linetype 0
set style line 2 linetype 1 linewidth 3
set style line 3 linetype 0 linewidth 2

set label "" at 1, 0, 0 point lt 1 pt 7 ps 1
set label "" at 1, 0, 2*pi point lt 1 pt 7 ps 1
set label "" at 1, 0, 4*pi point lt 1 pt 7 ps 1
set label "" at 1, 0, 6*pi point lt 1 pt 7 ps 1
set label "" at 1, 0, 8*pi point lt 1 pt 7 ps 1
set label "" at 1, 0, 10*pi point lt 1 pt 7 ps 1

splot [0:1.1] [-pi:11*pi] u*cos(v),u*sin(v),v with lines ls 1, \
    1, 0, 50*u-10 with lines ls 2

EOF
