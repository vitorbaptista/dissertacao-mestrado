all: final.pdf
	latexmk -shell-escape -pdf dissertacao.tex

final.pdf: dissertacao.pdf
	pdftk A=dissertacao.pdf B=ficha-catalografica.pdf C=ata.pdf cat A1 B C A2-end output final.pdf

dissertacao.pdf:
	latexmk -shell-escape -pdf dissertacao.tex

watch:
	latexmk -shell-escape -pdf -pvc -interaction=nonstopmode dissertacao.tex

watch-knitr:
	knitr dissertacao.Rnw
