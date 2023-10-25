import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import pickle # Importa pickle

model = pickle.load(open('model.sav', 'rb')) # Carrega o modelo do disco

# substitua o nome do arquivo .json a seguir pela chave .json que você baixou
# do console do Firebase
cred = credentials.Certificate("key.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

produtos_ref = db.collection('produtos')
docs = produtos_ref.stream()

for doc in docs:
    d = doc.to_dict()
    print('Descrição = {}\n   Categoria = {} '.format(d['descricao'], d['categoria']))
    input_message = [d['descricao']] # Monta a mensagem para servir de entrada ao modelo
    input_message = model["vect"].transform(input_message) # Aplica o preprocessamento na entrada
    final_prediction = model["clf"].predict(input_message)[0] # Realiza a predição
    doc_ref = db.collection('produtos').document(doc.id) # Obtém uma referência para o documento no BD
    doc_ref.update({"categoria": final_prediction}) # Salva o resultado no banco de dados