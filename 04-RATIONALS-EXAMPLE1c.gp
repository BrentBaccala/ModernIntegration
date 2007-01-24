#!/bin/sh

(m4 | gnuplot /dev/stdin) > junk.ps <<EOF

define(\`comment', \`')

set terminal postscript color

set isosamples 20,20

#splot [-10:10] [-10:0] atan2(y,x)

set parametric
set hidden3d offset 0 trianglepattern 3
set nokey

set style line 1 linetype 0
set style line 2 linetype 1 linewidth 3

set view 50, 30

#set ticslevel -(10/14)
set ticslevel -0.71428
set zeroaxis
unset xtics
set zrange [-10:4]

funcx(v) = ((v/2)*(v/2)*(v/2)-3*(v/2))
funcy(v) = (v/2)*(v/2)-2

func2x(v) = ((-v/2)*(-v/2)*(-v/2)-3*(-v/2))
func2y(v) = (-v/2)*(-v/2)-2

func2atan2(y,x) = atan2(y,x)  - ((y > 0) ? 2*pi : 0)

splot [-5:5] [0:5] u,5-v,atan2(5-v,u) with lines ls 1,   \
	u,-v,atan2(-v,u) with lines ls 1, \
	u,5-v,atan2(5-v,u)-2*pi with lines ls 1, \
	u,-v,atan2(-v,u)-2*pi with lines ls 1, \
	funcx(v),funcy(v),func2atan2(funcy(v),funcx(v))+0.2 with lines ls 2, \
	func2x(v),func2y(v),atan2(func2y(v),func2x(v))+0.2 with lines ls 2


EOF

#gnuplot junk.gp >junk.ps
