# Projeto

## Objetivos

Em linhas gerais, o objetivo é criar um sistema que monitore o comportamento do
governo (parlamentares, gasto, etc.). No âmbito desse mestrado, meu foco é no
legislativo, mais especificamente na Câmara dos Deputados. Quero criar um
sistema que me avise caso detecte alguma anomalia e/ou mudança de comportamento
na Câmara.

* Detectar mudanças de comportamento dos parlamentares;
* Detectar mudanças semelhantes entre vários parlamentares (ex.: João e Pedro
  votavam diferente e passaram a votar igual);
* (Secundário) Encontrar votações importantes, lembrando que polêmico é
  diferente de importante (ex.: Lei Maria da Penha teve só 2 votos contra).

## Justificativa

A quantidade de dados disponíveis é muito grande para ser analisada por uma só
pessoa. Mesmo pensando só em dados sobre votações, há uma infinidade de
informações. Padrões de votação, mudanças de partido, projetos apresentados,
etc.

Um software pode analisar e comparar dados muito mais rapidamente que um
humano. Assim, pode detectar anomalias e mudanças de comportamento mais
velozmente, auxiliando o trabalho da pessoa.

## Arquitetura

O sistema é dividido em três grandes grupos: Extração, Análise e Notificação.
Eles são organizados em uma pipeline, onde cada grupo entrega dados para o
grupo seguinte.

A primeira parte é responsável por extrair dados de fontes diversas (Câmara dos
Deputados, Senado Federal, etc.) e armazená-los em uma forma útil para
análise. O componente de análise usa os dados extraídos pelo componente
anterior buscando por padrões e anomalias. Já o componente de notificação é
responsável por gerar e enviar relatórios com base nas análises feitas pelo
segundo componente.

Basicamente, o componente de Extração é responsável pelo data wrangling, o de
Análise pelo data science, e o de notificação pela interface com o usuário.
