# Luigi VS Huginn

Existem vários frameworks que posso usar para criar o data pipeline. Eles
servem para definir as tarefas e suas interdependências. Na minha busca,
encontrei o [Azkaban do LinkedIn][Azkaban], [Oozie do Apache][Oozie], [Luigi do
Spotify][Luigi], e o [Huginn][Huginn] (criado pela comunidade).

Desses, os dois primeiros (Azkaban e Oozie) se limitam a tarefas que usam o
Hadoop. Como o volume de dados que vou analisar é muito pequeno
(comparativamente), não vejo a necessidade de usar o Hadoop. Por isso, eles
foram desconsiderados logo de cara. Sobraram o Luigi e o Huginn.

## Requisitos

Além das funcionalidades básicas de um data pipeline (agendamento,
gerenciamento de dependências, etc.), busco um sistema que permita:

* Desenvolver tarefas em qualquer linguagem;
* Extrair dados tanto de APIs quanto de bancos de dados (para usar o BD
  Legislativo da CEBRAP);
* Persistir os dados em BDs e no sistema de arquivos local.

Tanto o Luigi quanto o Huginn cumprem todos esses requisitos, mas eles têm uma
diferença importante. O Huginn foi feito como um [IFTTT][IFTTT] pessoal. Ele
foi pensado como um sistema para ajudar a uma pessoa automatizar tarefas
repetitivas ou monitorar o que lhe interessa (como o clima da sua cidade, sua
localização, notícias no Twitter, etc.).

Para isso, ele tem uma interface web mais amigável onde você pode selecionar os
"agentes" que deseja e os interligar. A funcionalidade de um agente pode ser
checar o clima. Daí você o configura com sua cidade e o interliga com outro
agente que envia e-mails. Dessa forma, você recebe um email quando for chover.

Já o Luigi foi feito pelo Spotify para executar tarefas como analisar os dados
dos usuários do Spotify, gerar uma lista dos artistas mais escutados, top
músicas, etc.

O Huginn é pensado para automatizar tarefas pessoais, enquanto o Luigi é para
tarefas de uma empresa.

Dessa forma, apesar de ambos puderem executar as mesmas tarefas, para o projeto
de minha dissertação, o Luigi é mais indicado.

[Azkaban]: http://data.linkedin.com/opensource/azkaban
[Oozie]: http://oozie.apache.org/
[Luigi]: https://github.com/spotify/luigi
[Huginn]: https://github.com/cantino/huginn
[IFTTT]: https://ifttt.com/
