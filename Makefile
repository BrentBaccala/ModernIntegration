
all: ModernIntegration.pdf

export SAGE_ROOT = /home/baccala/src/sage

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
	#rm -f pythontex-files-ModernIntegration/*
	pdflatex ModernIntegration
	ls -v sagecommon*.tex | xargs cat > sagecommon.sage
	rm sagecommon*.tex
	ls -v common*.tex | xargs cat > common.mac
	rm common*.tex
	./pythontex/pythontex/pythontex.py --interpreter sage:$(SAGE_ROOT)/local/bin/sage --verbose ModernIntegration.tex --jobs 1
	pdflatex ModernIntegration
	rm common*.tex
	rm sagecommon*.tex

out.pdf: slides.pdf toc.pdf ModernIntegration.pdf
	pdftk A=slides.pdf B=toc.pdf C=ModernIntegration.pdf cat A B1 C46-49 C59-64 output out.pdf


publish: ModernIntegration.pdf
	scp ModernIntegration.pdf www:/var/www/ModernIntegration

dep depend .depend: [0-9]*.tex
	grep -e \\\\includegraphics -e \\\\input [0-9]*.tex | sed 's/^[^{]*{/ModernIntegration.pdf:/' | sed 's/}.*//' > .depend

include .depend
