#!/bin/sh

# m4 <<EOF
(m4 | gnuplot -persist /dev/stdin) <<EOF

set terminal postscript color

# copied from bivariat gnuplot demo and modified

# the function integral_f(x) approximates the integral of f(x) from 0 to x.
#
# define f(x) to be any single variable function
#
# the integral is calculated using Simpson's rule as 
#          ( f(x-delta) + 4*f(x-delta/2) + f(x) )*delta/6
# repeated x/delta times (from x down to 0)
#

f(x) = (x==0) ? 1 :sin(x)/x

delta = 0.01

# integral_f(x) takes one variable, the upper limit.  0 is the lower limit.
# calculate the integral of function f(t) from 0 to x

integral_f(x) = (x>0)?int1a(x,(1.0*x)/ceil(x/delta)):-int1b(x,-(1.0*x)/ceil(-x/delta))
int1a(x,d) = (x<=d*.1) ? 0 : sum [i=1:int(x/d)] ((f(i*d-d)+4*f(i*d-d*.5)+f(i*d))*d/6.)
int1b(x,d) = (x>=-d*.1) ? 0 : sum [i=1:int(-x/d)] ((f(i*d+d)+4*f(i*d+d*.5)+f(i*d))*d/6.)

Si(x) = integral_f(x)

    unset key
    set ytics 2
    set xtics 20
    set grid linestyle 4
    set samples 1000
    set xrange [-20:20]
    set yrange [-2:2]
    tangent(x,x0,y,slope) = abs(x-x0) < 3 ? (y + slope*(x-x0)) : 1/0
    tangent2(x,x0) = tangent(x,x0,Si(x0),sin(x0)/x0)
    # set object circle at -9, Si(-9) radius .25 fc rgb 'black' fs solid
    plot Si(x), tangent2(x,5) lt 1 lc 0 lw 2, tangent2(x,-9) lt 1 lc 0 lw 2

EOF
