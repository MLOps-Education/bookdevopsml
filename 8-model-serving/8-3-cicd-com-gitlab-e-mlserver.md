# 8.3 CI/CD com GitLab e MLServer

Agora que já sabemos como fazer uso de um servidor de modelos, podemos tentar automatizar o processo de subir os modelos, seguindo os princípios de DevOps. Faremos aqui um exemplo simples que ilustra como um possível ciclo de desenvolvimento pode ser implementado com as ferramentas que já vimos até agora, além de algumas novas que aprenderemos no caminho.

## 8.3.1 Implantação automática do MLServer no Heroku - criando uma imagem Docker personalizada

Já fizemos antes, na [Seção 3.3](../3-producao/3-3-ambiente-de-producao-parte-2.md), a implantação de uma API HTTP no Heroku, utilizando gunicorn e Flask. Também fizemos, na [Seção 7.3](../7-entrega-continua/), a implantação automatizada no Heroku a partir do GitLab. Então o que faremos agora não é nenhuma novidade, exceto pela diferença que estamos usando MLServer ao invés da combinação gunicorn e Flask. Na verdade, o MLServer usa uvicorn e FastAPI, que são muito semelhantes ao gunicorn e Flask.

Comece criando uma nova pasta, com o nome `mlserver`. Na verdade, se quiser apagar a pasta anterior e reutilizar, tudo bem, faremos tudo novamente aqui. Nessa pasta vamos recriar o que fizemos na seção anterior, porém simplificando algumas coisas. Não teremos _runtimes_ customizados e nem modelos pesados como o do BERT, para deixar os processos mais rápidos. Além disso, faremos uso do nginx e MLServer na mesma imagem, para simplificar o deploy no Heroku.

Crie um arquivo chamado `settings.json`, com o conteúdo:

```
{
    "debug": "true"
}
```

O modo debug do MLServer facilita para detectarmos erros e problemas ao longo do processo.

Crie um arquivo `requirements.txt`:

```
mlserver==1.3.2
mlserver-sklearn==1.3.2
mlserver-lightgbm==1.3.2
```

Agora crie um arquivo chamado `default` (sem extensão), para configurar o nginx:

```
server {
    listen $PORT;

    location / {
        root /www;
    }

    location /mlapi/ {
        rewrite /mlapi/(.*)$ /$1 break;
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Crie um arquivo chamado `entrypoint.sh`:

```
#!/bin/bash

mlserver start . &
sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/sites-available/default && nginx -g 'daemon off;' &
   
wait -n
  
exit $?
```

Esses dois últimos reproduzem a configuração que já fizemos antes, então não é necessário explicar nada.

Agora crie o arquivo `Dockerfile`:

```
FROM python:3.10.4

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y nginx && rm -rf /var/lib/apt/lists/*

COPY default /etc/nginx/sites-available/default

WORKDIR /usr/src/app

COPY entrypoint.sh ./
RUN chmod 755 ./entrypoint.sh

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --upgrade "protobuf==3.20.1" # Caso haja problemas com versão do protobuf

COPY models ./
COPY settings.json ./

CMD ["./entrypoint.sh"]
```

Também já fizemos tudo isso antes. A única diferença aqui que vale a pena ressaltar é que estamos usando a imagem não-slim, pois o MLServer depende de algumas bibliotecas que só existem na versão completa da imagem python do docker hub. Fora isso, o Dockerfile faz a instalação e configuração do nginx, a instalação dos pacotes python (incluindo MLServer), e a execução dos dois serviços por meio do script `entrypoint.sh`.

Por último, crie uma estrutura de pastas `models/iris-dtc/1.0`. Dentro dela salve o arquivo [iris-dtc-1.0.joblib](./codigo/iris/iris-dtc-1.0.joblib). É o mesmo que utilizamos na seção anterior, mas substituímos o _underline_ pelo hífen, pois a nomenclatura será importante mais adiante. Crie também um arquivo chamado `model-settings.json`, com o seguinte conteúdo:

```
{
    "name": "iris-dtc",
    "implementation": "mlserver_sklearn.SKLearnModel",
    "parameters": {
        "uri": "iris-dtc-1.0.joblib",
        "version": "1.0"
    }
}
```

Podemos testar. Crie a imagem por meio do comando:

```sh
docker build -t mlserver .
```

E execute:

```sh
docker run -it -p 80:9361 -e PORT=9361 --rm --name mlserver-container mlserver
```

A porta 9361 pode ser substituída por qualquer outra, pois é assim que o Heroku (e outros provedores) fazem ao subir um contêiner.

Faça o teste local, enviando um POST:

```
POST http://localhost/mlapi/v2/models/iris-dtc/versions/1.0/infer
Content-Type: application/json

{
    "inputs": [
        {
            "name": "predict",
            "shape": [1,4],
            "datatype": "FP32",
            "data": [[5  , 3.4, 1.5, 0.2]]
        }
    ]
}
```

Até aqui não há nenhuma novidade. Vamos fazer o processo CI/CD com base nessa imagem, utilizando o GitLab.

## 8.3.2 Implantação automática do MLServer no Heroku - Configurando projetos no Heroku/GitLab

Vá até o GitLab e crie um novo projeto, chamado `mlserver`. Não adicione um arquivo `README.md`, pois iremos enviar nosso conteúdo inicial a partir da pasta que acabamos de criar. Para isso, execute:

```sh
git init --initial-branch=main
git remote add origin https://gitlab.com/daniel.lucredio/mlserver.git
git add .
git commit -m "Initial commit"
git push -u origin main
```

Aliás, esses são os comandos que aparecem no GitLab assim que o novo projeto é criado. Não esqueça de substituir o nome do GitLab pelo seu!

Agora vá até o Heroku e crie uma aplicação, chamada `dlucredio-mlserver` (use seu próprio username). Para simplificar, não faremos aqui as versões de _staging_ e produção como fizemos na [Seção 7.3](../7-entrega-continua/7-3-implantacao-automatica-no-heroku.md), mas você já sabe fazer isso, então vamos seguir adiante.

Ainda no Heroku (canto superior direito), clique em "Account settings", e depois encontre "API Key". Clique em "Reveal". Copie e cole esse valor.

Agora vá até o GitLab, entre no seu projeto, e selecione a opção "Settings" -> "CI/CD" -> "Variables". Vamos adicionar 2 variáveis:

* `HEROKU_API_KEY`: o valor é a chave que acabamos de copiar e colar
* `HEROKU_APP`: coloque o nome do aplicativo no Heroku (`dlucredio-mlserver`)

## 8.3.3 Implantação automática do MLServer no Heroku - Configurando pipeline de deploy no Heroku

Agora crie o arquivo `.gitlab-ci.yml`:

```yml
stages:
  - release
 
variables:
  DOCKER_TLS_CERTDIR: ""

deploy_heroku:
  image: docker:24.0.0
  stage: release
  
  services:
    - docker:24.0.0-dind
  before_script:
    - apk add --no-cache curl
    - apk add --no-cache bash
    - apk add --no-cache nodejs
    - curl https://cli-assets.heroku.com/install.sh | sh
    - docker login --username=_ -p "$HEROKU_API_KEY" registry.heroku.com
  script:
    - heroku container:push web --app $HEROKU_APP
    - heroku container:release web --app $HEROKU_APP
```

Também não tem segredos aqui, pois já fizemos a mesma coisa antes. Na verdade esse _pipeline_ é bem simples, não estamos fazendo testes, nem verificações de qualidade, apenas o deploy. Além disso, o deploy é automático e configurado para rodar a qualquer _commit_, em qualquer _branch_.

Podemos testar. Basta fazer o envio das mudanças para o GitLab e aguardar o deploy ser concluído:

```sh
git add .
git commit -m "Configurando deploy no Heroku"
git push
```

Caso ainda não tenha feito, é necessário configurar um runner para o GitLab. Fizemos isso na [Seção 6.5](../6-integracao-continua/6-5-pipeline-de-integracao-continua-com-gitlab-ci-cd.md).

Se tudo der certo, podemos enviar um POST para o Heroku, e estará tudo funcionando:

```

POST https://dlucredio-mlserver.herokuapp.com/mlapi/v2/models/iris-dtc/versions/1.0/infer
Content-Type: application/json

{
    "inputs": [
        {
            "name": "predict",
            "shape": [1,4],
            "datatype": "FP32",
            "data": [[5  , 3.4, 1.5, 0.2]]
        }
    ]
}
```

Agora temos um processo automatizado para fazer deploy de novos modelos. Por exemplo, se quisermos adicionar nosso modelo de classificação de produtos, basta fazer o seguinte:

1. Crie, nas pasta `models`, o diretório: `classificador-produtos/1.0`. Copie para lá o arquivo [classificador-produtos-1.0.joblib](./codigo/classificador-produtos/classificador-produtos-1.0.joblib) que criamos na última seção. Crie o arquivo `model-settings.json`:

```
{
    "name": "classificador-produtos",
    "implementation": "mlserver_sklearn.SKLearnModel",
    "parameters": {
        "uri": "classificador-produtos-1.0.joblib",
        "version": "1.0"
    }
}
```

Agora basta fazer o envio para o GitLab e aguardar:

```sh
git add .
git commit -m "Adicionando classificador de produtos"
git push
```

Assim que o deploy for concluído, basta testar, fazendo um POST:

```
POST https://dlucredio-mlserver.herokuapp.com/mlapi/v2/models/classificador-produtos/versions/1.0/infer
Content-Type: application/json

{
    "inputs": [
        {
            "name": "predict",
            "shape": [3],
            "datatype": "BYTES",
            "data": [ "boneca", "carrinho", "minecraft" ]
        }
    ]
}
```

## 8.3.4 Em direção à automação completa do processo - colocando notebook no GitLab

Agora que já conseguimos fazer o deploy automático a partir do GitLab para o Heroku, temos uma maior facilidade para manter nossos modelos atualizados. Porém, ainda resta agilizar o processo de envio dos modelos para o GitLab, de forma que possamos rapidamente colocar novos modelos no MLServer, inclusive novas versões.

Relembrando, o que queremos fazer é criar um caminho fácil de enviar as mudanças que fazemos localmente, possivelmente usando Jupyter notebook, até o Heroku. Também queremos usar o poder do MLServer para lidar com versionamento dos modelos.

Então vamos lá? Vamos começar criando uma pasta nova, onde iremos colocar nosso notebook. Desta vez faremos o exemplo com o Iris Dataset, que utilizamos na última seção.

Queremos que seja uma pasta com isolamento razoável, pois iremos controlar corretamente o versionamento dessa pasta no GitLab. Crie a pasta em um diretório qualquer, e chame-a de `iris-decision-tree`. Crie um ambiente virtual, e crie o arquivo `requirements.txt`:

```
jupyter==1.0.0
numpy==1.22.3
scikit-learn==1.1.1
```

Aqui é importante deixar todas as dependências bem organizadas e com as versões espeficidadas, pois esse notebook não será mais algo que ficará em nossa máquina, para experimentos sem muito controle. Iremos compartilhar esse notebook em um projeto no GitLab, por isso é importante esse cuidado. Assim, evite de instalar pacotes diretamente no notebook, preferindo deixar explícito no arquivo `requirements.txt`, assim outras pessoas poderão saber o que você está usando.

Instale os módulos:

```sh
pip install -r requirements.txt
```

Agora já podemos executar o notebook. Utilizaremos um dos exemplos da última seção, que foi simplificado aqui. Também é importante a nomeação. O nome dele deve ser `iris-decision-tree.ipynb`. Mais adiante utilizaremos scripts automáticos que dependem dessa nomeação exata.

```python
import numpy as np
from sklearn import datasets
from sklearn.metrics import accuracy_score
import joblib

iris = datasets.load_iris()
x = iris.data
y = iris.target
y_names = iris.target_names

np.random.seed(26322)
test_ids = np.random.permutation(len(x))

x_train = x[test_ids[:-10]]
x_test = x[test_ids[-10:]]

y_train = y[test_ids[:-10]]
y_test = y[test_ids[-10:]]

from sklearn import tree
dtc = tree.DecisionTreeClassifier()
dtc.fit(x_train, y_train)
pred = dtc.predict(x_test)
print(pred)
print(y_test)
print((accuracy_score(pred, y_test))*100)
joblib.dump(dtc, "iris-decision-tree.joblib")
```

Neste exemplo, estamos assumindo que o modelo será salvo em um arquivo com o mesmo nome que o notebook, com a extensão `.joblib`. Novamente, isso será importante mais para a frente, quando iremos automatizar todo o processo.

Execute o notebook e veja que será criado o arquivo `iris-decision-tree.joblib`. Isso significa que nosso modelo está funcionando e já podemos criar um repositório para ele. Mas não queremos que o arquivo `.joblib` seja versionado, pois ele é gerado automaticamente pelo notebook. Por isso, crie um arquivo `.gitignore` com o seguinte conteúdo:

```
.venv
*.joblib
```

A pasta `.venv` também é bom incluir, caso exista, assim o git irá ignorar esses arquivos também.

Agora vá ao GitLab e crie um novo projeto, chamado `iris-decision-tree`. Crie o projeto em branco, sem criar um `README.md`, e em seguida inicialize o repositório com o conteúdo que acabamos de criar, utilizando os comandos que já conhecemos:

```sh
git init --initial-branch=main
git remote add origin https://gitlab.com/daniel.lucredio/iris-decision-tree.git
git add .
git commit -m "Initial commit"
git push -u origin main
```

Agora já temos um ambiente compartilhado onde podemos trabalhar nesse modelo. Você pode clonar o repositório e trabalhar localmente, fazer testes e executar o que precisa. Pode fazer _commits_ a cada mudança, mantendo assim o rastreamento das versões, como já aprendemos ser uma boa prática. E também pode criar _branches_, _issues_ e _merge requests_, e tudo o mais que já aprendemos. Portanto, sob a ótica do código-fonte, está tudo bem encaminhado.

## 8.3.5 Em direção à automação completa do processo - do GitLab para o Heroku (de novo)

Agora vamos preparar o terreno para fazer um _pipeline_ de CI/CD que consegue levar nossos modelos até o MLServer, que está rodando no Heroku. Já fizemos isso agora há pouco, mas agora vamos focar no lado do desenvolvedor de modelos.

Primeiro, para criar um modelo que pode ser implantado no MLServer, precisamos do arquivo `model-settings.json`. Na pasta `iris-decision-tree`, crie um com o seguinte conteúdo:

```
{
    "name": "iris-decision-tree",
    "implementation": "mlserver_sklearn.SKLearnModel",
    "parameters": {
        "uri": "iris-decision-tree.joblib",
        "version": "v0.0.1"
    }
}
```

Aqui também a nomenclatura é importante. Veja como o nome do modelo e sua URI estão todos padronizados e com o mesmo nome que o arquivo `.ipynb`.

Para fazer o envio desse código ao MLServer, vamos utilizar o que já fizemos antes. Sabemos que o repositório GitLab para o MLServer já está configurado para, assim que receber um _commit_, fazer o envio ao Heroku. Então o que precisamos fazer é:

1. Clonar o repositório do MLServer
2. Copiar o arquivo do modelo e o `model-settings.json` para o local correto
3. Fazer um _commit_
4. Esperar enquanto o GitLab executa o _pipeline_ de deploy no Heroku

Então vamos lá. Os comandos são:

```sh
git clone https://gitlab.com/daniel.lucredio/mlserver.git
mkdir mlserver/models/iris-decision-tree-v0.0.1
cp iris-decision-tree.joblib mlserver/models/iris-decision-tree-v0.0.1
cp model-settings.json mlserver/models/iris-decision-tree-v0.0.1
cd mlserver
git add .
git commit -m "Releasing model iris-decision-tree-v0.0.1"
git push
cd ..
rm -rf mlserver
```

Agora basta aguardar. Assim que o _pipeline_ terminar de rodar, podemos testar o modelo lá no Heroku, enviando um POST:

```
POST http://dlucredio-mlserver.herokuapp.com/mlapi/v2/models/iris-decision-tree/versions/v0.0.1/infer
Content-Type: application/json

{
    "inputs": [
        {
            "name": "predict",
            "shape": [1,4],
            "datatype": "FP32",
            "data": [[5  , 3.4, 1.5, 0.2]]
        }
    ]
}
```

Tudo certo, mas ainda não está 100% automatizado, não é? Queremos que tudo isso seja feito sem que precisemos ficar executando comandos manualmente. Então vamos revisar, o que executamos manualmente?

1. O notebook, executamos manualmente
2. Fizemos a criação do arquivo `model-settings.json` manualmente
3. Também fizemos a clonagem do projeto do `mlserver` a partir do GitLab
4. Em seguida, criamos uma pasta e copiamos os arquivos, manualmente
5. Depois fizemos o _commit_, manualmente
6. Daqui pra frente, o GitLab fez o resto automaticamente

Será que conseguimos automatizar esses passos todos?

## 8.3.6 Passo 1: Automatizando a execução de notebooks

Existe um módulo Python que se chama [papermill](https://papermill.readthedocs.io/). Trata-se de uma ferramenta para executar notebooks Jupyter a partir de scripts Python ou a partir da linha de comando. Ele também possibilita a parametrização dos notebooks, o que dá bastante flexibilidade ao processo.

Usar o papermill é bastante trivial. Primeiro, modifique o arquivo `requirements.txt` para incluir essa ferramenta:

```diff
jupyter==1.0.0
numpy==1.22.3
scikit-learn==1.1.1
+papermill==2.3.4
```

Instale-a:

```sh
pip install -r requirements.txt
```

E para executar, basta rodar:

```sh
papermill iris-decision-tree.ipynb -
```

A opção `-` no final diz ao papermill para exibir o resultado da execução no próprio terminal. Experimente apagar o arquivo `.joblib` e veja que o mesmo é gerado novamente.

## 8.3.7 Passo 2: Automatizando a criação do model-settings.json

A princípio, devemos criar o arquivo `model-settings.json` manualmente. Porém, a cada nova versão teríamos que alterá-lo para que a nova versão apareça. Não é um problema muito grave, mas é possível automatizar essa parte também. Modifique-o da seguinte maneira:

```diff
{
    "name": "iris-decision-tree",
    "implementation": "mlserver_sklearn.SKLearnModel",
    "parameters": {
        "uri": "iris-decision-tree.joblib",
-        "version": "v0.0.1"
+        "version": "$VERSAO"
    }
}
```

Agora é possível rodar um comando `bash` que substitui a string $VERSAO por uma qualquer. Em um terminal `bash` execute:

```sh
sed -i 's/$VERSAO/v1.4.5/' model-settings.json
```

E veja como o conteúdo é substituído corretamente. Segundo desafio superado! E daqui a pouco veremos como usar o número de versão do GitLab aqui, automaticamente, aguarde.

Mas antes de seguir adiante, não esqueça de voltar atrás e desfazer a mudança feita pelo comando `sed`!

```diff
{
    "name": "iris-decision-tree",
    "implementation": "mlserver_sklearn.SKLearnModel",
    "parameters": {
        "uri": "iris-decision-tree.joblib",
-        "version": "v1.4.5"
+        "version": "$VERSAO"
    }
}
```

## 8.3.8 Passos 3, 4 e 5: Automatizando a clonagem e configuração do projeto do MLServer

Esses passos já são praticamente automáticos, exceto pelas permissões, que foram obtidas diretamente a partir do ambiente da máquina local. Para que os scripts rodem em qualquer local, será preciso gerar um _token_ de acesso ao GitLab, assim como fizemos na [Seção 6.3](../6-integracao-continua/6-3-configurando-um-repositorio-no-gitlab.md). Os passos são os seguintes:

1. Acesse o GitLab
2. Clique no ícone para editar seu perfil, no canto superior direito da página:
3. Em seguida, clique em "Access Tokens":
4. Na página que aparecer, escolha o nome "access-mlserver" para seu token, ative a opção `write_repository`, e crie o token. Se quiser definir uma data para que o token expire, é possível. Caso deixe em branco, o _token_ terá validade indeterminada.
5. Assim que o processo for concluído, será exibido o _token_ criado. Conforme as instruções, copie-o agora e salve-o em algum local seguro, pois o mesmo não poderá ser visto novamente assim que sair da página (será necessário revogá-lo e criar novamente).

Também é necessário definir o e-mail e nome de usuário, assim não é necessário ter mais nenhuma configuração extra.

Revisitando portanto os comandos vistos anteriormente, agora deve ser a seguinte sequência:

```sh
git config --global user.email "<seu e-mail>"
git config --global user.name "Daniel Lucrédio"
git clone https://access-mlserver:xxxxxxxxxxxxxxxxxx@gitlab.com/daniel.lucredio/mlserver.git
mkdir mlserver/models/iris-decision-tree-v0.0.2
cp iris-decision-tree.joblib mlserver/models/iris-decision-tree-v0.0.2
cp model-settings.json mlserver/models/iris-decision-tree-v0.0.2
cd mlserver
git add .
git commit -m "Releasing model iris-decision-tree-v0.0.2"
git push
cd ..
rm -rf mlserver
```

Com isso já temos tudo o que precisamos para automatizar 100% do processo.

## 8.3.9 Criando o pipeline CI/CD no GitLab

Nosso pipeline será um pouco customizável, e faremos isso com algumas variáveis de ambiente. Acesse, na página do GitLab do projeto `iris-decision-tree`, o menu "Settings" -> "CI/CD" -> "Variables". Crie três variáveis, e lembre-se de deixá-las desprotegidas (a opção "Protect variable" deve estar desmarcada). Falaremos disso depois:

* `GIT_USER_EMAIL`: configure seu e-mail aqui
* `GIT_USER_NAME`: configure um nome aqui para ficar registrado que os _commits_ estão vindo do GitLab. Pode ser: "GitLab iris-decision-tree"
* `MLSERVER_REPO`: coloque aqui a URL completa usada no comando `git clone`. No exemplo, é `https://access-mlserver:xxxxxxxxxxxxxxxxxx@gitlab.com/daniel.lucredio/mlserver.git` (substituindo xxxxxx pelo token de acesso)

Agora crie o arquivo `.gitlab-ci.yml`, na pasta `iris-decision-tree`:

```yml
stages:
  - release
 
variables:
  DOCKER_TLS_CERTDIR: ""
  NOME_MODELO: "iris-decision-tree"
  EXTENSAO_MODELO: "joblib"

send_model:
  image: python:3.10.4
  stage: release
  rules:
    - if: $CI_COMMIT_TAG
  script:
    - pip install -r requirements.txt
    - papermill $NOME_MODELO.ipynb -
    - git config --global user.email "$GIT_USER_EMAIL"
    - git config --global user.name "$GIT_USER_NAME"
    - git clone $MLSERVER_REPO
    - sed -i 's/$VERSAO/'"$CI_COMMIT_TAG"'/' model-settings.json
    - mkdir mlserver/models/$NOME_MODELO-$CI_COMMIT_TAG
    - cp $NOME_MODELO.$EXTENSAO_MODELO mlserver/models/$NOME_MODELO-$CI_COMMIT_TAG
    - cp model-settings.json mlserver/models/$NOME_MODELO-$CI_COMMIT_TAG
    - cd mlserver
    - git add .
    - git commit -m "Pushing model $NOME_MODELO-$CI_COMMIT_TAG to mlserver repo"
    - git push
```

Trata-se de um _pipeline_ simples, que tem um único _job_, que faz a sequência de passos que acabamos de preparar. Vamos entender o que ele faz:

A variável `DOCKER_TLS_CERTDIR` serve apenas para executar os _runners_ locais sem restrições, caso você não esteja utilizando os _runners_ compartilhados do GitLab. Já falamos disso na [Seção 7.2](../7-entrega-continua/7-2-implantacao-automatica-no-docker-hub.md).

As variáveis `NOME_MODELO` e `EXTENSAO_MODELO` servem para facilitar a criação de outros modelos, no futuro. Não são de fato necessárias, mas possibilitam que o reuso do arquivo `.gitlab-ci.yml` seja mais fácil. Elas serão utilizadas nos comandos mais abaixo.

O _job_ `send_model` utiliza a imagem `python` padrão, necessária para executar as ferramentas Python.

Existe uma regra - `rules: if: $CI_COMMIT_TAG`. Essa regra condiciona a execução do _job_ da seguinte maneira. Esse _job_ só vai rodar se existir uma _tag_ criada manualmente pelo desenvolvedor. _Tags_ [servem para que os desenvolvedores marquem pontos fixos na evolução do projeto](https://docs.gitlab.com/ee/topics/git/tags.html), e podem ser utilizadas, por exemplo, para marcar versões. É o que faremos aqui. Sempre que o desenvolvedor fizer um _commit_ sem uma _tag_, nada acontece. Ele poderá fazer quantos _commits_ quiser. Mas sempre que ele marcar um _commit_ com uma _tag_, o _job_ de envio será disparado. 

Há outras formas de se disparar o envio do modelo. Poderíamos associar o _job_ a um _branch_ específico. Sempre que for feito um _commit_ nesse _branch_, por exemplo, pode ser feito o envio. Ou então poderíamos usar o conceito de [_release_](https://docs.gitlab.com/ee/user/project/releases/), que é um tipo especial de _tag_ que marca uma entrega para os usuários. Também poderíamos fazer um _job_ para execução manual, como fizemos anteriormente na [Seção 7.3](../7-entrega-continua/7-3-implantacao-automatica-no-heroku.md). De qualquer forma, o processo é parecido com o que faremos aqui, e dentro das possibilidades do GitLab o leitor pode escolher a que mais se adequa ao seu cenário.

Ao condicionar a execução a uma _tag_, os _pipelines_ CI/CD do GitLab tem acesso ao texto daquela _tag_, por meio da variável $CI_COMMIT_TAG. No caso, a _tag_ irá marcar a versão, que será configurada no MLServer. Assim, ao marcar um _commit_ com uma _tag_, por exemplo "v2.5.4", o acesso ao modelo no MLServer também usará essa mesma versão, unificando os processos.

E é devido ao uso de _tags_ que deixamos as variáveis desprotegidas antes. Sempre que uma _tag_ dispara uma execução de um _job_, existe o risco de algum código malicioso ser inserido em um _pipeline_. Esse código poderia, por exemplo, acessar segredos e tokens salvos nas variáveis, e enviar para algum servidor remoto. Por isso, o GitLab dá a opção de esconder as variáveis dos _pipelines_ associados a algumas _tags_. E podemos também definir que algumas _tags_ são protegidas, ou seja, apenas algumas pessoas podem utilizá-las. Faremos isso daqui a pouco, quando voltaremos a proteger nossas variáveis. Mas por enquanto, vamos concluir o processo.

O restante do código desse _job_ não precisa de explicação. Ele faz exatamente o que fizemos manualmente há pouco, utilizando as variáveis para facilitar a customização. Leia-o atentamente e perceba o motivo pelo qual estivemos dizendo para manter todos os nomes padronizados. É aqui que colhemos o resultado desse esforço.

Salve esse arquivo e vamos fazer o envio, utilizando nossa primeira _tag_ para disparar o _pipeline_.

```sh
git add .
git commit -m "Adicionando pipeline CI/CD"
git push
```

Depois desse comando, vá ao GitLab e veja que nenhum _pipeline_ iniciou. Isso porque nosso _pipeline_ está condicionado a uma _tag_. Vamos fazer isso agora:

```sh
git tag -a v1.0.0 -m "Primeiro release"
git push --tags
```

O primeiro comando cria a _tag_ associada ao último _commit_ e o segundo faz o envio ao GitLab, o que irá disparar o _pipeline_.

O processo todo irá demmorar um pouco. Enquanto espera, pense sobre o que está acontecendo:

1. O notebook foi enviado ao GitLab, mas sem o arquivo do modelo, lembra que colocamos no `.gitignore`?
2. O GitLab vai subir um contêiner Docker, com base na imagem Python que configuramos
3. O GitLab vai instalar as dependências todas, incluindo o papermill
4. O GitLab vai rodar o notebook usando o papermill. Isso irá gerar o arquivo `.joblib`
5. O GitLab vai clonar o repositório do MLServer, onde estão todos os modelos
6. O GitLab vai modificar o arquivo `model-settings.json` para marcá-lo com a versão especificada na _tag_ (neste exemplo: "v1.0.0)
7. O GitLab vai criar a estrutura para esse novo modelo, criando uma pasta para ele e copiando os dois arquivos
8. O GitLab vai enviar as mudanças para o repositório do MLServer, em um _commit_
9. Já no repositório do MLServer, o GitLab vai iniciar outro _pipeline_, associado ao _commit_
10. Nesse pipeline, o GitLab vai subir um contêiner Docker que roda Docker (Docker-in-Docker)
11. O GitLab vai instalar as ferramentas do Heroku
12. O GitLab vai construir uma imagem para o MLServer, já com o novo modelo dentro
13. O GitLab vai se autenticar no Heroku e vai enviar a imagem para o Docker registry do Heroku
14. O GitLab vai pedir ao Heroku para fazer o release da nova imagem

Ufa, bastante coisa, não? Se tudo funcionar, faça um novo POST e veja o novo modelo sendo hospedado no Heroku:

```
POST http://dlucredio-mlserver.herokuapp.com/mlapi/v2/models/iris-decision-tree/versions/v1.0.0/infer
Content-Type: application/json

{
    "inputs": [
        {
            "name": "predict",
            "shape": [1,4],
            "datatype": "FP32",
            "data": [[5  , 3.4, 1.5, 0.2]]
        }
    ]
}
```

## 8.3.10 Voltando a proteger as variáveis

Agora vamos voltar e proteger nossas variáveis, que deixamos desprotegidas. Acesse o menu "Settings" -> "CI/CD" -> "Variables", e marque todas como "Protected".

Agora acesse "Settings" -> "Repository" -> "Protected tags".

No campo "Tag", especifique "v*".

No campo "Allowed to create", especifique "Maintainers".

Pronto, agora somente os desenvolvedores marcados como "maintainers" poderão criar _tags_ que começam com "v". Outras _tags_ poderão ser criadas, mas os _jobs_ não terão acesso às variáveis, e portanto falharão.

Faça o teste, gerando uma _tag_ que não começa com "v":

```sh
git tag -a 1.0.0 -m "Uma tag nao protegida" | git push --tags
```

O _pipeline_ irá rodar, mas ele irá falhar, pois essa _tag_ não é protegida e portanto as variáveis necessárias para a execução dos _jobs_ não estarão disponíveis.

Agora teste com uma _tag_ protegida:

```sh
git tag -a v1.0.1 -m "Testando variáveis em tag protegida" | git push --tags
```

Agora tudo irá funcionar normalmente.