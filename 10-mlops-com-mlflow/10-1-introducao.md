# 10.1 Introdução

Colocar modelos em produção não se resume a servir um modelo para que ele possa ser consumido, seja em tarefas _online_ ou _batch_. Isso por um motivo muito simples: assim como qualquer outro artefato de software, um modelo de machine learning não é um artefato estático. Ele evolui com o passar do tempo, devido a mudanças em todo o contexto onde ele se insere. Pode haver mudanças em regras de negócio, mudanças em legislação, tendências novas nos dados envolvidos e que exigem retreinamento, novos algoritmos e técnicas mais elaboradas... Tudo isso pode gerar a necessidade de atualização desse artefato.

O gerenciamento dessa evolução tem uma série de particularidades. Como explicado [neste vídeo tutorial da Databricks](https://www.youtube.com/watch?v=x3cxvsUFVZA), um projeto de machine learning tem algumas particularidades que o diferenciam do software tradicional:

* Não existe um conjunto de requisitos bem especificados. O objetivo é otimizar alguma métrica, como por exempo acurácia. Assim, é necessário constante experimentação para melhorá-la;
* Não basta ser um bom desenvolvedor de software e desenvolver bom código. A qualidade depende dos dados de entrada e dos hiperparâmetros;
* Não há um conjunto fixo de tecnologias e frameworks. É comum testar, combinar e comparar muitas bibliotecas, algoritmos e modelos;
* Não há uma única linguagem e um único ambiente. O ambiente de desenvolvimento é muito diversificado.

Tudo isso gera particularidades que podem fazer o desenvolvimento ficar bastante complexo, principalmente quando é necessário escalar:

* Muitos modelos;
* Muito volume de dados;
* Muitas pessoas.

Por esse motivo surgiu o [MLflow](https://mlflow.org/), uma ferramenta open source para todo o ciclo de desenvolvimento de machine learning.