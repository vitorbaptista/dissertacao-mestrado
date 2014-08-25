# Anotações

## Artigos

### Legislative Prediction via Random Walks over a Heterogeneous Graph

Ele cria um grafo onde nós podem ser parlamentares ou projetos de lei. Os
parlamentares se inter-relacionam baseado em sua coesão (neste artigo ele usou
o número de autorias e co-autorias), os projetos de lei se inter-relacionam de
acordo com sua similaridade (ele analisa o texto do projeto, descobre keywords,
e seleciona o número de keywords em comum (mais ou menos)). A relação entre
parlamentares e projetos de lei se dá só pelos votos (sim ou não, ignora
abstenções/faltas). A autoria/co-autoria não entra em consideração nessa
relação.

Ele separa esse grafo em dois: um só com os votos sim, outro só com os não. Fez
isso por alguma limitação no Random Walk com peso que não entendi bem.

A partir desse método, ele faz a previsão de uma votação de duas formas:
partindo de um subconjunto dos parlamentares, e extrapolando para os outros (se
João votou sim, e Pedro é coeso com João, então Pedro também deve ter votado
sim), e; partindo dos projetos de lei: se João votou sim na lei 123, e a lei
123 é muito parecida com a 321, então João também deve votar sim nela.

Nos testes dele, prever só pela semelhança das leis foi mais efetivo do que só
pela coesão entre os parlamentares. Me pergunto se isso não seja efeito da
maioria das leis ser semelhante. Por exemplo, em projetos de leis singulares
como o Marco Civil, ou redução da maioridade penal, legalização do aborto,
etc., será que a previsão através da semelhança com outras leis continua sendo
mais efetiva?

#### Insights

Agora estou tentando prever votações, e não simplesmente mostrar a coesão entre
parlamentares. Para isto, não basta uma métrica de coesão, tenho que ter uma
forma de, sabendo a coesão entre João e Pedro, e o voto de João numa votação
qualquer, possa prever o voto de Pedro. Neste artigo, ele usou Random Walks num
grafo, mas existem diversas outras formas (algumas das quais que ele comparou
com seu algoritmo). Dependendo do algoritmo, isso pode se tornar em mais um
fator no projeto de experimento: o que tem mais efeito? Mudar a métrica de
coesão (quando usada), ou o algoritmo pra extrapolar da coesão pra o resultado?

#### Idéia de algoritmo

Random Forests pra cada parlamentar. Por exemplo, imagine que eu tenha um CSV
com o voto de todos os parlamentares, aí eu considero o voto do João como o
resultado que eu quero prever, dada a entrada dos votos de todos os outros
parlamentares. Isso vai me gerar um algoritmo pra prever o voto do João, dados
os votos de todos os outros parlamentares.

Infelizmente, eu quero prever o voto do João baseado em menos gente, então
teria que repetir a mesma ideia para prever o voto do João baseado na
permutação dos outros parlamantares. Exemplo: prever o voto do João quando só
tenho o voto do Pedro; prever o voto do João quando só tenho o voto da Samara;
prever o voto do João quando tenho o voto do Pedro e da Samara; etc.

NOT GONNA HAPPEN! Com 500 deputados, esse algoritmo precisaria gerar 500!
combinações, o que não vai rolar. Talvez se não pre-calcularmos a tabela, pode
dar certo. Daí, considerando o pior caso de termos o voto só de um deputado e
precisarmos prever o voto dos 499 outros, "só" teríamos de fazer 499 cálculos
de coesão (voto de João dado que sabemos o voto de Pedro; voto de Samara dado
que sabemos o voto de João e Pedro, etc.) 

#### Usando Rice de forma simples

Imagine que existam 100 parlamentares. Sabemos os votos de 20, e precisamos
descobrir os dos 80 restantes. O algoritmo funcionaria da seguinte forma:

1. Enquanto existirem parlamentares com voto desconhecido, faça:
1.1. Escola um parlamentar aleatório A cujo voto não conhecemos;
1.2. Escolha o parlamentar B com voto conhecido mais coeso com ele;
1.3. Defina o voto do parlamentar A como sendo igual ao do B;
2. Profit!

Ao final, teremos os votos de todos parlamentares e podemos definir o resultado
da votação.

Pensei em algumas melhorias futuras:

* Em 1.1, ao invés de escolher um parlamentar aleatório, escolher o parlamentar
  mais coeso com algum dos parlamentares (ou grupo) cujo voto conhecemos;
* Em 1.2, ao invés de repetir o voto de somente um parlamentar, faça algum
  algoritmo considerando o voto de todos (ou alguns);
