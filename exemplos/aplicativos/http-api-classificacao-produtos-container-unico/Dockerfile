FROM python:3.9.6-slim

# Instalação do nginx

# Vamos rodar apt update sem precisar interagir. Essa flag diz isso.
ENV DEBIAN_FRONTEND=noninteractive

# Agora vamos instalar nginx, passando a opção -y para aceitar os prompts
# Após a instalação, vamos remover os caches criados pelo apt update,
# Assim nossa imagem fica mais limpa
RUN apt update && apt install -y nginx && rm -rf /var/lib/apt/lists/*

# Vamos copiar os arquivos estáticos para www (pasta configurada para o nginx)
COPY webclient/* /www/

# E agora vamos copiar o arquivo de configuração do nginx
COPY default /etc/nginx/sites-available/default

# A porta 80 será a utilizada pelo nginx. Vamos expô-la
EXPOSE 80/tcp

# Agora vamos às configurações do nosso app original
WORKDIR /usr/src/app

# Aqui vamos copiar os arquivos um a um, pois agora temos outros
# arquivos que não fazem parte da aplicação e não faz sentido copiar
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY model.sav ./
COPY app.py ./

# Agora vamos copiar um script que roda as duas coisas
# nginx e gunicorn

COPY entrypoint.sh ./
RUN chmod 755 ./entrypoint.sh

CMD ["./entrypoint.sh"]