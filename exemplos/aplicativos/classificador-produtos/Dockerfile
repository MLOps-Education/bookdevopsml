# Primeiro definimos qual imagem usar como base.
# Para isso, utilizamos o comando "FROM" e o nome da imagem obtido do Docker Hub
FROM python:3.9.6-slim

# Em seguida, definimos uma pasta de trabalho. É aqui que os comandos a seguir
# serão executados.
# Normalmente, cada imagem tem um valor pré-definido, procure na documentação.
# Esta aqui é a pasta padrão da imagem que escolhemos.
# Caso queira utilizar outro, fique à vontade, mas é preciso conhecer exatamente
# a estrutura de arquivos da imagem utilizada.
WORKDIR /usr/src/app

# Agora vamos instalar os pacotes necessários. Por sorte, já temos tudo
# definido no arquivo "requirements.txt", incluindo as versões já testadas
# Basta copiar o arquivo para a pasta de trabalho
COPY requirements.txt ./

# E executar o comando "pip install"
RUN pip install --no-cache-dir -r requirements.txt

# Agora vamos copiar o restante dos arquivos
COPY . .

# A partir de agora, já temos tudo instalado
# O último comando instrui o Docker sobre como rodar nossa aplicação.
# No caso, basta rodar "python app.py". No Docker, isso fica estruturado
# dentro do comando "CMD"
CMD [ "python", "./app.py" ]