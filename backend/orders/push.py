from users.models import User
from users.fcm import send_push_v1

STATUS_TEXT = {
    "pending": "Ожидает подтверждения",
    "preparing": "Готовится",
    "on_the_way": "В пути",
    "delivered": "Доставлен",
    "cancelled": "Отменён",
    "paid": "Оплачен",
}

def push_to_owner(title: str, body: str, data: dict):
    owner = User.objects.filter(is_superuser=True).first()
    if owner and owner.fcm_token:
        send_push_v1(
            token=owner.fcm_token,
            title=title,
            body=body,
            data=data
        )

def push_order_created(order):
    push_to_owner(
        title="Новый заказ",
        body=f"Поступил заказ №{order.id}",
        data={"order_id": str(order.id)}
    )

def push_order_status(order):
    status_text = STATUS_TEXT.get(order.status, order.status)
    push_to_owner(
        title="Статус заказа",
        body=f"Заказ №{order.id}: {status_text}",
        data={"order_id": str(order.id), "status": order.status}
    )

def push_to_client(user, title: str, body: str, data: dict):
    if user and user.fcm_token:
        send_push_v1(
            token=user.fcm_token,
            title=title,
            body=body,
            data=data
        )
