#!/bin/sh

if [ $0 = 04-RATIONALS-EXAMPLE1c.gp ]; then
    graph=a
else
    graph=b
fi

(m4 | gnuplot -persist /dev/stdin) <<EOF

define(\`comment', \`')


# this produces graph A
#define(graphAonly, \`\$*')
#define(graphBonly, \`')
ifelse($graph,a,\`define(graphAonly, \`\$*')')
ifelse($graph,a,\`define(graphBonly, \`')')

# this produces graph B
#define(graphAonly, \`')
#define(graphBonly, \`\$*')
ifelse($graph,b,\`define(graphAonly, \`')')
ifelse($graph,b,\`define(graphBonly, \`\$*')')



set terminal postscript color

set isosamples 20,20

#splot [-10:10] [-10:0] atan2(y,x)

set parametric
set hidden3d offset 0 trianglepattern 3
set nokey

set style line 1 linetype 0
set style line 2 linetype 1 linewidth 3
set style line 3 linetype 0 linewidth 2

set view 20, 30, 1.2, 1.2
#set view 15, 0, 1.2, 1.2

#set ticslevel -(10/14)
set ticslevel -0.71428
set zeroaxis
#set xzeroaxis linetype 4 linewidth 3
#set yzeroaxis linetype 4 linewidth 3
unset xtics
unset ztics
set border 15
#set xtics -6,2,6
#set ytics -6,2,6
set xtics -5,5,5
set ytics -5,5,5
set yrange [-10:10]
set zrange [-10:4]

# input ranges from 0 to 5
# output ranges from -2.5 to 2.5 (full range)
# output ranges from -2.5 to sqrt(2) (transition point)
#scale1(v) = v - 2.5
#scale1(v) = v/2
scale1(v) = (v/5)*(sqrt(2)+2.5)-2.5

func1x(v) = (scale1(v)*scale1(v)*scale1(v)-3*scale1(v))
func1y(v) = scale1(v)*scale1(v)-2

#func1atan2(y,x) = atan2(y,x)  - ((y > 0) ? 2*pi : 0)
func1atan2(y,x) = atan2(y,x)

# input ranges from 0 to 5
# output ranges from sqrt(2) to 2.5
#scale2(v) = -v/2
#scale2(v) = 0
scale2(v) = (v/5)*(2.5-sqrt(2))+sqrt(2)

func2x(v) = (scale2(v)*scale2(v)*scale2(v)-3*scale2(v))
func2y(v) = scale2(v)*scale2(v)-2

graphAonly(func2atan2(y,x) = atan2(y,x))
graphBonly(func2atan2(y,x) = atan2(y,x) - 2*pi)

#    u,-v,atan2(-v,u)-2*pi with lines ls 3, \

splot [0:5] [0:5] \
    u,v,atan2(v,u) with lines ls 1,   \
    graphAonly(5+u,v,atan2(v,5+u) with lines ls 1,)   \
    -u,v,atan2(v,-u) with lines ls 1,   \
    -5-u,v,atan2(v,-5-u) with lines ls 1,   \
    u,-v,atan2(-v,u) with lines ls 1, \
    graphAonly(u+5,-v,atan2(-v,u+5) with lines ls 1,) \
    -u,-v,atan2(-v,-u) with lines ls 1, \
    graphAonly(-u-5,-v,atan2(-v,-u-5) with lines ls 1,) \
    graphBonly( u,v,atan2(v,u)-2*pi with lines ls 3, ) \
    graphBonly( -u,v,atan2(v,-u)-2*pi with lines ls 1, )   \
    graphBonly( 5+u,v,atan2(v,5+u)-2*pi with lines ls 3, ) \
    func1x(v),func1y(v),func1atan2(func1y(v),func1x(v))+0.2 with lines ls 2, \
    func2x(v),func2y(v),func2atan2(func2y(v),func2x(v))+0.2 with lines ls 2


EOF
