
all: ModernIntegration.pdf slides.pdf decomposition.pdf

SAGE=sage

clean:
	rm *.inc *.ps *.pdf

%.inc: %.sh
	sh $< > $@
%.ps: %.gp
	sh $< > $@
%.pdf: %.ps
	ps2pdf $<

.DELETE_ON_ERROR:

# sagecommon.sage is created here, but it is also used in the slides,
# so it's important that this build step runs before the slides
# are created.  There's really not much in the Makefile to enforce
# that requirement.

ModernIntegration.pdf: [0-9]*.tex BIBLIOGRAPHY.tex ModernIntegration.tex
	#rm -f pythontex-files-ModernIntegration/*
	pdflatex ModernIntegration || true
	ls -v sagecommon*.tex | xargs cat > sagecommon.sage
	rm sagecommon*.tex
	./pythontex/pythontex/pythontex.py --interpreter sage:$(SAGE) --verbose ModernIntegration.tex --jobs 1
	pdflatex ModernIntegration
	rm sagecommon*.tex

%.md5: %
	@md5sum $< | cmp -s $@ -; if test $$? -ne 0; then md5sum $< > $@; fi

slides.pdf: slides.tex ModernIntegration.cpy.md5
	pdflatex slides || true
	./pythontex/pythontex/pythontex.py --interpreter sage:$(SAGE) --verbose slides.tex --jobs 1
	pdflatex slides

decomposition.pdf: decomposition.tex
	pdflatex decomposition || true
	./pythontex/pythontex/pythontex.py --interpreter sage:$(SAGE) --verbose decomposition.tex --jobs 1
	pdflatex decomposition

out.pdf: slides.pdf toc.pdf ModernIntegration.pdf
	pdftk A=slides.pdf B=toc.pdf C=ModernIntegration.pdf cat A B1 C46-49 C59-64 output out.pdf


publish: ModernIntegration.pdf slides.pdf
	scp ModernIntegration.pdf slides.pdf u20:/var/www/html/ModernIntegration/

dep depend .depend: [0-9]*.tex
	grep -e \\\\includegraphics -e \\\\input [0-9]*.tex | sed 's/^[^{]*{/ModernIntegration.pdf:/' | sed 's/}.*//' > .depend

include .depend
