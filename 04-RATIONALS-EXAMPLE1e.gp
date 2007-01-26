#!/bin/sh

(m4 | gnuplot -persist /dev/stdin) <<EOF

set terminal postscript color

set nokey

set samples 250

pow(f,p) = exp(log(f)*p)

plot [0:3] (pow(x,4)-3*pow(x,2)+6)/(pow(x,6)-5*pow(x,4)+5*pow(x,2)+4)

EOF
