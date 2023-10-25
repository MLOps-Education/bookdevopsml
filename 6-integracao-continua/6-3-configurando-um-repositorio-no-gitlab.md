# 6.3 Configurando um repositório no GitLab

Vamos começar a colocar esses conceitos em prática então. Retomando a figura, estamos no passo 2, ou seja, vamos começar colocando um de nossos projetos nesse ciclo, iniciando pelo sistema de controle de versões. Utilizaremos o [GitLab](https://gitlab.com/).

![Fluxo de trabalho genérico e para o ciclo de vida do aplicativo em contêineres do Docker (extraída de Torre (2020))](https://docs.microsoft.com/pt-br/dotnet/architecture/containerized-lifecycle/docker-application-lifecycle/media/containers-foundation-for-devops-collaboration/generic-end-to-enddpcker-app-life-cycle.png)

## 6.3.1. Download e preparação do projeto

Faremos o exemplo baseado no aplicativo para classificação de produtos que utiliza contêiner único. Faça o [download aqui](../exemplos/aplicativos/) e salve-o em seu computador (precisaremos apenas da pasta referente ao projeto da API HTTP com contêiner único). Caso ainda não exista, não se esqueça de criar e ativar um ambiente virtual para esse projeto. A estrutura de diretórios deve ser a seguinte:

![Página inicial do GitLab](./imgs/integracaocontinua2.png)

Sempre certificando-se que o ambiente virtual está ativado, execute o comando `pip install -r requirements.txt` para instalar os pacotes caso necessário.

## 6.3.2. Configuração do repositório

Agora vamos colocar esse projeto no [GitLab](https://gitlab.com/). A primeira coisa a fazer é criar uma conta de usuário. O processo é simples e rápido, basta acessar a página e seguir as instruções. Assim que estiver concluído, você verá a página inicial:

![Página inicial do GitLab](./imgs/integracaocontinua1.png)

Crie um novo projeto vazio, e escolha um nome para ele. O importante é que este nome seja único dentro do seu conjunto de repositórios. Vamos escolher "classificador-produtos". Também é importante escolher a visibilidade. A opção "Private" mantém o repositório inacessível a outros usuários, permitindo que você libere o acesso apenas a quem desejar, enquanto a opção "Public" permite que qualquer pessoa consiga vê-lo, o que é ideal para projetos abertos, open source, etc. Para este exemplo, tanto faz a opção. Por último, vamos desmarcar a opção "Initialize repository with a README", pois queremos inicializar o repositório com a pasta que acabamos de criar.

As Figuras a seguir ilustram as opções a serem adotadas para este exemplo.

![Criação de projeto no GitLab - parte 1](./imgs/integracaocontinua3.png)

![Criação de projeto no GitLab - parte 2](./imgs/integracaocontinua4.png)

Ao concluir a criação do projeto, você será levado até sua página inicial. Lá serão exibidas algumas informações interessantes. Uma delas é uma sequência de comandos para configurar seu usuário padrão do GitLab na máquina (não se preocupe, isso pode ser alterado posteriormente caso queira outros usuários):

```sh
git config --global user.name "Daniel Lucrédio"
git config --global user.email "daniel.lucredio@ufscar.br"
```

Em seguida, precisamos configurar uma forma segura para acessar o repositório a partir da nossa máquina local. Há diferentes formas para fazer isso. Faremos utilizando um _token_ de acesso pessoal.

Clique no ícone para editar seu perfil, no canto superior direito da página:

![Criando um token de acesso pessoal - parte 1](./imgs/integracaocontinua5.png)

Em seguida, clique em "Access Tokens":

![Criando um token de acesso pessoal - parte 2](./imgs/integracaocontinua6.png)

Na página que aparecer, escolha um nome para seu token (no exemplo, colocamos "notebook-samsung"), ative a opção `write_repository`, e crie o token. Se quiser definir uma data para que o token expire, é possível. Caso deixe em branco, o _token_ terá validade indeterminada.

![Criando um token de acesso pessoal - parte 3](./imgs/integracaocontinua7.png)

Assim que o processo for concluído, será exibido o _token_ criado. Conforme as instruções, copie-o agora e salve-o em algum local seguro, pois o mesmo não poderá ser visto novamente assim que sair da página (será necessário revogá-lo e criar novamente).

![Criando um token de acesso pessoal - parte 4](./imgs/integracaocontinua8.png)

Agora podemos inicializar nosso repositório com o conteúdo que criamos anteriormente. Abra um terminal e navegue até a pasta com o projeto `classificador-produtos`. Execute os seguintes comandos, substituindo o nome ("notebook-samsung") e conteúdo do token (`xxxxxxxxxxxxxxxxxxxxx`) pelos valores que você acabou de criar.

```sh
git init --initial-branch=main
git remote add origin https://notebook-samsung:xxxxxxxxxxxxxxxxxxxxxxxxxxx@gitlab.com/daniel.lucredio/classificador-produtos.git
git add .
git commit -m "Initial commit"
git push -u origin main
```

Se tudo der certo, algo parecido com o seguinte deve aparecer no terminal:

```
Enumerating objects: 12, done.
Counting objects: 100% (12/12), done.
Delta compression using up to 8 threads
Compressing objects: 100% (9/9), done.
Writing objects: 100% (12/12), 434.51 KiB | 5.79 MiB/s, done.
Total 12 (delta 0), reused 0 (delta 0), pack-reused 0
To https://gitlab.com/daniel.lucredio/classificador-produtos.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

Acessando a página do projeto no GitLab, você deve conseguir ver o mesmo conteúdo que criamos anteriormente:

![Inicialização do repositório aparecendo no GitLab](./imgs/integracaocontinua9.png)

Não é aqui o objetivo ensinar todos os detalhes e procedimentos para utilização do `git`. Existem muitos tutoriais, livros e artigos sobre o assunto, sendo de fácil acesso e aprendizado. Deixamos para o leitor a tarefa de se familizarizar com o uso desse sistema para controle de versões. Mas iremos demonstrar a seguir o processo de criação de uma "branch" e o processo de "merge", pois é importante para a integração contínua.

