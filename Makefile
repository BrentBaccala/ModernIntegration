
all: file.pdf

%.inc: %.sh
	sh $< > $@
%.ps: %.gp
	sh $< > $@
%.pdf: %.ps
	ps2pdf $<

file.pdf: [0-9]*.tex file.tex $(patsubst %.sh, %.inc, $(wildcard 02-ALGEBRA*.sh))
	pdflatex file

dep depend .depend:
	grep includegraphics [0-9]*.tex | sed 's/^[^{]*{/file.pdf:/' | sed 's/}.*//' > .depend

include .depend
