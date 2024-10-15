import flask
from flask import request
import os
from bot import ObjectDetectionBot
import boto3 

app = flask.Flask(__name__)

dynamodb = boto3.resource('dynamodb', region_name='eu-north-1')
# TODO load TELEGRAM_TOKEN value from Secret Manager
TELEGRAM_TOKEN = '7550116941:AAG-GkW_PZVfkJ77_EK1xNxteiMBWnttR0E'

TELEGRAM_APP_URL = 'https://hip-separately-dragon.ngrok-free.app'


@app.route('/', methods=['GET'])
def index():
    return 'Ok'


@app.route(f'/{TELEGRAM_TOKEN}/', methods=['POST'])
def webhook():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


@app.route(f'/results', methods=['POST'])
def results():
    prediction_id = request.args.get('prediction_id')
    table = dynamodb.Table("BotYolo5")

    # TODO use the prediction_id to retrieve results from DynamoDB and send to the end-user
    response= table.get_item(Key={'prediction_id':prediction_id})
    class_counts={}

    chat_id = int(response['Item']['chat_id'])
    labels=response['Item']['labels']
    for x in labels:
        name = x['class']
        if name in class_counts:
            class_counts[name] += 1
        else:
            class_counts[name] = 1 
    print(class_counts)
    text_results=[]
    for name,count in class_counts.items():
        text_results.append(f"There are {count} {name}(s).")
    result_message = "\n".join(text_results)
    #text_results =response['Item']['labels'][0]['class']

    bot.send_text(chat_id, result_message)
    return 'Ok'


@app.route(f'/loadTest/', methods=['POST'])
def load_test():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


if __name__ == "__main__":
    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)

    app.run(host='0.0.0.0', port=8443)
