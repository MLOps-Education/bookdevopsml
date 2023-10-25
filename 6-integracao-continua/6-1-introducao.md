# 6.1 Introdução

Nós capítulos anteriores o foco foi na demonstração da implantação do ambiente de produção considerando a tecnologia Docker. Desse modo, demonstramos como usar contêineres para colocar no ar algumas aplicações funcionais. Basicamente fizemos uso de diferentes tecnologias: nginx (web), guvicorn (WSGI), Flask (API HTTP) e Apache Kafka, além do servidor de monitoramento (Nagios). Com o uso do Docker, tornamos o processo de deploy mais automatizado e menos propenso a erros.

Retomando a figura apresentada anteriormente no [Capítulo 1](broken-reference), [Seção 1.2](../1-introducao/1-2-devops-e-docker.md), estivemos trabalhando nos itens 1, 5 e 6. Abordaremos agora as etapas 2 e 3, ou seja, a integração contínua, passando pelo controle de versões, construção, integração e testes.

![Fluxo de trabalho genérico e para o ciclo de vida do aplicativo em contêineres do Docker (extraída de Torre (2020))](https://docs.microsoft.com/pt-br/dotnet/architecture/containerized-lifecycle/docker-application-lifecycle/media/containers-foundation-for-devops-collaboration/generic-end-to-enddpcker-app-life-cycle.png)

Conforme ressalta [Sato (2018](https://www.casadocodigo.com.br/products/livro-devops)), a essência do DevOps é exatamente a cooperação entre as equipes de desenvolvimento e operações em prol de construir e disponibilizar uma aplicação de qualidade para os usuários finais utilizando o máximo possível de automatização nesse processo. Para isso, escrever código para a aplicação e para a infraestrutura é fundamental.

Considerando essa forma moderna de desenvolvimento de software o que se pretende é que, a cada alteração realizada no código da aplicação que seja confirmada (_commit_), siga-se um fluxo (_pipeline_) que permita a compilação, teste e geração do pacote da aplicação para entrega ao ambiente de produção se for o caso.

Isso é decorrente da introdução dos métodos ágeis propostos nos anos 90 e que hoje são utilizados total ou parcialmente por grande parte das empresas desenvolvedoras de software ([Beck e Andres (2005)](https://www.pearson.com/us/higher-education/program/Beck-Extreme-Programming-Explained-Embrace-Change-2nd-Edition/PGM155384.html)). Dentre as práticas ágeis preconizadas pela _eXtreme Programing_ (XP), por exemplo, estão: refatoração, _Test Driven Development_ (TDD), propriedade coletiva de código, projeto incremental, programação em pares, padrões de código e integração contínua. Obviamente, nem todas são universalmente aceitas mas algumas, tais como a responsabilidade pelo código e a integração contínua passaram a ser um padrão de fato no desenvolvimento de software atual.

A responsabilidade pelo código acabou fazendo com que o desenvolvedor, ao se responsabilizar pelo código que escreve, passasse a adotar teste unitário como prática comum. Desse modo, ele não entrega mais apenas o código operacional da aplicação mas também um conjunto de testes unitários que demonstre que o que ele desenvolveu funciona corretamente.

Já a integração contínua faz com que, a cada mudança confirmada no código, todo ou parte do sistema seja reconstruída e testada rapidamente e a equipe de desenvolvimento passa a ter um rápido retorno se algo deu errado com as últimas mudanças introduzidas. Para esse ponto, recomendo a leitura do artigo de [Feitelson et al. (2013)](https://doi.org/10.1109/MIC.2013.25) intitulado "[_Development and Deployment at Facebook_](https://doi.org/10.1109/MIC.2013.25)". É bem interessante. Apesar de apresentar o relato de desenvolvimento em uma empresa particular, as práticas adotadas e descritas são empregadas hoje por uma vasta gama de empresas.

Esperamos que estejam animados para essas próximas etapas de aprendizado sobre Integração e Entrega Contínuas.
