from chatterbot import ChatBot
from chatterbot.trainers import ChatterBotCorpusTrainer
import uuid
from kafka import KafkaProducer
import json

# Configuração da sessão de chat
sessao = uuid.uuid4()
nome_bot = "Robô"
chatbot = ChatBot(nome_bot, read_only=True)

# Configuração do Kafka
producer = KafkaProducer(bootstrap_servers='localhost:9092',
                        value_serializer=lambda v: json.dumps(v).encode('utf-8'))
topico = 'chatbot'

# Treinando o robô
trainer = ChatterBotCorpusTrainer(chatbot)
trainer.train(
    "chatterbot.corpus.portuguese"
)

# Início da interação com o usuário
print("Sessão de chat iniciada: "+str(sessao))
nome = input('Digite o seu nome: ')

# Conversa principal
while True:
    # Lê pergunta do usuário
    pergunta = input(nome+': ')

    # Envia pergunta ao chatbot e obtém resposta
    resposta = chatbot.get_response(pergunta)

    # Monta o evento e envia ao Kafka
    evento = {
        'sessao': str(sessao),
        'nome': nome,
        'pergunta': pergunta,
        'resposta': str(resposta)
    }
    producer.send(topico, evento)

    # Imprime a conversa na tela
    print(nome_bot+': '+str(resposta)+'\n')