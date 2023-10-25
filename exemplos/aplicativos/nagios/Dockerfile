FROM jasonrivers/nagios:latest

LABEL maintainer="auri@ufscar.br, g4briel.4lves@gmail.com, daniel.lucredio@ufscar.br"

ENV NAGIOS_TIMEZONE="America/Sao_Paulo"

# Configurações do POSTFIX
RUN apt update
RUN apt install -y vim nano postfix mailutils libsasl2-2 ca-certificates libsasl2-modules
ADD postfix/main.cf /etc/postfix/
ADD postfix/sasl_passwd /etc/postfix/sasl/
ADD postfix/sasl_passwd.db /etc/postfix/sasl/
RUN chown -R root:postfix /etc/postfix/sasl
RUN chmod 750 /etc/postfix/sasl
RUN chmod 640 /etc/postfix/sasl/sasl_passwd*

ADD conf.d/*.cfg /opt/nagios/etc/objects/customconfig/
ADD nagios.cfg /opt/nagios/etc/
ADD contacts.cfg /opt/nagios/etc/objects/

EXPOSE 80