#!/usr/bin/gnuplot -persist
#

# unset key

set terminal wxt enhanced

set title "z = (1 + i) + {/Symbol \326}~2{1.3\\_} e^{i {/Symbol q}}"

set size square

set xzeroaxis
set yzeroaxis

set samples 10000

limit = 100

set xrange [ -limit : limit ]
set yrange [ -limit : limit ]

set trange [0 : 2*pi]

z(theta) = {1,1} + sqrt(2)*exp({0,1}*theta)
mysqrt(x) = ((imag(x) > 0) ^ (abs(x) > 15)) ? -sqrt(x) : sqrt(x)
y(t) = mysqrt(z(t)**4 - 1)

set parametric

plot real(z(t)), imag(z(t)) title "z", real(z(t)**4-1), imag(z(t)**4-1) title "z^4-1", real(y(t)), imag(y(t)) title "sqrt(z^4-1)", real(z(t)**3), imag(z(t)**3) title "z^3", real(2*z(t)**3/y(t)), imag(2*z(t)**3/y(t)) title "2 z^3 / sqrt(x^4+1)"

