import json
import requests
import os
from datetime import datetime

HOP_URL = os.environ['HOP_URL']
HOP_USERNAME = os.environ['HOP_USERNAME']
HOP_PASSWORD = os.environ['HOP_PASSWORD']

def lambda_handler(event, context):

    payload = {
        "workflow": "daily-orchestration"
    }

    response = requests.post(
        HOP_URL,
        auth=(HOP_USERNAME, HOP_PASSWORD),
        json=payload
    )

    print(response.text)

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Workflow triggered",
            "time": str(datetime.now())
        })
    }