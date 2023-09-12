#!/bin/sh

# m4 <<EOF
(m4 | gnuplot -persist /dev/stdin) <<EOF

define(\`comment', \`')


set terminal postscript color

set isosamples 20,20

set parametric
set hidden3d offset 0 trianglepattern 3
set nokey

set style line 1 linetype 0
set style line 2 linetype 1 linewidth 3
set style line 3 linetype 0 linewidth 2

set view 20, 30, 1.2, 1.2
#set view 15, 0, 1.2, 1.2

unset zeroaxis
unset xtics
unset ytics
unset ztics
unset border
set yrange [-10:10]
set zrange [-10:10]


splot [0:5] [0:5] \
    u,v,(u**2+v**2) with lines ls 1, \
    -u,v,(u**2+v**2) with lines ls 1, \
    u,-v,(u**2+v**2) with lines ls 1, \
    -u,-v,(u**2+v**2) with lines ls 1, \
    u,v,-(u**2+v**2) with lines ls 1, \
    -u,v,-(u**2+v**2) with lines ls 1, \
    u,-v,-(u**2+v**2) with lines ls 1, \
    -u,-v,-(u**2+v**2) with lines ls 1
