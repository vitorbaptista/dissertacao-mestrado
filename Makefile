all:
	latexmk -pdf dissertacao.tex

watch:
	latexmk -pdf -pvc dissertacao.tex
