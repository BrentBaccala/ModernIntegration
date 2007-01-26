#!/bin/sh

# m4 <<EOF
(m4 | gnuplot -persist /dev/stdin) <<EOF

set terminal postscript color

set nokey
set parametric
set xrange [-5:5]
set yrange [-5:5]

set zeroaxis

define(\`mklabel', \`set label "\$1" at (\$1*\$1*\$1-3*\$1), (\$1*\$1-2) point lt 1 pt 7 ps 1 front font "Helvetica,20" \$2')

mklabel(-2)
mklabel(-1.5)
mklabel(-1)
mklabel(-0.5, \`offset 1,-4')
mklabel(0, \`offset 1,-4')
mklabel(0.5, \`right offset 0,-4')
mklabel(1, \`right offset -2,0')
mklabel(1.5, \`right offset -2,0')
mklabel(2, \`offset -6,1')

plot [-5:5] (t*t*t-3*t), (t*t-2)

EOF
