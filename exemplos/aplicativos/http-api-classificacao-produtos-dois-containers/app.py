from flask import Flask, request, jsonify
import pickle

app = Flask(__name__)

model = pickle.load(open('model.sav', 'rb'))

@app.route('/predizer_categoria', methods=['POST'])
def predizer_categoria():
    request_data = request.get_json()
    input_message = [request_data['descricao']]
    input_message = model["vect"].transform(input_message)
    final_prediction = model["clf"].predict(input_message)[0]

    response = {
        'categoria': final_prediction
    }

    return jsonify(response)