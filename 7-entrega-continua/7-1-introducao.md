# 7.1 Introdução

No capítulo anterior tratamos da parte da Integração Contínua, que permite, a cada commit, confirmando mudanças realizadas, verificar a aplicação em tudo o que for necessário, demonstrando que o código não quebrou, que as diretrizes de qualidade estão sendo cumpridas, entre outras tarefas que podem ser automatizadas. No final das contas, essa automação possibilita que o código que está no VCS é continuamente integrado e testado.

Nessa seção, iremos incluir um passo a mais no nosso arquivo de configuração do pipeline de modo que possa ser feito o deploy da aplicação e a mesma possa ser utilizada em um ambiente de produção, conforme já realizamos nos capítulos iniciais. Por também ser uma tarefa automatizada, isso permite que, a todo _commit_, o sistema seja implantado automaticamente, promovendo a entrega contínua (CD).

Juntos, CI/CD promovem uma maior agilidade no processo de transferência do software da máquina do desenvolvedor para o(s) ambiente(s) de produção, entregando os benefícios do DevOps na prática. Cada vez que uma mudança é realizada, em pouco tempo já será possível visualizar seus efeitos no ambiente final. Além disso, o desenvolvedor não precisa perder tempo com tarefas manuais de testes, empacotamente, implantação, pois tudo já está programado e configurado.

Retomando a figura apresentada anteriormente no Capítulo 1.2, estivemos trabalhando nos itens 1, 2, 3, 5 e 6. Como deve ter adivinhado, vamos agora fechar o ciclo e trabalhar finalmente no item 4!

![Fluxo de trabalho genérico e para o ciclo de vida do aplicativo em contêineres do Docker (extraída de Torre (2020))](https://docs.microsoft.com/pt-br/dotnet/architecture/containerized-lifecycle/docker-application-lifecycle/media/containers-foundation-for-devops-collaboration/generic-end-to-enddpcker-app-life-cycle.png)

Faremos uma abordagem prática, dando continuidade ao mesmo exemplo que trabalhamos no [Capítulo 6](../6-integracao-continua/6-1-introducao.md). Assim, se ainda não efetuou os passos do exemplo por lá e quiser acompanhar aqui, volte e realize todas as etapas para deixar configurado tudo o que vamos precisar:

* Projeto de classificador de produtos configurado como contêiner único;
* Projeto no GitLab configurado e sincronizado com a pasta local;
* Um _runner_ CI/CD rodando (pode ser rodando em máquina própria ou pode ser os _runners_ gratuitos oferecidos pelo GitLab mediante verificação da conta).
