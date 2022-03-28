all: adding_species_manuscript.pdf

clean :
	-rm adding_species_manuscript.tex adding_species_manuscript.pdf adding_species_manuscript.docx

%.pdf : %.md
	pandoc adding_species_manuscript.md --to latex --from markdown+autolink_bare_uris+tex_math_single_backslash --output adding_species_manuscript.pdf --filter pandoc-citeproc 

