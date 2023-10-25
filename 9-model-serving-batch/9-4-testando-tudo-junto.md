# 9.4 Testando tudo junto

Para integrar o Airflow com o Spark vamos utilizar o [Apache Livy](https://livy.apache.org).
O Apache Livy é uma aplicação que fornece uma API REST para integragir com o contexto de execucão do Spark.

## Preparando Apache Livy

Da mesma forma que fizemos para o Aiflow e para o Spark, crie uma pasta serving-batch/livy para prepararmos a imagem do conteiner do Livy.

O Dockerfile do Livy é semelhante ao do Spark, mas inclui a instalação do Livy.

```docker
FROM python:3.10.11-slim

ENV SPARK_VERSION=3.4.0
ENV HADOOP_VERSION=3
ENV LIVY_VERSION=0.7.1
ENV SPARK_VERSION_STRING=spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
ENV LIVY_VERSION_STRING=apache-livy-${LIVY_VERSION}-incubating-bin
ENV SPARK_HOME=/spark
ENV LIVY_HOME=/livy

ADD http://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/${SPARK_VERSION_STRING}.tgz /
RUN tar xzf ${SPARK_VERSION_STRING}.tgz \
    && mv ${SPARK_VERSION_STRING} ${SPARK_HOME} \
    && rm ${SPARK_VERSION_STRING}.tgz

ENV OPENJDK_VERSION=17

RUN apt-get -y update && \
    apt-get install --no-install-recommends -y \
    openjdk-${OPENJDK_VERSION}-jdk \
    procps zip libssl-dev libkrb5-dev libffi-dev libxml2-dev libxslt1-dev python-dev build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD http://dlcdn.apache.org/incubator/livy/${LIVY_VERSION}-incubating/${LIVY_VERSION_STRING}.zip /
RUN unzip ${LIVY_VERSION_STRING}.zip \
    && mv ${LIVY_VERSION_STRING} ${LIVY_HOME} \
    && rm ${LIVY_VERSION_STRING}.zip \
    && mkdir ${LIVY_HOME}/logs    


RUN python3 -m pip install --upgrade pip wheel setuptools && \
    python3 -m pip cache purge

COPY requirements.txt /tmp/
RUN python3 -m pip install -r /tmp/requirements.txt && \
    python3 -m pip cache purge

ENV PATH=/usr/local/openjdk-${OPENJDK_VERSION}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/spark/bin:/livy/bin
ENV PYSPARK_PYTHON=/usr/bin/python3
ENV SPARK_CONF_DIR=/spark/conf
ENV PYSPARK_PYTHON=/usr/local/bin/python3

COPY livy.conf ${LIVY_HOME}/conf
COPY spark-defaults.conf ${SPARK_HOME}/conf

RUN ln -sf /usr/local/bin/python3 /usr/bin/python

EXPOSE 8080
```

O Livy tem um arquivo de configuração chamado livy.conf, ele é copiado para a imagem do container.
Gere um arquivo na pasta de acordo com o exemplo:

```conf
livy.spark.master = local 
livy.server.port = 8998
livy.file.local-dir-whitelist = /src
```

Exixtem muitas outras opções de configurações, como mostra o [exemplo](https://github.com/apache/incubator-livy/blob/master/conf/livy.conf.template).

O Livy també precisa dos arquivos requirements.txt e spark.conf mostrado na sessão [10.2](10-2-spark.md). Remova as dependencias exclusivas do jupyter para gerar o requirements do livy.

Agora no diretorio serving-batch vamos gerar o docker-compose para fazer a integracão entre os componentes:

```yaml
version: '3'
services:
    airflow:
        image: airflow
        ports:
        - 8080:8080
        volumes:
        - ./dags:/opt/airflow/dags
        - ./model:/model
    livy:
        build: .
        ports:
            - 8998:8998
            - 7077:7077
        command: livy-server
        volumes:
            - ./src:/src
            - ./model:/model
            - ./data:/data
```

Repare que os volumes apontam para os diretórios locais e precisamos copiar os dados e o modelo treinado para as pastas.
Vamos rodar o airflow junto para simular a integracão, e referenciamos a imagem "airflow" dentro do docker compose, por isso gere uma tag da imagem do airflow executando o seguinte comando na pasta do airflow:

```bash
docker build . -t airflow 
```

Repare que isso gerou uma tag para a imagem do airflow construída a partir do diret
orio base.

Agora sim podemos fazer o build do livy através do comando do docker-compose.

## Código da aplicacão Spark

Copie o exemplo [pi.py](https://github.com/apache/spark/blob/master/examples/src/main/python/pi.py) para pasta /src. Ele será o primeiro teste com Spark e Livy.

```python
import sys
from random import random
from operator import add

from pyspark.sql import SparkSession


if __name__ == "__main__":
    """
        Usage: pi [partitions]
    """
    spark = SparkSession\
        .builder\
        .appName("PythonPi")\
        .getOrCreate()

    partitions = int(sys.argv[1]) if len(sys.argv) > 1 else 2
    n = 100000 * partitions

    def f(_:int) -> float:
        x = random() * 2 - 1
        y = random() * 2 - 1
        return 1 if x ** 2 + y ** 2 <= 1 else 0

    count = spark.sparkContext.parallelize(range(1, n + 1), partitions).map(f).reduce(add)
    print("Pi is roughly %f" % (4.0 * count / n))
```

## Airflow Livy Operator

O Airflow tem um operador para implementar a integração com o Livy. Verifique a [documentacão do operador](https://airflow.apache.org/docs/apache-airflow-providers-apache-livy/stable/_api/airflow/providers/apache/livy/operators/livy/index.html).
O seguinte trecho é uma chamada de task para o operador do Livy:

```python
    livy_python_task = LivyOperator(
        task_id='livy_task', 
        file='/src/pi.py', 
        polling_interval=60, 
        livy_conn_id='livy_default',
        executor_memory="1g",
        executor_cores=2,
        driver_memory="1g",
        driver_cores=1,
        num_executors=1)
```

Este operador utiliza a [conexão default do livy](https://airflow.apache.org/docs/apache-airflow-providers/core-extensions/connections.html) para obter configurações como endpoint e porta para conexão.

Execute sua DAG e veja o resultado.

## Executando a inferência

Da mesma forma que executamos o pi.py podemos executar a inferência do modelo, assim como já vimos na sessão [10.2](10-2-spark.md).

```python

import sys
from random import random
from operator import add

from pyspark.sql import SparkSession

from pyspark.sql.functions import monotonically_increasing_id
from pyspark.sql.functions import pandas_udf, PandasUDFType  
import pandas as pd
import joblib

if __name__ == "__main__":
    spark = SparkSession\
        .builder\
        .appName("InferenciaProdutos")\
        .getOrCreate()

    pipe = spark.sparkContext.broadcast(joblib.load("/model/classificador-produtos.joblib"))

    # Define Pandas UDF
    @pandas_udf("string")
    def predict(descricao: pd.Series) -> pd.Series:
        msg_predict = pipe.value.predict(descricao.tolist())
        return pd.Series(msg_predict)

    df_input = spark.read.option("delimiter", ';').option("header","true").csv("/data/produtos.csv")

    df_input = df_input.filter("descricao is not null").select("descricao").withColumn("id", monotonically_increasing_id())

    df_predict = df_input.withColumn("predict", predict("descricao"))    

    df_predict.limit(10).write.mode('overwrite').parquet("/data/predicoes")

```

Inclua essa nova task na sua DAG e verifique o resultado.

## Kubernetes

Existem outras formas de integrar o Airflow com o Spark, uma delas é usando a execuão nativa do Spark com Kubernetes e o operador de Airflow para Spark.
Explore a documentação do [Apache Spark](https://spark.apache.org/docs/latest/running-on-kubernetes.html) e [Apache Airflow](https://airflow.apache.org/docs/apache-airflow/stable/kubernetes.html) para configuração em ambiente Kubernetes.
