# Projeto de Experimentos

Realizaremos o experimento usando a técnica de projeto fatorial 2^k, que
analisa o efeito de k fatores com dois níveis cada (mínimo e máximo). Para
estimar os erros experimentais, evitando assim que se chegue a conclusões
equivocadas, cada experimento é repetido r vezes, tendo-se assim 2^kr
observações.

O objetivo deste experimento é avaliar a eficácia de dois algoritmos Burro e
Foo em prever o resultado de uma votação, e o quanto conhecer previamente um
percentual dos votos influencia nessa eficácia desses algoritmo.

Como só temos 2 fatores, nosso k é 2, o que nos dá 4 (2^2) experimentos
possíveis, que replicaremos 10 vezes cada, totalizando 40 experimentos.

Os dados usados serão da 53ª legislatura, que foi de 1 de fevereiro de 2007 até
1 de fevereiro de 2011. Escolhemos esta legislatura pois é a mais recente
disponível por completo (a 54ª vai até 2015). Dividimos as votações entre 70%
para treino e 30% para teste. A escolha das votações muda em cada execução.

Código | Fator             | Mínimo (-1) | Máximo (1)
-----------------------------------------------------
A      | Algoritmo         | Burro       | Foo
B      | Amostra de treino | 20%         | 80%

## Algoritmo Burro

Seu funcionamento é bem simples: o resultado da votação é previsto como o voto
da maioria em nossa amostra de treino.

## Algoritmo Foo

Imagine que existam 100 parlamentares. Sabemos os votos de 20, e precisamos
descobrir os dos 80 restantes. O algoritmo funcionaria da seguinte forma:

1. Enquanto existirem parlamentares com voto desconhecido, faça:
1.1. Escola um parlamentar aleatório A cujo voto não conhecemos;
1.2. Escolha o parlamentar B com voto conhecido mais coeso com ele;
1.3. Defina o voto do parlamentar A como sendo igual ao do B;
2. Profit!

Para definir a coesão entre dois parlamentares, usamos o índice de Rice usando
os resultados dos dois anos anteriores a votação analisada. Escolhemos usar só
dois anos para evitar "overfitting".

Ao final, teremos os votos de todos parlamentares e podemos definir o resultado
da votação.
