# 8.4 Testando tudo junto

Seguindo a tradição do capítulo anterior, vamos agora fazer um processo completo, do início ao fim, onde configuraremos um novo modelo para deploy automático no Heroku via GitLab. Vamos reutilizar o projeto MLServer que já criamos antes, e focaremos aqui em criar um novo modelo e atualizá-lo depois.

Vamos fazer o exemplo do classificador de produtos, assim poderemos ver a mudança refletida no produto final.

O primeiro passo é criar uma nova pasta para o projeto, chamada `classificador-produtos`. Crie um ambiente virtual, e instale as seguintes dependências:

```
jupyter==1.0.0
pandas==1.4.2
nltk==3.7
matplotlib==3.5.2
seaborn==0.11.2
scikit-learn==1.1.1
papermill==2.3.4
```

O arquivo `.gitignore` terá o seguinte conteúdo:

```
.venv
*.joblib
```

Agora copie os arquivos para o projeto:

* [produtos.csv](codigo/classificador-produtos/produtos.csv) - conjunto de dados anotado contendo produtos e sua classificação. Existem quatro categorias de produtos neste conjunto: game, maquiagem, brinquedo e livro
* [classificador-produtos.ipynb](codigo/classificador-produtos/classificador-produtos.ipynb) - notebook com a solução para classificação de produtos, já modificado conforme alterações que fizemos na [Seção 8.2](./8-2-model-serving-com-mlserver.md).

Execute e veja que nessa versão o modelo não lida bem com a falta de acentos ao detectar a categoria dos exemplos.

Veja também que as nomenclaturas são todas respeitadas. Tanto notebook quanto arquivo salvos tem o mesmo nome.

Crie um arquivo chamado `model-settings.json` (veja como é parecido com o da seção anterior):

```
{
    "name": "classificador-produtos",
    "implementation": "mlserver_sklearn.SKLearnModel",
    "parameters": {
        "uri": "classificador-produtos.joblib",
        "version": "$VERSAO"
    }
}
```

Por último, crie o arquivo `.gitlab-ci.yml`. A única diferença em relação ao exemplo da seção anterior é o nome do modelo, o que demonstra que nosso script está bastante reutilizável:

```yml
stages:
  - release
 
variables:
  DOCKER_TLS_CERTDIR: ""
  NOME_MODELO: "classificador-produtos"
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

Agora vá ao GitLab e crie um novo projeto, chamado "classificador-produtos". Após concluir a criação, acesse o menu "Settings" -> "CI/CD" -> "Variables". Crie três variáveis, e lembre-se de deixá-las protegidas:

* `GIT_USER_EMAIL`: configure seu e-mail aqui
* `GIT_USER_NAME`: configure um nome aqui para ficar registrado que os _commits_ estão vindo do GitLab. Pode ser: "GitLab classificador-produtos"
* `MLSERVER_REPO`: coloque aqui a URL completa usada no comando `git clone`. No exemplo, é `https://access-mlserver:xxxxxxxxxxxxxxxxxx@gitlab.com/daniel.lucredio/mlserver.git` (substituindo xxxxxx pelo token de acesso)

Agora vamos proteger as _tags_. Acesse "Settings" -> "Repository" -> "Protected tags".

No campo "Tag", especifique "v*".

No campo "Allowed to create", especifique "Maintainers".

Não se esqueça de salvar as mudanças.

Agora podemos inicializar o repositório na pasta local, fazer nosso envio e aguardar até que o modelo chegue até o Heroku:

```sh
git init --initial-branch=main
git remote add origin https://gitlab.com/daniel.lucredio/classificador-produtos.git
git add .
git commit -m "Initial commit"
git push -u origin main
git tag -a v1.0.0 -m "Primeiro release"
git push --tags
```

Vamos testar:

```
POST http://dlucredio-mlserver.herokuapp.com/mlapi/v2/models/classificador-produtos/versions/v1.0.0/infer
Content-Type: application/json

{
    "inputs": [
        {
            "name": "predict",
            "shape": [3],
            "datatype": "BYTES",
            "data": [ "Minecraft", "Senhor dos aneis", "Senhor dos anéis" ]
        }
    ]
}
```

O resultado, como esperado, é o reconhecimento errado de um dos produtos. Vamos corrigir no `requirements.txt`, como já fizemos antes:

```diff
jupyter==1.0.0
pandas==1.4.2
nltk==3.7
matplotlib==3.5.2
seaborn==0.11.2
scikit-learn==1.1.1
papermill==2.3.4
+unidecode==1.3.4
```

Agora no notebook, no seguinte local:

```diff
import pandas as pd
import nltk
from nltk.corpus import stopwords
+from unidecode import unidecode

...

stop_words=set(stopwords.words("portuguese"))
# transforma a string em caixa baixa e remove stopwords

-products_data['sem_stopwords'] = products_data['informacao'].str.lower().apply(lambda x: ' '.join([word for word in x.split() if word not in (stop_words)]))
+products_data['sem_stopwords'] = products_data['informacao'].str.lower().apply(lambda x: ' '.join([unidecode(word) for word in x.split() if word not in (stop_words)]))

...
```

Teste localmente, para garantir que o erro está corrigido. Agora basta fazer um novo _commit_ e _release_:

```
git commit -am "Corrigindo modelo para tratamento de acentos" 
git push
git tag -a v1.0.1 -m "Pequena correção"
git push --tags
```

Após alguns minutos, sem nenhuma necessidade de esforço manual além do trabalho com o notebook, o novo modelo estará pronto no MLServer:

```
POST http://dlucredio-mlserver.herokuapp.com/mlapi/v2/models/classificador-produtos/versions/v1.0.1/infer
Content-Type: application/json

{
    "inputs": [
        {
            "name": "predict",
            "shape": [3],
            "datatype": "BYTES",
            "data": [ "Minecraft", "Senhor dos aneis", "Senhor dos anéis" ]
        }
    ]
}
```

Lembrando que a versão anterior ainda está disponível no MLServer para consulta.

## Considerações finais

Chegamos ao fim de mais um capítulo, e mais uma vez conseguimos um processo automatizado bem completo. Do início ao fim, assim que um _commit_ especial é feito no GitLab (marcado com uma _tag_), basta esperar e a nova versão do modelo estará no ar em poucos minutos, sem que o desenvolvedor precise fazer nada manualmente.

Esse processo que fizemos aqui é mais didático do que funcional. O leitor mais atento deve ter percebido que clonar todo o repositório do MLServer a cada envio de novo modelo ou nova versão pode ficar rapidamente custoso à medida que a quantidade de modelos aumenta. O ideal seria configurar o MLServer para que ele acessasse os modelos a partir de um volume, por exemplo, assim poderíamos simplesmente salvar o novo modelo nesse volume e reiniciar o servidor para que ele carregue o novo modelo. Mas o Heroku, que utilizamos aqui, não tem suporte a volumes Docker. Além disso, recarregar todo o servidor, a todo momento, também não é ideal. O correto seria usar uma solução _serverless_, com cópias criadas para atender às requisições de acordo com a demanda. Mas aí a limitação é do MLServer. Trata-se de um componente limitado, que não possui essa funcionalidade.

É para isso que existem outras soluções como [Seldon core](https://www.seldon.io/solutions/open-source-projects/core) ou [Kserve](https://kserve.github.io/website). Eles resolvem esses problemas utilizando camadas de orquestração por baixo, além de oferecer acesso a modelos salvos em repositórios como Amazon S3, muito mais apropriados para armazenamento de arquivos a baixo custo. Além disso, eles dão suporte a outras funções, como a criação de pré e pós-processamento, distribuição automática de carga entre versões, para testes do tipo canário, além de outras tarefas úteis. Porém, sua instalação e configuração são muito mais complexas, o que deixaria nosso livro mais parecido com um manual de operações de clusters do que um livro que ensina os conceitos fundamentais de MLOps.

Mas não fique triste, achando que tudo o que você aprendeu até agora foi à toa! Saiba que o MLServer, apesar de simples, é o componente que está no núcleo do Seldon core e do Kserve, portanto o princípio da hospedagem de modelos que você aprendeu aqui não muda caso você esteja trabalhando com uma ferramenta mais robusta. A diferença é o melhor desempenho e escalabilidade e as funções adicionais.