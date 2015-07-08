all:
	latexmk -shell-escape -pdf dissertacao.tex

watch:
	latexmk -shell-escape -pdf -pvc -interaction=nonstopmode dissertacao.tex

watch-knitr:
	knitr dissertacao.Rnw
