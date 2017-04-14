
all: ModernIntegration.pdf

clean:
	rm *.inc *.ps *.pdf

%.inc: %.sh
	sh $< > $@
%.ps: %.gp
	sh $< > $@
%.pdf: %.ps
	ps2pdf $<

.DELETE_ON_ERROR:

ModernIntegration.pdf: [0-9]*.tex BIBLIOGRAPHY.tex ModernIntegration.tex
	rm -f pythontex-files-ModernIntegration/*
	pdflatex ModernIntegration
	./pythontex/pythontex/pythontex.py --interpreter maxima:/home/baccala/src/maxima-code/maxima-local --verbose ModernIntegration.tex
	# ./pythontex/pythontex/pythontex.py --verbose ModernIntegration.tex
	pdflatex ModernIntegration

out.pdf: slides.pdf toc.pdf ModernIntegration.pdf
	pdftk A=slides.pdf B=toc.pdf C=ModernIntegration.pdf cat A B1 C46-49 C59-64 output out.pdf


scp: ModernIntegration.pdf
	scp ModernIntegration.pdf www:/var/www/ModernIntegration

dep depend .depend: [0-9]*.tex
	grep -e \\\\includegraphics -e \\\\input [0-9]*.tex | sed 's/^[^{]*{/ModernIntegration.pdf:/' | sed 's/}.*//' > .depend

include .depend
