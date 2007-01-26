
all: file.pdf

%.inc: %.sh
	sh $< > $@
%.ps: %.gp
	sh $< > $@
%.pdf: %.ps
	ps2pdf $<

file.pdf: PREFACE 01-INTRO 02-ALGEBRA 03-DIFFALG 04-RATIONALS file.tex $(patsubst %.sh, %.inc, $(wildcard 02-ALGEBRA*.sh))
	pdflatex file

dep depend .depend:
	grep includegraphics [0-9]* | sed 's/^[^{]*{/file.pdf:/' | sed 's/}.*//' > .depend

include .depend
