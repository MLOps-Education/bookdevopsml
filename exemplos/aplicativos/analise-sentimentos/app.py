from classificador.model import Model
from kafka import KafkaConsumer
import json

# Conecta o classificador ao Kafka, em servidor local, no tópico "chatbot"
consumer = KafkaConsumer('chatbot', bootstrap_servers='broker:29092')

# Carrega o modelo BERT pré-treinado (demora um tempinho)
print('Carregando modelo...')
model = Model()
print('Modelo carregado!')

# Enquanto houver mensagens, analisa o sentimento
for msg in consumer:
    obj = json.loads(msg.value)
    sentiment, confidence, probabilities = model.predict(obj['pergunta'])
    sentimento = ':|'
    if sentiment == 'negative':
        sentimento = ':('
    elif sentiment == 'positive':
        sentimento = ':)'
    print (sentimento + ' ' + obj['nome']+' disse '+obj['pergunta'])
    if sentiment == 'negative':
        print('Atendente humano, converse com o usuário '+obj['nome']+' na sessão '+obj['sessao']+"! Rápido!")