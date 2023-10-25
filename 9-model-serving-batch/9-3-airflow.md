# 9.3 Apache Airflow

## 9.3.1 História

A Airnb iniciou como startup e tomou proporções globais, o que gerou uma complexidade na orquestracão dos fluxos de dados.
Em 2014 iniciou a criação do Airflow para facilitar a cordenação publicado em 2015.

[Publicação de 2015 no medium da Airbnb por Maxime Beauchemin](https://medium.com/airbnb-engineering/airflow-a-workflow-management-platform-46318b977fd8)

Desde a publicação a ferramenta ganhou força e foi encubada pela Apache Foundation em 2016.

## 9.3.3 Arquitetura

Os principais [componentes do Airflow](https://airflow.apache.org/docs/apache-airflow/stable/concepts/overview.html) são:

- **Scheduler**: Responsável por agendar a execucão das DAGs
- **WebServer**: WebUi para mamipulação dos medatados e DAGs
- **Workers**: Reponsável pela execução dos processo
- **Metadata** databases: Responsável por armazenar os metadados do Airflow
- **Dag Directory**: Contem os arquivos de DAGs

![Diagrama de arquitetura do Airflow](https://airflow.apache.org/docs/apache-airflow/stable/_images/arch-diag-basic.png)

Os workflows do Airflow são representados por DAGs

![DAG](https://airflow.apache.org/docs/apache-airflow/stable/_images/edge_label_example.png)

## 9.3.4 Preparando container com Airflow

Para preparar as configurações do Airflow crie uma pasta serving-batch/airflow.

```docker
FROM apache/airflow:2.6.1 AS airflow

RUN python3 -m pip install --upgrade pip wheel setuptools && \
    python3 -m pip cache purge

COPY requirements.txt /tmp/
RUN python3 -m pip install -r /tmp/requirements.txt && \
    python3 -m pip cache purge

ENV AIRFLOW_HOME=/opt/airflow

ENTRYPOINT "airflow" "standalone"
```

Vamos usar o airflow standalone para fins didáticos, para implementacões em produções usar a [documentacão oficial](https://airflow.apache.org/docs/apache-airflow/stable/production-deployment.html)

O arquivo de docker compose nos ajuda a gerir os containers. Neste exemplo vamos criar um volume para as dags e os modelos. Copie o modelo joblib na pasta model do Airflow.

```yaml
version: '3'
services:
    airflow:
        build: .
        ports:
        - 8080:8080
        volumes:
        - ./dags:/opt/airflow/dags
        - ./model:/model
```

O arquivo de requirimets segue as mesmas versões das bilbiotecas que usamos no spark. Repare que também incluimos o plugin do Apache Livy do Spark que será utilizado para integrar o Spark com o Airflow.

```python
pandas==1.3.5
nltk==3.7
scikit-learn==1.0.2
apache-airflow-providers-apache-livy==3.5.0
joblib==1.1.0
pyarrow==8.0.0
```

Inicialize o airflow com o docker-compose e verifique a WebUi na url [localhost:8080](http://localhost:8080).
Com a WebUi é possível acompanhar e operar as execução das DAGs. Explore a [documentação da WebUI](https://airflow.apache.org/docs/apache-airflow/stable/ui.html) para o aprofundamento.

O exemplo a seguir traz a utilizacão do
[Bash Operator](https://airflow.apache.org/docs/apache-airflow/stable/tutorial.html), operador do Airflow que executa um comando Bash nos Workers do Airflow.

```python
from datetime import datetime, timedelta
from textwrap import dedent
import joblib

# The DAG object; we'll need this to instantiate a DAG
from airflow import DAG

# Operators; we need this to operate!
from airflow.decorators import dag, task
from airflow.operators.bash import BashOperator
from airflow.operators.python_operator import PythonOperator

from airflow.utils.task_group import TaskGroup

from airflow.providers.apache.livy.operators.livy import LivyOperator

with DAG(
    'bash-operator',
    # These args will get passed on to each operator
    # You can override them on a per-task basis during operator initialization
    default_args={
        'depends_on_past': False,
        'email': ['airflow@example.com'],
        'email_on_failure': False,
        'email_on_retry': False,
        'retries': 1,
        'retry_delay': timedelta(minutes=5),
    },
    description='A simple tutorial DAG',
    schedule_interval=None,
    start_date=datetime(2021, 1, 1),
    catchup=False,
    tags=['example'],
) as dag:

    with TaskGroup(group_id='group_for') as tg_for:
        for i in range(1,5):
            t1 = BashOperator(
                task_id=f'print_date_t_for{i}',
                bash_command='date',
            )

    with TaskGroup(group_id='group_sleep') as tg1:
        t2 = BashOperator(
            task_id='sleep_t2',
            depends_on_past=False,
            bash_command='sleep 5',
            retries=3,
        )

        t3 = BashOperator(
            task_id='print_date_t3',
            bash_command='date',
        )

    t4 = BashOperator(
        task_id='print_date_t4',
        bash_command='date',
    )

    tg_for >> [t2, t3] >> t4 
```

Faça teste com a dependência entre as Tasks e os [TaksGroups](https://airflow.apache.org/docs/apache-airflow/stable/concepts/dags.html?highlight=taskgroup#taskgroups) e veja o resultado na WebUi do Airflow.

O Scheduler do Airflow tem vários recursos de periodicidade e triggers de execução.

Explore a [documentacão](https://airflow.apache.org/docs/apache-airflow/stable/_api/airflow/models/dag/index.html) de parametrizacão das Dags, altere o pipeline e veja o resultado na WebUI.

Vamos explorar o [Python Operator](https://airflow.apache.org/docs/apache-airflow/stable/howto/operator/python.html).

Inclua a seguinte função na sua DAG:

```python
@task(task_id="print_the_context_t5")
def print_context(ds=None, **kwargs):
    """Print the Airflow context and ds variable from the context."""
    print(kwargs)
    print(ds)
    return 'Whatever you return gets printed in the logs'
```

O decorator @task indica que esta função é uma task do Airflow.

Inclua ela no fim como tarefa5 e veja o resultado:

```python
t5 = print_context()
```

```python
tg_for >> [t2, t3] >> t4 >> t5 
```

Repare que a funcão é executada e o contexto da DAG é apresentado no log das tasks.

Agora que já sabemos como orquestrar um compando Python em uma DAG, vamos simular a inferência do modelo em uma Task Python.

```python
@task(task_id="inferencia_t6")
def predict(ds=None, **kwargs):
    input_message = ["Figura Transformers Prime War Deluxe - E9687 - Hasbro",  "Senhor dos aneis", "Senhor dos anéis"]
    pipe = joblib.load("/model/classificador-produtos.joblib")
    final_prediction = pipe.predict(input_message)
    print("Predicted values:")
    print(",".join(final_prediction))
    return 'sucesso'
```

Inclua essa task no final da sua DAG como Task6 e veja que é possível executar a inferência dentro de uma Tarefa Python no Airflow. Explore o código para ler de arquivos externos, executar a inferência e gravar o resultado em um arquivo de saída.

## 9.3.5 Data-aware schedulling

É possivel controlar dependencia entre DAGs via [Task Sensor](https://airflow.apache.org/docs/apache-airflow/stable/howto/operator/external_task_sensor.html) ou desde a versão 2.4, quando o conceito de Dataset foi criado, é possível ter o mesmo resultado com [Data-aware](https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/datasets.html).

Com este novo conceito uma DAG pode depender de um Dataset para ser iniciada e as tasks dentro de uma DAG podem gerar versões de Datasets. Assim é possível ter dependencia entre DAGs e um visão parcial de Data Lineage na interface de Dataset.

Vamos gerar duas novas DAGs de teste para visualizarmos esta dependencia:

```python

from datetime import datetime, timedelta
from airflow.datasets import Dataset
from airflow.operators.bash import BashOperator
from airflow import DAG

with DAG(
    'DAG1',
    schedule_interval=None,
    start_date=datetime(2021, 1, 1)
):
    t1 = BashOperator(
                task_id=f'GenerateDataset1',
                outlets=[Dataset("Dataset1")],
                bash_command='date',
            )

with DAG(
    'DAG2',
    schedule=[Dataset("Dataset1")],
    start_date=datetime(2021, 1, 1)
):
    t1 = BashOperator(
                task_id=f'GenerateDataset2',
                outlets=[Dataset("Dataset2")],
                bash_command='date',
            )
```
