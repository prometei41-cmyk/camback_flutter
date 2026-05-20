import json
import requests
from google.oauth2 import service_account
from google.auth.transport.requests import Request

PROJECT_ID = "your-project-id"
SCOPES = ["https://www.googleapis.com/auth/firebase.messaging"]
SERVICE_ACCOUNT_FILE = "../delivery-app-cameback-20-fbcfe-firebase-adminsdk-fbsvc-db4042794b.json"


def get_access_token():
    credentials = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE, scopes=SCOPES
    )
    credentials.refresh(Request())
    return credentials.token


def send_push_v1(token: str, order_id: int):
    url = f"https://fcm.googleapis.com/v1/projects/{PROJECT_ID}/messages:send"

    message = {
        "message": {
            "token": token,
            "notification": {
                "title": "Заказ обновлён",
                "body": "Курьер уже в пути"
            },
            "data": {
                "type": "open_order",
                "order_id": str(order_id)
            }
        }
    }

    headers = {
        "Authorization": f"Bearer {get_access_token()}",
        "Content-Type": "application/json; UTF-8",
    }

    response = requests.post(url, headers=headers, data=json.dumps(message))
    print(response.text)
