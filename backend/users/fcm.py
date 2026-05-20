import json
import requests
from google.oauth2 import service_account
from google.auth.transport.requests import Request


def get_google_access_token():
    """Получаем OAuth2 токен для FCM HTTP v1."""
    credentials = service_account.Credentials.from_service_account_file(
        "firebase-adminsdk.json",
        scopes=["https://www.googleapis.com/auth/firebase.messaging"],
    )
    credentials.refresh(Request())
    return credentials.token


def send_push_v1(token: str, title: str, body: str, data: dict = None):
    """Отправка пуша через FCM HTTP v1."""
    access_token = get_google_access_token()

    message = {
        "message": {
            "token": token,
            "notification": {
                "title": title,
                "body": body,
            },
            "data": data or {},
        }
    }

    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json; UTF-8",
    }

    url = "https://fcm.googleapis.com/v1/projects/delivery-app-cameback-20-fbcfe/messages:send"

    response = requests.post(url, headers=headers, data=json.dumps(message))
    return response.json()
