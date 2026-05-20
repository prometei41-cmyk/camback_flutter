import requests
import json

SERVER_KEY = "ТВОЙ_SERVER_KEY"  # из Firebase → Project Settings → Cloud Messaging
FCM_URL = "https://fcm.googleapis.com/fcm/send"

def send_order_push(token, order_id):
    payload = {
        "to": token,
        "priority": "high",
        "notification": {
            "title": "Заказ обновлён",
            "body": "Курьер уже в пути"
        },
        "data": {
            "type": "open_order",
            "order_id": str(order_id),
            "click_action": "FLUTTER_NOTIFICATION_CLICK"
        }
    }

    headers = {
        "Authorization": f"key={SERVER_KEY}",
        "Content-Type": "application/json"
    }

    response = requests.post(FCM_URL, headers=headers, data=json.dumps(payload))
    print("STATUS:", response.status_code)
    print("RESPONSE:", response.text)


if __name__ == "__main__":
    token = "dLYq8A0_RnSdGcPyGkQkYa:APA91bGpenPiGVWx2zGeSowR4OtTwfVsrjvz9I16_E1J9ixuRgNmChj5IClMRn07UOwI0KdrLR5OrUnmpQCESdVaA94OAlVO4l-6-0KYqp_3fOPnTrilsFs"
    send_order_push(token, 1234)
