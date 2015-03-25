# Dependências

Para compilar a dissertação no Ubuntu 14.04, execute:

```
sudo apt-get install latexmk texlive-latex-extra texlive-latex-recommended texlive-lang-portuguese texlive-fonts-recommended
```

# Mudando leitor de PDF padrão do latexmk para o evince

Por padrão, o latexmk usa o `xpdf`. Para mudar para o `evince`, que é o leitor
padrão no Ubuntu 14.04, crie um arquivo .latexmkrc no seu diretório home e
adicione:

```
$pdf_previewer = "start evince";
$pdf_update_method = 0;
```
