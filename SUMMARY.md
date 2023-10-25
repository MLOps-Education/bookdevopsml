# Table of contents

* [Prática de DevOps com Docker para Machine Learning](README.md)
* [Autores e Agradecimentos](autores-e-agradecimentos.md)
* [Uso do Livro](uso-do-livro.md)
* [Contribua com o Livro](contribua-com-o-livro.md)
* [Licença](licenca.md)
* [Organização do Livro](organizacao-do-livro-1.md)

## 1. Introdução <a href="#1-introducao" id="1-introducao"></a>

* [1.1 Máquinas Virtuais e Contêineres](1-introducao/1-1-maquinas-virtuais-e-conteineres.md)
* [1.2 DevOps e Docker](1-introducao/1-2-devops-e-docker.md)
* [1.3 Configuração do Ambiente - Python](1-introducao/1-4-configuracao-do-ambiente-python.md)
* [1.4 Configuração do Ambiente - Docker](1-introducao/1-3-configuracao-do-ambiente-docker.md)
* [1.5 Dockerfile, Imagem e Contêiner Docker](1-introducao/1.5-dockerfile-imagem-e-conteiner-docker.md)
* [1.6 Docker Hub e Comandos Adicionais](1-introducao/1.6-docker-hub-e-comandos-adicionais.md)

## 2. Desenvolvimento <a href="#2-desenvolvimento" id="2-desenvolvimento"></a>

* [2.1 Do notebook para aplicação - parte 1](2-desenvolvimento/2-1-do-notebook-para-aplicacao-parte-1.md)
* [2.2 Do notebook para aplicação - parte 2](2-desenvolvimento/2-2-do-notebook-para-aplicacao-parte-2.md)
* [2.3 Do notebook para aplicação - parte 3](2-desenvolvimento/2-3-do-notebook-para-aplicacao-parte-3.md)

## 3. Produção <a href="#3-producao" id="3-producao"></a>

* [3.1 Desenvolvimento vs Produção: o fim ou o início?](3-producao/3-1-producao-o-fim-ou-o-inicio.md)
* [3.2 Ambiente de Produção - parte 1](3-producao/3-2-ambiente-de-producao-parte-1.md)
* [3.3 Ambiente de Produção - parte 2](3-producao/3-3-ambiente-de-producao-parte-2.md)
* [3.4 Ambiente de Produção - parte 3](3-producao/3-4-ambiente-de-producao-parte-3.md)

## 4. Monitoramento <a href="#4-monitoramento" id="4-monitoramento"></a>

* [4.1 Introdução](4-monitoramento/4-1-introducao.md)
* [4.2 Configurando o Servidor de Monitoramento](4-monitoramento/4-2-configurando-o-servidor-de-monitorament.md)
* [4.3 Monitorando Servidores do Ambiente de Produção](4-monitoramento/4-3-monitorando-servidores-do-ambiente-de-producao.md)
* [4.4 Comandos de Verificação do Nagios](4-monitoramento/4-4-comandos-de-verificacao-do-nagios.md)
* [4.5 Criando Verificações Mais Específicas](4-monitoramento/4-5-criando-verificacoes-mais-especificas.md)
* [4.6 Criando Alertas](4-monitoramento/4-6-criando-alertas.md)
* [4.7 Recuperando de Problemas](4-monitoramento/4-7-recuperando-de-problemas.md)
* [4.8 Verificação de Contêineres via NRPE](4-monitoramento/4.8-verificacao-de-conteineres-via-nrpe.md)

## 5. Infraestrutura como Código e Orquestração <a href="#5-infraestrutura-como-codigo-e-orquestracao" id="5-infraestrutura-como-codigo-e-orquestracao"></a>

* [5.1 Introdução](5-infraestrutura-como-codigo-e-orquestracao/5-1-introducao.md)
* [5.2 Orquestração com Docker Compose](5-infraestrutura-como-codigo-e-orquestracao/5-2-docker-compose.md)
* [5.3 Orquestração com Kubernetes](5-infraestrutura-como-codigo-e-orquestracao/5-3-kubernetes.md)

## 6. Integração Contínua <a href="#6-integracao-continua" id="6-integracao-continua"></a>

* [6.1 Introdução](6-integracao-continua/6-1-introducao.md)
* [6.2 Controle de Versão](6-integracao-continua/6-2-controle-de-versao.md)
* [6.3 Configurando um repositório no GitLab](6-integracao-continua/6-3-configurando-um-repositorio-no-gitlab.md)
* [6.4 Branch e merge](6-integracao-continua/6-4-branch-e-merge.md)
* [6.5 Pipeline de Integração Contínua com GitLab CI/CD](6-integracao-continua/6-5-pipeline-de-integracao-continua-com-gitlab-ci-cd.md)

## 7. Entrega Contínua <a href="#7-entrega-continua" id="7-entrega-continua"></a>

* [7.1 Introdução](7-entrega-continua/7-1-introducao.md)
* [7.2 Implantação automática no Docker Hub](7-entrega-continua/7-2-implantacao-automatica-no-docker-hub.md)
* [7.3 Implantação automática no Heroku](7-entrega-continua/7-3-implantacao-automatica-no-heroku.md)
* [7.4 Implantação automática no Google Kubernetes Engine (GKE)](7-entrega-continua/7-4-implantacao-automatica-no-kubernetes.md)
* [7.5 Testando tudo junto](7-entrega-continua/7-5-testando-tudo-junto.md)

## 8. Model serving <a href="#8-model-serving" id="8-model-serving"></a>

* [8.1 Introdução](8-model-serving/8-1-introducao.md)
* [8.2 Model serving com mlserver](8-model-serving/8-2-model-serving-com-mlserver.md)
* [8.3 CI/CD com GitLab e mlserver](8-model-serving/8-3-cicd-com-gitlab-e-mlserver.md)
* [8.4 Testando tudo junto](8-model-serving/8-4-testando-tudo-junto.md)

## 9. Model serving batch <a href="#9-model-serving-batch" id="9-model-serving-batch"></a>

* [9.1 Introdução](9-model-serving-batch/9-1-introducao.md) 
* [9.2 Spark](9-model-serving-batch/9-2-spark.md) 
* [9.3 Airflow](9-model-serving-batch/9-3-airflow.md) 
* [9.4 Testando tudo junto](9-model-serving-batch/9-4-testando-tudo-junto.md) 

## 10. MLOps com mlflow <a href="#10-mlops-com-mlflow" id="10-mlops-com-mlflow"></a>

* [10.1 Introdução](10-mlops-com-mlflow/10-1-introducao.md)
* [10.2 Visão geral do MLflow](10-mlops-com-mlflow/10-2-visao-geral-do-mlflow.md)
* [10.3 Configuração do MLflow](10-mlops-com-mlflow/10-3-configuracao-do-mlflow.md)
* [10.4 Testando MLflow](10-mlops-com-mlflow/10-4-testando-mlflow.md)

## 11. MLOps com Kubeflow<a href="#11-mlops-com-kubeflow" id="11-mlops-com-kubeflow"></a>

* [11.1 Visão geral do Kubeflow](11-mlops-com-kubeflow/11.1-visao-geral-kubeflow.md)
* [11.2 Configuracão](11-mlops-com-kubeflow/11.2-configuracao.md)
* [11.3 Kubeflow Pipeline](11-mlops-com-kubeflow/11.3-kubeflow-pipeline.md)
* [11.4 Kserve](11-mlops-com-kubeflow/11.4-kserve.md)
* [11.5 Testando tudo junto](11-mlops-com-kubeflow/11.5-testando-tudo-junto.md)

## 12. Conclusão <a href="#12-conclusao" id="12-conclusao"></a>

* [Conclusão](12-conclusao/conclusao.md)
