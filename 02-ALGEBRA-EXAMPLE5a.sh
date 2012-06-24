#!/bin/sh

./long-division.pl '-y^2-(x)y+(2x^2)' '-5y^2+(5x+7)y-(7x)'
echo "\\\\bigskip"
./long-division.pl '-5y^2+(5x+7)y-(7x)' '-(2x+7/5)y+(2x^2+7/5x)'
