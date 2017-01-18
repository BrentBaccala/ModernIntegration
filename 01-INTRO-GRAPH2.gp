#!/bin/sh

# m4 <<EOF
(m4 | gnuplot -persist /dev/stdin) <<EOF

set terminal postscript color

unset key
set grid linestyle 4
set samples 1000
set xrange [-6:6]
plot sqrt(3.1415)/2*erf(x)

EOF
