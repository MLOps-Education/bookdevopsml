# 1.3 Configuração do Ambiente - Python

Após uma época em que os computadores ocupavam salas enormes e eram compartilhados, o surgimento do computador pessoal trouxe uma característica que normalmente não pensamos muito, e que vai além da sua maior presença nos lares e negócios: a personalização.

Hoje é comum que cada indivíduo tenha seu próprio computador (às vezes mais do que um, se contarmos os smartphones e tablets), e com isso surge a necessidade - e o desejo - de acrescentarmos nosso toque pessoal, seja na escolha das cores e fundo de tela, até a opção por ferramentas e sistemas operacionais. Isso faz muito sentido se considerarmos que passamos cada vez mais horas em frente à tela do computador. Por que não deixar tudo com nosso toque pessoal?

Assim também vai acontecer no desenvolvimento de software. O ambiente de desenvolvimento é o local onde o programador passa a maior parte de seu tempo, realizando atividades de edição de código, documentação, teste, depuração e experimentação. Naturalmente, cada desenvolvedor terá sua própria escolha de sistema operacional, linguagem, configurações de cores, além das ferramentas de sua preferência. Assim, seria impossível ditar um conjunto de regras e escolhas que sirva para todo desenvolvedor. Isso para não mencionar algumas [brigas que parecem eternas](https://en.wikipedia.org/wiki/Editor\_war) (e das quais não queremos tomar partido!)

Devemos portanto nos ater ao mínimo necessário para que as demais atividades deste livro possam ser realizadas sem conflitos ou dificuldades. Como este livro tem seu foco em _Machine Learning_, vamos configurar um ambiente de desenvolvimento que permita desenvolver sistemas baseados em _Machine Learning_, um mundo onde Python reina absoluta [em termos de popularidade](https://towardsdatascience.com/what-is-the-best-programming-language-for-machine-learning-a745c156d6b7).

## Instalando o interpretador

A maioria dos sistemas operacionais já vem com alguma (ou mais de uma) versão do Python instalada e pronta para usar. Porém, as chances de que essa versão seja antiga, incompatível com alguma biblioteca mais moderna, são grandes. Portanto, é uma boa ideia instalar uma nova versão.

O problema é que manter duas (ou mais) versões de um mesmo interpretador no mesmo ambiente pode gerar conflitos. Há inúmeras formas de se resolver isso, [incluindo o uso do Docker](https://docs.docker.com/desktop/dev-environments/), mas aqui seguiremos um caminho mais simples: [pyenv](https://github.com/pyenv/pyenv).

A instalação é simples. Para Linux e Mac há instruções para isso na [página do projeto](https://github.com/pyenv/pyenv). Uma opção que simplifica a instalação é utilizar o [pyenv-installer](https://github.com/pyenv/pyenv-installer). Utilizando o pyenv-installer no Linux, todo o ambiente já é configurado, inclusive a instalação do ambiente virtual descrito abaixo.

Para Windows há um porte da ferramenta, chamado [pyenv-win](https://github.com/pyenv-win/pyenv-win). Há instruções de instalação na [página do projeto](https://github.com/pyenv-win/pyenv-win). No caso do Windows, para facilitar a execução dos comandos, recomenda-se o uso do PowerShell ou o [Git Bash](https://git-scm.com/downloads). Verifique sempre as configurações das variáveis de ambiente necessárias para o correto funcionamento dos comandos.

Depois que a instalação tiver sido bem-sucedida, execute o seguinte comando (procure seguir sempre a mesma versão dos exemplos, pois os códigos deste livro estão todos testados nesta versão. Caso queira mudar, faça-o por sua própria conta e risco :-)

```
pyenv update
pyenv install 3.10.2
```

Se tudo der certo, ao término da instalação será possível verificar quais interpretadores estão instalados em sua máquina. Execute o seguinte comando:

```
pyenv versions
```

O resultado deve ser algo parecido com o seguinte:

```
* system (set by /Users/fulano/...)
  3.10.2
  3.8.0
  3.7.2
```

Neste caso, existem quatro versões listadas, a do sistema (marcada com asterisco como sendo a vigente), e outras três.

Vamos trocar para que o sistema comece a utilizar a versão mais recente. Execute o comando:

```
pyenv global 3.10.2
```

Teste, executando:

```
python -V
```

O resultado deve ser `Python 3.10.2`, indicando que a versão instalada é a que está sendo reconhecida pelo sistema operacional.

É possível utilizar essa ferramenta para manter múltiplas versões do Python instaladas, adicionar novas, remover, entre outras tarefas. Consulte a página do projeto para mais detalhes sobre como fazer tudo isso. Para este livro, já temos o necessário para seguir adiante.

## Ambientes virtuais

Outra coisa que pode ser bastante útil é criar um ambiente separado para trabalhar. É comum que, em uma mesma máquina, você precise trabalhar em vários projetos Python. Também é comum que cada projeto tenha suas próprias características. Apesar de, em tese, ser possível que todo código Python seja executável pela versão mais recente do interpretador ou das bibliotecas, isso nem sempre é verdade, graças à [retrocompatibildade](https://en.wikipedia.org/wiki/Backward\_compatibility), um sonho tão distante em muitos cenários.

Mas não iremos entrar no mérito desse assunto, e sim dizer que há um jeito simples de evitar alguns dos problemas das diferentes versões do interpretador/bibliotecas: o uso de ambientes virtuais. Em um resumo simplificado, um ambiente virtual isola versões do interpretador e das bibliotecas. Assim, se um projeto A utiliza uma determinada versão do Python e da biblioteca X, e um projeto B utiliza uma outra versão do Python e da biblioteca X, e essas versões não são compatíveis, basta criar um ambiente virtual distinto para cada uma.

Faremos isso com um plugin do `pyenv`, chamado `pyenv-virtualenvwrapper`. Instruções para instalação podem ser encontradas na [página do projeto](https://github.com/pyenv/pyenv-virtualenvwrapper).

Após a instalação, podemos criar novos ambientes à vontade. Vamos criar um para todos os exemplos deste curso, com o seguinte comando:

```
pyenv virtualenv 3.10.2 devopsml
```

Sem entrar em muitos detalhes sobre o comando, podemos identificar duas coisas importantes:

* 3.10.2 é a versão do Python desse ambiente virtual
* `devopsml` é o nome do nosso ambiente virtual

Se o comando for bem-sucedido, deve ter sido criado um novo ambiente. Para verificar, execute:

```
pyenv virtualenvs
```

O ambiente `devopsml` deve aparecer na lista que for exibida, sendo também possível identificar a versão do python associada.

Agora vamos ativar nosso ambiente virtual recém-criado. Execute o seguinte comando:

```
pyenv activate devopsml
```

Se tudo der certo, o prompt do terminal deve passar a mostrar o nome do ambiente entre parêntesis, mais ou menos assim:

```
(devopsml) daniel@MacBook-Pro ~ % _
```

Para sair do ambiente virtual, pasta executar

```
(devopsml) daniel@MacBook-Pro ~ % pyenv deactivate
```

Em máquinas Windows, até o momento da escrita deste capítulo, não existe uma forma simples de instalar o `virtualenvwrapper` como plugin do `pyenv`. Para facilitar, criamos um [comando customizado para o Powershell](../exemplos/python-env/New-Python-Project.psm1). Basta instalá-lo em sua máquina e utilizá-lo conforme as instruções que estão no próprio arquivo.

Parabéns, se chegou até aqui já tem o que precisa para começar a desenvolver os exemplos do livro.

IMPORTANTE: sempre que for trabalhar em um novo projeto, verifique se o ambiente virtual está ativado, caso contrário você pode estar trabalhando no ambiente real (interpretador e bibliotecas instaladas no sistema), no qual não queremos mexer para evitar conflitos.
