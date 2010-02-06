
all: file.pdf

%.inc: %.sh
	sh $< > $@
%.ps: %.gp
	sh $< > $@
%.pdf: %.ps
	ps2pdf $<

file.pdf: [0-9]*.tex file.tex
	pdflatex file

out.pdf: slides.pdf toc.pdf file.pdf
	pdftk A=slides.pdf B=toc.pdf C=file.pdf cat A B1 C46-49 C59-64 output out.pdf


dep depend .depend: [0-9]*.tex
	grep -e includegraphics -e input [0-9]*.tex | sed 's/^[^{]*{/file.pdf:/' | sed 's/}.*//' > .depend

include .depend
