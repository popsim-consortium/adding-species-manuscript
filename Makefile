all: adding_species_manuscript.pdf

adding_species_manuscript.pdf: adding_species_manuscript.tex references.bib
	pdflatex adding_species_manuscript.tex
	bibtex adding_species_manuscript
	pdflatex adding_species_manuscript.tex
	pdflatex adding_species_manuscript.tex

clean:
	rm -f *.pdf
	rm -f *.log *.dvi *.aux
	rm -f *.blg *.bbl
	rm -f *.eps *.[1-9]
	rm -f src/*.mpx *.mpx

