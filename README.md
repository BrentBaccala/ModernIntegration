# Modern Integration [![Download PDF](https://img.shields.io/badge/Download-PDF-brightgreen.svg)](http://www.freesoft.org/ModernIntegration/ModernIntegration.pdf)
## A differential algebra textbook

From the preface:

> In 1970, Robert Risch published [Ri70], which sketched in four pages
> how to bound the torsion of a divisor on an algebraic curve, and
> thus provided the "missing link" in a comprehensive algorithm that
> would either find an elementary form for a given integral, or prove
> that no such elementary form can exist.  Risch's method, suitably
> enhanced, is currently used in the symbolic integration routines of
> the most sophisticated computer algebra systems.
>
> The goal of this book is to present the Risch integration algorithm
> in a manner suitable to be understood by undergraduate mathematics
> students, the prerequisites being calculus and abstract algebra, and
> the expected context being a senior-level university class.
>
> Why, first of all, should math students study this subject, and why
> near the end of an undergraduate mathematics program?
>
> First and foremost, for pedagogical reasons.  Almost all modern
> college math curricula include higher algebra, yet this subject seems
> to be taught in a very abstract context.  The integration problem puts
> this abstraction into concrete form.
> One of the best ways to learn a subject
> is to apply it in a specific and concrete way.  The greatest
> difficulties I have encountered in math is when faced with abstract
> concepts lacking concrete examples.  Such, in my mind, is the primary
> benefit of studying Risch integration near the end of an undergraduate
> program.  The student has no doubt been exposed to higher algebra, now
> we want to make sure we understand it by taking all those rings,
> fields, ideals, extensions and what not and applying them to a
> specific goal.
>
> Secondly, there is a sense of both historical and educational
> completion to be obtained.  Not only has the integration problem
> challenged mathematicians since the development of the calculus, but
> there is a real danger of getting through an entire calculus sequence
> and be left thinking that if you really want to solve an integral, the
> best way is to use a computer!  Due to the intricacy of the
> calculations involved, the best way probably is to use a computer, but
> without studying the Risch algorithm, the student is left with a vague
> sense that integration is nothing but a bag of tricks, and
> a real deficiency without
> understanding that the integration problem has been solved.
>
> Third, an introduction to differential algebra may be quite
> appropriate at a point where students are starting to think about
> research interests.  Though this field has profitably engaged the
> attentions of a number of late twentieth century mathematicians, it is
> still a young field that may turn out to be a major breakthrough in
> the solution of differential equations.  It may also turn out to be a
> dead end ("interesting but not compelling" in the words of one
> commentator), which I why I hesitate to list this reason first on my
> list.  The big question, in my mind, is whether this theory can be
> suitably extended to handle partial differential equations, as both
> integrals and ordinary differential equations can now be adequately
> handled using numerical techniques.  This question remains unanswered
> at this time, and that mystery has animated my own mathematical
> research for a number of years.


Currently, the first six chapters, covering the transcendental cases, are in fairly good order,
and should be useful to anyone studying Risch integration,
but are not yet suitable for publication.  The remaining chapters are
still woefully inadequate.

Chapter 1 is an introduction.

Chapter 2 is a review of basic commutative algebra.

Chapter 3 introduces differential algebra, gives a precise definition of
the term "elementary function", shows how symbolic integration can be
reduced to three basic cases, and finally states and proves Liouville's theorem.

Chapter 4 covers integration of rational functions, a topic mostly addressed in elementary
calculus classes, but the focus here is on an outlying case, generally skipped, that
can lead to discontinuous integrals even when the integrand is continuous.

Chapter 5 covers the logarithmic extension.

Chapter 6 covers the exponential extension.

Chapter 7 begins discussion of the algebraic extension by introducing classical algebraic curve theory

Chapter 8 covers the integration of Abelian integrals, stating the Risch theorem without proof.

Chapter 9 proofs the Risch Theorem (currently only a sketch).

Chapter 10, covering algebraic extensions in general, is also only a sketch.

Chapter 11 is a loose collection of notes that won't be a chapter in the final edit

## Building from source

After cloning this repository (use --recursive to get its submodule), you'll need the following packages (on Ubuntu):

    maxima
    python
    python-pygments
    python-sympy
    texlive-latex-base
    texlive-latex-extra
    texlive-publishers

I use a patched version of Sage.  Though most of the patches are
moving their way through the Sage development pipeline, the textbook
can't currently build with a stock Sage.  Clone my [Sage repository](https://github.com/BrentBaccala/sage)
on github and build with the optional packages `kash`, `blad`, and `bmi`, something like this:

    git clone https://github.com/BrentBaccala/sage.git
    cd sage
    make build
    SAGE_ROOT=$(pwd) ./local/bin/sage -i kash
    SAGE_ROOT=$(pwd) ./local/bin/sage -i blad
    SAGE_ROOT=$(pwd) ./local/bin/sage -i bmi
    make build

Then adjust `SAGEROOT` in the textbook's Makefile to point to your Sage installation,
and build the textbook with `make`.

## The current draft

The current draft PDF is available [here](http://www.freesoft.org/ModernIntegration/ModernIntegration.pdf)
