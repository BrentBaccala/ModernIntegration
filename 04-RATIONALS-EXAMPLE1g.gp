#!/bin/sh

(m4 | gnuplot -persist /dev/stdin) <<EOF

set terminal postscript color

set nokey

set samples 250

pow(f,p) = exp(log(f)*p)

#f(x) = 2*atan((pow(x,3)-3*x) / (x*x-2))
f(x) = 2*atan((pow(x,5)-3*pow(x,3)+x)/2) + 2*atan(x*x*x) + 2*atan(x)

plot [0:3] f(x)

EOF
