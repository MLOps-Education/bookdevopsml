# 3.1 Desenvolvimento vs Produção: o fim ou o início?

Neste capítulo falamos sobre o ambiente de produção. Conforme comentado no livro "[DevOps na Prática: Entrega de Software Confiável a Automatizada](https://www.casadocodigo.com.br/products/livro-devops)", Sato (2018) argumenta que o ciclo de vida do software deveria iniciar somente apenas quando o usuário passasse a fazer uso do software.

Particularmente, essa é uma afirmação interessante. Do ponto de vista de desenvolvimento de software, sabe-se que bons produtos de software ficam no mercado por mais de 20 anos. Desse modo, se comparado com o tempo de desenvolvimento do produto e o primeiro lançamento, pode-se dizer que o software passa muito mais tempo em manutenção do que em desenvolvimento.

A ideia deste capítulo é ilustrar como podemos utilizar o Docker para montar o ambiente de produção e disponibilizar uma aplicação para ser utilizada pelo usuário final.

Recapitulando a figura do Capítulo 1 que ilustra um fluxo DevOps, esse capítulo tem como objetivo final começar a abordar o item 5 da figura, ou seja, o ambiente de produção.

![Fluxo de trabalho genérico e para o ciclo de vida do aplicativo em contêineres do Docker (extraída de Torre (2020))](https://docs.microsoft.com/pt-br/dotnet/architecture/containerized-lifecycle/docker-application-lifecycle/media/containers-foundation-for-devops-collaboration/generic-end-to-enddpcker-app-life-cycle.png)

Iremos adotar, a princípio, um ambiente simples de produção, fazendo uso do Docker e contêineres para executar algumas tarefas típicas de um sistema de Machine Learning. Em particular, veremos como é possível configurar um ambiente de produção para os três exemplos típicos de tarefas vistos no capítulo anterior: uma tarefa _online_ para processamento de dados em batch, e duas tarefas _online_: API HTTP e processamento em fluxo. 

Neste momento, o ambiente será realmente simples, portanto várias coisas ficarão de fora, como monitoramento, versionamento, agendamento de tarefas, testes de sanidade, e outros conceitos importantes de um ambiente de produção de Machine Learning. À medida que avançamos no livro, acrescentaremos algumas dessas funcionalidades e ferramentas.