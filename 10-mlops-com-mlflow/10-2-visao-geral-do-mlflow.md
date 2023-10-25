# 10.2 Visão geral do MLflow

O [MLflow](https://mlflow.org/) é uma ferramenta baseada em quatro componentes principais:

* MLflow Tracking: uma API e uma UI para registro (_logging_) de parâmetros, versões de código, métricas e artefatos em uma execução de um experimento. Esse registro permite o rastreamento e a comparação de cada execução.
* MLflow Projects: um formato padronizado para empacotar e reutilizar código de machine learning utilizado normalmente para gerar modelos. Esse formato permite que qualquer pessoa consiga reproduzir a execução de um experimento em qualquer máquina.
* MLflow Models: uma convenção para empacotamento de modelos de machine learning de forma a possibilitar sua execução sem a necessidade de instalação manual das ferramentas e dependências.
* MLflow Registry: um armazenamento centralizado de modelos, para que os desenvolvedores possam publicar e reutilizar seus modelos.

O MLflow pode ser útil em diferentes cenários, desde cientistas de dados trabalhando individualmente até equipes maiores, pois ele oferece ferramentas úteis para diferentes tarefas. Outra característica do MLflow é sua abordagem modular. Não é necessário utilizar todos os componentes, apenas aquele ou aqueles que forem mais interessantes.

Além disso, vale destacar que existem duas versões do MLflow: a versão open source, que utilizaremos aqui, e a [versão gerenciada](https://databricks.com/product/managed-mlflow), um serviço contratado da Databricks e que tem algumas funções adicionais. 

A [documentação do MLflow](https://mlflow.org/docs/latest/index.html) tem uma série de tutoriais e exemplos para compreender os conceitos básicos. Para executar os tutoriais, recomendamos os seguintes passos:

1. Instale [miniconda](https://docs.conda.io/en/latest/miniconda.html)
2. Abra um terminal do anaconda
3. Crie um ambiente virtual com uma versão recente do Python:

Para descobrir quais versões do Python estão disponíveis:

```sh
conda search python
```

Para criar e ativar um ambiente virtual:

```sh
conda create --name mlflowtutorial1 python=3.10.4
conda activate mlflowtutorial1
```

Recomendamos a criação de um ambiente virtual para cada tutorial, para manter o isolamento dos ambientes.

Também é importante perceber que o mlflow não roda completamente no Windows. Pode-se utilizar uma máquina virtual Linux ou Mac para esses testes, ou utilizar desenvolvimento remoto via SSH. Neste último caso, ao subir os serviços, como por exemplo `mlflow ui`, que abre a interface visual, é necessário especificar que o serviço deve estar acessível a outras máquinas também, por exemplo:

```sh
mlflow ui -h 0.0.0.0
```

Finalmente, os tutoriais assumem que, ao executar um projeto no GitHub utilizando `mlflow run`, existe um _branch_ chamado "master". Caso não exista, basta especificar o nome do _branch_ no parâmetro `version`:

```sh
mlflow run --version main https://gitlab.com/daniel.lucredio/mlflowtutorial1.git -P alpha=5.1
```

Neste momento da leitura, recomendamos o [tutorial de regressão linear](https://mlflow.org/docs/latest/tutorials-and-examples/tutorial.html) (exceto a parte de hospedagem no MLServer, que no momento da escrita deste livro está em estágio experimental) e o [tutorial para empacotamento de experimentos em Docker](https://github.com/mlflow/mlflow/tree/master/examples/docker).