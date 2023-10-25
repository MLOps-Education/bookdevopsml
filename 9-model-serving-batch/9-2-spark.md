# 9.2 Introdução ao Apache Spark

[Apache Spark](https://spark.apache.org) é uma ferramenta de processamento paralelo para ciência de dados, engenharia de dados e machine learning, que foi criada em uma pesquisa do Amplab da universidade de Berkeley em 2009 e se tornou open source em 2010 com a publicação do paper:

<https://people.csail.mit.edu/matei/papers/2010/hotcloud_spark.pdf>

O conceito de RDD (Resilient Distributed Datasets) do spark foi bastante difundido com o seguinte paper:

<https://people.csail.mit.edu/matei/papers/2012/nsdi_spark.pdf>

E em 2013 foi encubada pela [Apache Software Foundation](https://www.apache.org).

## 9.2.2 Conceitos

### RDD (Resilient Distributed Datasets)

RDDs é uma abstração de uma coleção de dados distribuído que permite a criação de programas para manipular os dados distribuidos. RDDs são coleções imutáveis distribuídas que podem ser armazenadas em memória ou disco dentro de um cluster de servidores. RDDs são resilientes pois possuem a receita para a sua reconstrução em caso falhas. Existem dois tipos de [operações](https://spark.apache.org/docs/2.1.1/programming-guide.html#rdd-operations) dos RDDs, ações e transformações. As transformações executadas nos RDDs são "lazy", isto é, as transformaões não são executadas no momento da execucão da instrução de código, mas sim no momento que é executado uma ação.
Apache Spark guarda a receita para as transfomações e espera até uma acão para a execucão das transformações anteriores dependentes.

### Dataframe

Assim como RDDs um DataFrame é uma coleção imutável de dados distribuídos, mas os DataFrames também possúem uma estrutura de colunas nomeadas como uma tabela de um banco de dados relacional. Com os Dataframes é possível criar uma abstracão auto nível para manipular e transformar os dados. É possivel usar uma linguagem própria de manipulação em uma das linguagens compatíveis ou até mesmo SQL.

### Dataset

Dataset foi introduzido na versão 1.6 do Spark e a partir da versão 2.0 as APIs de Dataframe e Dataset se uniram.
Dataset tem algumas vantagens de performance com relação ao Dataframe principalmente porque tem uma API de type-safe que guarda os tipos das colunas dos dados durante o processo de build.

### MLib

MLib é a bibliotéca de ML do Apache Spark que tem a implementacão de alguns algoritmos de ML para processamento em paralelo.
Com o processamento paralelo do Spark e a MLib é possível ter escalabilidade nos treinamento e inferência dos modelos.

### ML Pipelines

ML Pipelines ajuda a organizar e processar as tarefas de pré-processamento, extracão de variáveis, infernecia e validação e todas as fases de pipeline de ML.

### GraphX

GraphX é é um componente do Apache Spark para processamento paralelo de grafos, eles implementa uma abstracão de grafos em cima dos RDDs.

### Spark Streaming

Spark Streaming habilita o processamento de dados realtime com integracão com fontes como Apache Kafka e outros.
A abstração DStream (Discretized Stream), que foi contruida a partir dos RDDs, representa um stream de dados divididos em pequenos lotes e permite que os dados processados sejam carregados em bancos de dados, filesystems e dahsboards.

## 9.2.3 Arquitetura

[Componentes do Apache Spark](https://spark.apache.org/docs/latest/cluster-overview.html)

![Arquitetura do Spark](https://spark.apache.org/docs/latest/img/cluster-overview.png)

- **Driver Program**: Executa o sparkContext que é responsável por negociar o recurso com o gerenciador de cluster e orquestra a execucão dos executores nos Worker nodes disponibilizados.
- **Executors**: Responsáveis pela execução das tasks e gestão do cache e disco.
- **Cluster Manager**: Responsável pela gestão do recurso do cluster. Apache Spark é compativel com Yarn, Mesos, Standalone mode e Kubernetes.
- **Jobs, Stages e Tasks:** A execucão de uma ação no RDD gera um [Job](https://spark.apache.org/docs/latest/programming-guide.html#rdd-operations) para processar aquela ação. O Job contem uma sequencia de [Stages](https://spark.apache.org/docs/latest/web-ui.html#stages-tab) que agrupam as Tasks que são executadas em paralelo.

## 9.2.4 Primeiros passos com Apach Spark

A seguir vamos preparar o ambiente Docker para executarmos nossos testes.
Crie uma pasta serving-batck/spark para começar a trabalhar com os arquivos do Spark.
A imagem base para execucão do Apache Spark é python:3.10.11-slim.

```docker
FROM python:3.10.11-slim
```

Para criar nosso ambiente com Apche Spark vamos utilizar a os [binários](http://apache.mirror.iphh.net/spark/) oficiais da Apache.

```docker
ENV SPARK_VERSION=3.4.0
ENV HADOOP_VERSION=3
ENV SPARK_VERSION_STRING=spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
ENV SPARK_HOME=/spark

ADD http://apache.mirror.iphh.net/spark/spark-${SPARK_VERSION}/${SPARK_VERSION_STRING}.tgz /

RUN tar xzf ${SPARK_VERSION_STRING}.tgz \
    && mv ${SPARK_VERSION_STRING} ${SPARK_HOME} \
    && rm ${SPARK_VERSION_STRING}.tgz
```

A imagem do python não tem o java instalado. O trecho a seguir instala os binários do openjdk, instala dependencias do SO e faz atualizacão das ferramentas pip, wheel e setuptools.

```docker
ENV OPENJDK_VERSION=17

RUN apt-get -y update && \
    apt-get install --no-install-recommends -y \
    openjdk-${OPENJDK_VERSION}-jdk \
    procps zip libssl-dev libkrb5-dev libffi-dev libxml2-dev libxslt1-dev python-dev build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip wheel setuptools && \
    python3 -m pip cache purge
```

Para instalatar as dependências de Python vamos utilizar o requirements.txt:

```docker
COPY requirements.txt /tmp/
RUN python3 -m pip install -r /tmp/requirements.txt && \
    python3 -m pip cache purge
```

A seguir vamos habilitar as extensões do jupyter:

```docker
RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension 
```

Definir as variáveis de ambiente para executarmos o Pyspark com o Jupyter como driver:

```docker
ENV PATH=/usr/local/openjdk-8/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/spark/bin
ENV PYSPARK_PYTHON=/usr/local/bin/python3
ENV SPARK_CONF_DIR=/spark/conf
ENV PYSPARK_DRIVER_PYTHON=jupyter
ENV PYSPARK_DRIVER_PYTHON_OPTS="notebook --port=8888 --ip '0.0.0.0' --NotebookApp.token='' --NotebookApp.password='' --allow-root"
```

Setup das configurações padrões do Apache Spark:

```docker
COPY spark-defaults.conf ${SPARK_HOME}/conf
```

Difinicão do entrypoint e diretório de trabalho:

```docker
RUN mkdir /notebooks
WORKDIR /notebooks
ENTRYPOINT [ "pyspark" ]
```

No nosso arquivo de requirements vamos colocar as mesmas dependências para o treinamento do modelo de categoria de modelos e também o pyarrow para usarmos UDFs pandas com Spark e o sparksql-magic para facilitar os comandos de Spark SQL.

```python
jupyter==1.0.0
ipywidgets==7.7.0
sparksql-magic==0.0.3
pandas==1.3.5
nltk==3.7
scikit-learn==1.0.2
joblib==1.1.0
pyarrow==8.0.0
```

Para facilitar as configurações das configuracões do spark é comum alterarmos o spark-default.conf. 
Neste caso vamos usar somente para definir o python como python3, mas podemos alterar qualquer configuração do spark:

```bash
# Example:
# spark.master                     spark://master:7077
# spark.eventLog.enabled           true
# spark.eventLog.dir               hdfs://namenode:8021/directory
# spark.serializer                 org.apache.spark.serializer.KryoSerializer
# spark.driver.memory              5g
# spark.executor.extraJavaOptions  -XX:+PrintGCDetails -Dkey=value -Dnumbers="one two three"

spark.pyspark.python python3
```

Como já aprendemos nos capítulos anteriores vamos criar o docker-compose para facilitar a execucão e build:
Vamos configurar volumew locais para acessar os notebooks, os dados e modelos.

```yaml
version: '3'
services:
    jupyter:
        build: .
        ports:
        - 8888:8888
        - 4040:4040
        volumes:
        - ./notebooks:/notebooks
        - ./model:/model
        - ./data:/data
```

Agora com o docker-compose pronto podemos subir a instancia do spark e acessar o Jupyter na porta 8888 [local](http://local:8888).

```bash
docker-compose up
```

O Apache Spark inicia uma [WebUi](http://localhost:4040) na porta 4040 para acompanhamento do processamento.
Esta [WebUi](http://localhost:4040) é iníciada somente quando é gerado o Driver para processamento.
Para verificarmos vamos criar um kernel no Jupyter e iniciar a sessão do spark.
Copie o seguinte trecho para o notebook:

```python
spark
```

Verifique que depois da inicialização da sessão do Spark conseguimos acessar a [WebUi](http://localhost:4040):

Agora com nosso ambiente pronto vamos entender as operacões principais do Apache spark.
Como vimos na sessão de conceitos podemos executar ações e transformações nos RDDs e as transformações são "lazy".
Vamos comprovar isso na prática.
Antes de carregar o CSV copie o arquivo produtos.csv para a pasta ./data.
A API de Dataset e Dataframe do Spark é parecida com a do pandas, o trecho de código a seguir carrega um arquivo CSV, o mesmo que usamos nos módulos anteriores:

```python
df_input = spark.read.option("delimiter", ';').option("header","true").csv("/data/produtos.csv")
```

Verifique que depois da execucão do código podemos ver na [WebUi](http://localhost:4040) a criação de um Job para carregar o CSV.
Agora vamos começar a criar as transformcões.

Criação de uma nova coluna do resultado da juncão de um prefixo e a descrição:

```python
from pyspark.sql.functions import concat, lit
df_trans1 = df_input.withColumn("nova_coluna", concat(lit("Prefixo"),"descricao"))
```

Repare que não foi gerado nenhum Job para processamento na [WebUi](http://localhost:4040):

Vamos agora o count por categoria:

```python
df_trans2 = df_trans1.groupBy("categoria").count()
```

Repare que ainda não foi gerado nenhum Job para processamento na [WebUi](http://localhost:4040):

Agora vamos imprimir o resultado:

```python
df_trans2.show()
```

Repare que agora foi gerado um Job na [WebUi](http://localhost:4040) para imprimir os resultados no notebook.
Agora vimos na prática o conceito de "Lazy evaluation" do Spark.
Explore a [documentacão oficial da WebUi](https://spark.apache.org/docs/latest/web-ui.html) para mais detalhes.

O Apache Spark também possibilita a execução de SQL com o API do Spark SQL.
O Spark SQL pode ser integrado com catálogo de dados externos como o Hive Metastore, mas para fim didáticos vamos explorar o catalogo local do Spark.

Por padrão o Spark cria um catalogo local, veja que o resultado do comando "show tables":

```python
spark.sql("show tables")
```

Para facilitar a execucão dos comando SQL do Spark é possível usar os Magics comands do Jupyter, como usamos a integração nativa entre Jupyter e Pyspark, temos o pacote sparksql-magic. Para habilitar o magic execute os seguinte comandos no notebook:

```python
%load_ext sparksql_magic
%alias_magic sql sparksql
```

Agora podemos executar comando para listar as tabelas com o magic do jupyter:

```sql
%%sql
show tables
```

Vamos criar uma view temporária para emular uma tabela no nosso catalogo global.
Este comando cria uma view temporária para nosso dataframe da transformação 2:

```python
df_trans2.createTempView("trans2")
```

Agora se listarmos as tabelas novamente vamos verificar que existe uma tabela no nosso catálogo global:

Agora vamos consultar a table com SQL:

```sql
%%sql
select * from trans2 limit 10
```

Explore comando SQL com seguinto a syntaxe da [documentação oficial](https://spark.apache.org/docs/latest/sql-ref-syntax.html).

## 9.2.5 Portando a inferência do modelo para Spark

Agora que já preparamos nosso ambiente e passamos pelos comandos básicos do Apache Spark vamos criar um processo para executar a inferência da categorição de produtos. Lembrando que a inferencia com o Apache Spark é realmente necessária quando estamos lidando com um volume grande de dados, para fins didáticos vamos usar o mesmo CSV de prondutos usado nos capítulos anteriores.
Para executar a inferencia vamos criar uma [UDF pandas para Apache Spark](https://spark.apache.org/docs/latest/api/python/reference/api/pyspark.sql.functions.pandas_udf.html).

Vamos iniciar a conversão do código para a inferência, para isso primeiramente vamos gerar um DataFrame para teste:

```python
df_teste = spark.createDataFrame(
    [
        (1, "Figura Transformers Prime War Deluxe - E9687 - Hasbro"),  # create your data here, be consistent in the types.
        (2, "Senhor dos aneis"),
        (3, "Senhor dos anéis")
    ],
    ["id", "descricao"]  # add your column names here
)
```

Este dataframe de teste tem um id, e a descricão dos produtos.
Podemos listar o dataframe convertendo-o para pandas:

```python
df_teste.toPandas()
```

Como vamos usar o mesmo modelo é necessário gerar o joblib, da mesma forma que foi feito nos capítulos anteriores.

Agora vamos gerar a UDF pandas para executar a predicão do modelo:
Antes de executar os trechos a seguir, faca o treinamento com o notebook classificador-produtos.ipynb e copie o arquivo joblib no diretório ./model.

```python
from pyspark.sql.functions import pandas_udf, PandasUDFType  
import pandas as pd
import joblib

pipe = sc.broadcast(joblib.load("/model/classificador-produtos.joblib"))
print(pipe.value)
# Define Pandas UDF
@pandas_udf("string")
def predict(descricao: pd.Series) -> pd.Series:
    msg_predict = pipe.value.predict(descricao.tolist())
    return pd.Series(msg_predict)
```

O primeiro comando para criar a UDF é disponibilizar o serializado do modelo para todos os workers. Lembre que o Spark é executado de forma distribuída em producão, por isso é necessário que todos os executores tenham acesso ao modelo.
O Spark possibilita a criação de [UDF (User Defined Functions)](https://spark.apache.org/docs/latest/sql-ref-functions-udf-scalar.html), para a inferência das categorias vamos usar uma [UDF pandas para Apache Spark](https://spark.apache.org/docs/latest/api/python/reference/api/pyspark.sql.functions.pandas_udf.html).
Para criar a UDF usamos o decorator @pandas_udf com o parametro "string" para definir o tipo do resultado da UDF.
A declaração da função deve usar os hints de tipos do Python.

Agora com a UDF pronta vamos executar a predição:

```python
df_predict = df_teste.withColumn("predict", predict("descricao"))
```

Repare como resultado temos uma coluna nova "predict" com o resultado da predição.
Executamos o cenário de teste, mas como funciona em um cenário produtivo?
Vamos emular um cenário produtivo que consultamos um CSV de entrada, executamos a inferência para todos os registros e por fim devolvemos o dados para o storage com as inferências prontas.
Para fins didáticos vamos usar o mesmo CSV de produtos:

```python
from pyspark.sql.window import *
from pyspark.sql.functions import monotonically_increasing_id

df_input = spark.read.option("delimiter", ';').option("header","true").csv("/data/produtos.csv")
df_input = df_input.select("descricao").withColumn("id", monotonically_increasing_id())
```

Vamos criar uma chave para cada descrição para simular um ID.
Agora com o DataFrame criado vamos executar o mesmo código de predicão usado para o teste:

```python
df_predict = df_input.select("id","descricao").withColumn("predict", predict("descricao"))
```

Agora vamos gravar o resultado no disco:

```python
df_predict.write.mode('overwrite').csv("predicoes")
```

Repare que CSV foi gerado com as as predições da categoria do produto.
Nesta sessão aprendemos a executar uma inferência de modelo utilizando o paralelismo do Apache Spark através de UDFs pandas.
