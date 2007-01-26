#!/bin/sh

(m4 | gnuplot -persist /dev/stdin) <<EOF

set terminal postscript color

set nokey

set samples 250

set parametric

pow(f,p) = exp(log(f)*p)

f(x) = 2*atan((pow(x,3)-3*x) / (x*x-2))

plot [0:1] sqrt(2)*t,f(sqrt(2)*t), \
    sqrt(2)+(3-sqrt(2))*t,f(sqrt(2)+(3-sqrt(2))*t) with line lt 1

EOF
