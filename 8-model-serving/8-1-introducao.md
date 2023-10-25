# 8.1 Introdução

Até agora temos focado bastante em DevOps. Mostramos aqui todo o ciclo entre desenvolvimento e operação, utilizando Docker e GitLab como ferramentas de automação para as diferentes tarefas desse processo. Mas os exemplos, apesar de serem aplicativos que utilizam Machine Learning, ainda não exploram questões e dificuldades inerentes aos projetos de Machine Learning.

Por exemplo, retorne ao capítulo anterior, e veja como, ao fazer a substituição de um modelo por outro aprimorado ([Para desprezar acentos, lembra?](../7-entrega-continua/7-4-testando-tudo-junto.md)), tivemos que voltar ao notebook original, salvar o novo modelo, substituí-lo no diretório do aplicativo manualmente, depois subir a nova versão Docker com o novo arquivo, testar localmente, testar no ambiente de _staging_... Tudo isso foi feito de forma manual, o que deveria acender um alerta no leitor. Afinal, desde o início estamos falando que automação é a "alma" do DevOps, não? Será que não daria para automatizar essa parte inerente aos projetos de Machine Learning também?

Além de substituir um modelo por outro, existem outras tarefas que são típicas de um projeto de Machine Learning:

* Construir _pipelines_ complexos para treinamento e predição;
* Ajuste de hiperparâmetros;
* Avaliar modelos por meio de métricas;
* Controlar execução e resultado de experimentos;
* Reproduzir experimentos;
* Empacotar e reutilizar modelos, com versionamento;
* Gerenciar artefatos e metadados (datasets, modelos e código);
* Monitorar o desempenho das soluções de ML em produção;
* Entre outras.

Esse tipo de tarefa normalmente exige um planejamento cuidadoso para que o esforço necessário não se torne uma barreira para a boa qualidade dos produtos entregues. Esse planejamento deve, sempre que possível, fazer uso dos conceitos do DevOps, o que inclui o uso de ferramentas e automação. É esse o assunto que começa agora. Veremos algumas técnicas e ferramentas que auxiliam o engenheiro de machine learning ao longo desse processo.