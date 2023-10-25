# 5.2 Orquestração com Docker Compose

Como o próprio nome diz, `docker-compose` é parte da pilha de tecnologias da Docker Inc e é responsável por definir e executar aplicações multi-contêineres com o `docker`.

Com ele, é possível definir uma aplicação multi-contêiner, coordenando a criação e a ordem de execução dos contêineres em um único arquivo, denominado `compose.yaml`. Com isso, passa a ser possível inicializar toda a aplicação a partir de um único comando, e não como fizemos até o momento, utilizando vários `docker run` de forma isolada e numa ordem gerenciada manualmente.

No nosso caso, para inicializar os contêineres das diferentes aplicações e de monitoramento, precisamos, primeiramente, inicializar os servidores WSGI e Web, os componentes do Kafka, incluindo o Zookeeper, Broker e Consumer. Também precisamos nos preocupar com a dependência entre eles, pois eles trabalham de forma conectada. Essa dependência precisa ser respeitada para que as aplicações executem com sucesso.

O `docker-compose` funciona como um orquestrador, ou seja, uma entidade que gerencia a criação das imagens na ordem determinada e de forma coordenada. Com base nos `Dockerfile` de imagens individuais, ele é capaz de coordenar a ordem de criação dos contêineres, além de outros recursos como o mapeamento de portas, gerenciamento de volumes, e até mesmo opções de reinicialização do contêiner em caso de alguma falha no mesmo.

A função básica do `docker-compose` é simplificar os comandos de construção de imagens e execução de contêineres. Vamos então começar pelo básico. Como construir uma imagem e subir um contêiner? Que tal subir uma instância do nginx, com a qual já trabalhamos aqui no livro?

Apenas para organizar seu trabalho, crie uma pasta qualquer em seu computador (por exemplo, `hello-world`). Agora crie um arquivo chamado `compose.yaml`:

```yml
services:
  web:
    image: nginx
    ports:
      - 80:80
```

Antes de explicá-lo, vale a pena discutir sobre o nome do arquivo. A princípio, é possível criar um arquivo com qualquer nome. Mas ao se utilizar um nome padrão, os comandos são mais simples, pois não é necessário informá-lo toda vez que for executado um comando.

Além disso, é importante destacar que, em muitas documentações e exemplos, você irá se deparar com o nome `docker-compose.yml`. Esse nome é mais antigo, e a [documentação oficial](https://docs.docker.com/compose/compose-file/) recomenda que seja utilizado o novo nome canônico `compose.yaml`. Mas ambos são considerados padrão, e ambos irão funcionar da mesma forma.

Vamos ao conteúdo. Esse arquivo define um serviço apenas, abaixo do item `services`. Esse serviço se chama `web` (um nome que nós definimos). A imagem Docker referente a esse serviço é a `nginx`, que será puxada do Docker Hub. Além disso, estamos definindo que a porta 80 do contêiner ficará disponível para o host, também na porta 80.

Vamos rodar para ver o resultado. Abra um terminal, navegue até a pasta que criou, e execute:

```
docker-compose up
```

Se tudo der certo, a imagem será criada (com base em uma imagem baixada do Docker Hub), e o servidor irá rodar. Abra um navegador, acesse o endereço `http://localhost` e veja se o nginx está de fato rodando.

Para interromper a execução, abra outro terminal, navegue até a mesma pasta e execute:

```
docker-compose stop
```

O que fizemos foi, basicamente, equivalente ao seguinte comando, que já deve ser familiar para o leitor, pois já explicamos várias vezes até o momento:

```
docker run --name hello-world_web_1 -p 80:80 nginx
```

Veja como o nome é composto a partir do nome da pasta onde o arquivo `compose.yaml` está localizado, o nome do serviço, e um número sequencial.

Também é possível hospedar conteúdo estático. Crie uma pasta, chamada `html`, e dentro dela salve um arquivo chamado `index.html`, com um conteúdo simples, como o seguinte:

```html
Hello world!
```

Agora modifique o conteúdo do `compose.yaml`:

```diff
services:
  web:
    image: nginx
    ports:
      - 80:80
+    volumes:
+      - ./html:/usr/share/nginx/html:ro
```

O que fizemos foi mapear um volume para o contêiner, que irá criar um link para o conteúdo da pasta `html` (onde colocamos o nosso arquivo `index.html`), em uma pasta dentro do contêiner que já está pré-configurada para hospedagem de arquivos estáticos. Assim, quando acessarmos o endereço `http://localhost` no navegador, veremos o conteúdo do arquivo. Experimente trocar esse conteúdo (modifique o arquivo `index.html`) e recarregar a página, para ver o novo conteúdo sendo exibido.

Novamente, não há nenhuma novidade nesse comando. O que está sendo executado, no fundo, é isso aqui:

```
docker run --name hello-world_web_1 -p 80:80 -v ./html:/usr/share/nginx/html:ro nginx
```

Aqui cabe um questionamento: se é possível fazer o mesmo que está no arquivo `compose.yaml` por meio de comandos `docker run`, por que perder tempo utilizando `docker-compose`? De fato, à primeira vista, se o objetivo é apenas rodar um único serviço, há pouca vantagem em utilizar o `docker-compose`. Por que não simplesmente executar os comandos manualmente? Seria até melhor por gastar menos texto, afinal em uma linha conseguiríamos executar tudo do mesmo jeito!

A resposta tem dois componentes:

1. Primeiro, de fato o `docker-compose` não serve para subir um único serviço. Ele será realmente útil quando tivermos que combinar vários serviços, colocá-los na mesma rede, definir uma ordem para execução, entre outras coisas. Volte ao início desta seção. Lá dissemos que o `docker-compose` é uma ferramenta para orquestração de aplicações multicontêineres!
2. Além disso, deixar codificado, em um arquivo, tudo o que é necessário para subir um serviço (nome da imagem, versão, portas, volumes...), isso fica melhor documentado. É mais fácil entender o que está acontecendo, é mais fácil reutilizar aquela configuração. Em outras palavras, estamos codificando (em um arquivo YAML) a configuração da nossa infraestrutura de execução. Leia novamente a [seção anterior](5-1-introducao.md), agora! É exatamente isso o que queríamos dizer com o termo "infraestrutura como código".

A ferramenta `docker-compose` tem muitas opções. Vale a pena [estudar a documentação oficial](https://docs.docker.com/compose/). Por exemplo, se quisermos rodar o servidor em modo desacoplado, basta utilizar a opção `-d`:

```
docker-compose up -d
```

Dessa forma, o terminal fica desacoplado enquanto o contêiner roda, como tínhamos feito em exemplos anteriores com o `docker run`.

Quer ver um exemplo mais completo, com múltiplos contêineres? Experimente realizar o tutorial ["Getting started"](https://docs.docker.com/compose/gettingstarted/) da documentação oficial.

## 5.2.1 Subindo as aplicações de machine learning

Vamos então partir para um exemplo mais completo e subir todos os contêineres das nossas aplicações desenvolvidas até o momento. Vamos repetir aqui a mesma figura que já mostramos antes, para que você se lembre da nossa infraestrutura que estaremos codificando:

![Infraestrutura das aplicações](../4-monitoramento/imgs/monitoramentoSetup3.png)

Faça download de todas as pastas [desse link aqui](../exemplos/aplicativos/). Você deve ter os seguintes diretórios:

* `classificador-produtos`:
  * Tarefa offline para classificação de produtos acessando banco de dados na nuvem
* `http-api-classificacao-produtos-container-unico`:
  * Tarefa online para classificação de produtos via API HTTP (contêiner único)
* `http-api-classificacao-produtos-dois-containers`:
  * Tarefa online para classificação de produtos via API HTTP (dois contêineres)
* `analise-sentimentos`:
  * Consumidor Kafka que analisa sentimentos
* `chatbot`:
  * Produtor Kafka que produz conversas com um chatbot

Em uma pasta acima de todas essas, crie um arquivo chamado `compose.yaml`, e vamos começar a construir o conteúdo. Vamos fazer um aplicativo de cada vez. Vamos pular a tarefa _offline_, pois ela não é um serviço que ficará rodando. Vamos começar pela HTTP API em contêiner único (nginx + wsgi rodando no mesmo contêiner).

```yaml
services:
  http-api-classificacao-produtos-container-unico-container:
    build: ./http-api-classificacao-produtos-container-unico
    restart: always
    ports:
      - "8080:80"
```

A diferença deste exemplo com o anterior é que, ao invés de passar uma imagem, estamos especificando a diretriz `build`. Seu conteúdo aponta para a pasta `./http-api-classificacao-produtos-container-unico`, onde espera-se que exista um arquivo chamado `Dockerfile`. Confira lá, e veja que esse arquivo de fato existe! Assim, quando formos executar essa configuração, o `docker-compose` irá verificar se já existe uma imagem construída a partir desse `Dockerfile`. Se não existe, ele a irá construir automaticamente.

Vamos testar. Antes de mais nada, apague todos contêineres e imagens de seu computador, para garantir que tudo será construído corretamente.

```
docker stop $(docker ps -q)
docker image prune -a
```

Execute o comando `docker-compose up -d` na mesma pasta onde está o `compose.yaml`. Veja como a imagem será construída.

Teste, abrindo no navegador o endereço `http://127.0.0.1:8080/cadastro.html` (não funciona com `localhost` pois o navegador acha que é outra origem, então vai barrar a requisição por causa da restrição CORS).

Se funcionou, vamos continuar. Vamos agora adicionar os serviços nginx e wsgi separados. Modifique o arquivo `compose.yaml`, adicionando os seguintes serviços:

```diff
services:
  http-api-classificacao-produtos-container-unico-container:
    build: ./http-api-classificacao-produtos-container-unico
    restart: always
    ports:
      - "8080:80"
+  my-custom-nginx-container:
+    build:
+      context: ./http-api-classificacao-produtos-dois-containers
+      dockerfile: Dockerfile-nginx
+    restart: always
+    ports:
+      - "8081:80"
+  wsgi-app-container:
+    build:
+      context: ./http-api-classificacao-produtos-dois-containers
+      dockerfile: Dockerfile-wsgi
+    restart: always
```

Agora há outra diferença. Como nesses contêineres o nome do `Dockerfile` não é o padrão, a diretriz `build` tem dois componentes: o contexto (a pasta onde está o `Dockerfile`), e o nome do `Dockerfile`. Confira lá nessa pasta, e veja que de fato esses dois arquivos estão lá!

Interrompa a aplicação e suba-a novamente:

```
docker-compose stop
docker-compose up -d
```

Teste, abrindo o navegador, agora no endereço `http://127.0.0.1:8081/cadastro.html`, e veja como os serviços subiram corretamente.

Agora vamos configurar a aplicação com Kafka. As mudanças no `compose.yaml` são as seguintes:

```diff
services:
  http-api-classificacao-produtos-container-unico-container:
    build: ./http-api-classificacao-produtos-container-unico
    restart: always
    ports:
      - "8080:80"
  my-custom-nginx-container:
    build:
      context: ./http-api-classificacao-produtos-dois-containers
      dockerfile: Dockerfile-nginx
    restart: always
    ports:
      - "8081:80"
  wsgi-app-container:
    build:
      context: ./http-api-classificacao-produtos-dois-containers
      dockerfile: Dockerfile-wsgi
    restart: always
+  zookeeper:
+    image: confluentinc/cp-zookeeper:7.0.1
+    environment:
+      - ZOOKEEPER_CLIENT_PORT=2181
+      - ZOOKEEPER_TICK_TIME=2000
+  broker:
+    image: confluentinc/cp-kafka:7.0.1
+    ports:
+      - "9092:9092"
+    restart: on-failure
+    depends_on:
+      - zookeeper
+    environment:
+      - KAFKA_BROKER_ID=1
+      - KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
+      - KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,PLAINTEXT_INTERNAL:PLAINTEXT
+      - KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092,PLAINTEXT_INTERNAL://broker:29092
+      - KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
+      - KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1
+      - KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1
+  analise-sentimentos-consumer-container:
+    build: ./analise-sentimentos
+    restart: on-failure
+    depends_on:
+      - broker
```

Aqui a coisa já começa a ficar interessante. Compare esse arquivo com os comandos para executar cada um dos contêineres, na [Seção 4.1](../4-monitoramento/4-1-introducao.md). Veja como é muito mais fácil ver a conexão entre cada contêiner, especificada por meio das variáveis de ambientes explícitas no `compose.yaml`.

Veja como o broker e consumer do Kafka tem dependências definidas por meio da diretriz `depends_on`. O broker depende do zookeeper, isto é, se o broker começar a subir antes que o zookeeper esteja pronto, ele irá falhar. O mesmo irá acontecer com o consumer. Se o broker ainda não estiver pronto, o consumer é que irá falhar. A diretriz `depends_on` tenta aliviar esse problema, definindo uma ordem para que os contêineres sejam iniciados. Porém, o `docker-compose` não aguarda o início completo de um serviço para iniciar o processamento do outro. Essas inicializações ocorrem em paralelo. Ou seja, não há garantias de que um serviço terminou antes de começar o próximo.

Para resolver esse problema de um jeito simples (porém não ideal), note também como definimos que o broker e consumer do Kafka tem uma política de reinicialização (`restart: on-failure`). Isso porque caso o broker comece a subir antes que o zookeeper esteja pronto para ouvir, ele irá falhar. Neste caso, o docker compose irá automaticamente tentar subi-lo novamente. O mesmo irá acontecer com o consumer, que depende do broker. Assim garantimos que, eventualmente, todos os contêineres consigam subir ainda que a ordem não seja garantida, e ainda que existam algumas tentativas fracassadas para isso.

Há outras formas de se garantir a ordem de execução sem esse processo de tentativa e erro, conforme [pode ser estudado na documentação oficial](https://docs.docker.com/compose/startup-order/). Isso normalmente envolve a criação de _scripts_ de testes para garantir que uma determinada condição é atendida. Deixamos a cargo do leitor estudar essas alternativas.

Por fim, vamos completar o ambiente subindo nosso monitor. Copie a [pasta do projeto](../exemplos/DockerProjects/nagios/) onde criamos nosso contêiner customizado do Nagios para essa mesma pasta, e modifique o arquivo `compose.yaml` uma última vez:

```diff
services:
  http-api-classificacao-produtos-container-unico-container:
    build: ./http-api-classificacao-produtos-container-unico
    restart: always
    ports:
      - "8080:80"
  my-custom-nginx-container:
    build:
      context: ./http-api-classificacao-produtos-dois-containers
      dockerfile: Dockerfile-nginx
    restart: always
    ports:
      - "8081:80"
  wsgi-app-container:
    build:
      context: ./http-api-classificacao-produtos-dois-containers
      dockerfile: Dockerfile-wsgi
    restart: always
  zookeeper:
    image: confluentinc/cp-zookeeper:7.0.1
    environment:
      - ZOOKEEPER_CLIENT_PORT=2181
      - ZOOKEEPER_TICK_TIME=2000
  broker:
    image: confluentinc/cp-kafka:7.0.1
    ports:
      - "9092:9092"
    restart: on-failure
    depends_on:
      - zookeeper
    environment:
      - KAFKA_BROKER_ID=1
      - KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
      - KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,PLAINTEXT_INTERNAL:PLAINTEXT
      - KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092,PLAINTEXT_INTERNAL://broker:29092
      - KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
      - KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1
      - KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1
  analise-sentimentos-consumer-container:
    build: ./analise-sentimentos
    restart: on-failure
    depends_on:
      - broker
+  nagios-server:
+    build: ./nagios
+    restart: always
+    ports:
+      - "80:80"
```

Não deve haver nenhuma novidade para o leitor nessa nova entrada no arquivo.

Depois de subir mais uma vez, abra o navegador no caminho `localhost` e aguarde até que o monitoramento comece a funcionar. Se tudo der certo, todos os serviços estarão funcionando depois de algum tempo, [exceto pelo serviço WSGI - porta 5000, na aplicação onde nginx e WSGI rodam num mesmo contêiner, como já discutido antes](../4-monitoramento/4-5-criando-verificacoes-mais-especificas.md).

Uma outra questão precisa ser discutida. Volte à [Seção 4.1](../4-monitoramento/4-1-introducao.md) e veja como, em cada comando, especificamos que uma determinada rede deveria ser utilizada (chamada `minharede`). Aqui isso não foi necessário. Isso porque, com o docker compose, automaticamente é criada uma rede virtual para os contêineres rodarem. Como o docker compose possui um _Domain Name Server_ (DNS) interno que faz o mapeamento do nome do serviço para o seu IP correspondente, os contêineres conseguem se encontrar pelo seu nome sem a necessidade de conectá-los explicitamente a uma rede diferente.

Desse modo, como pudemos observar, foi possível concentrar a carga e a sequência desejada de início dos serviços em um único arquivo de configuração, facilitando a realização do _deploy_ da aplicação no ambiente de produção.

No próximo capítulo abordaremos o processo de integração contínua e entrega contínua que estão relacionadas ao ambiente de desenvolvimento e, posteriormente, de atualização do ambiente de produção se tudo correr conforme o esperado.
