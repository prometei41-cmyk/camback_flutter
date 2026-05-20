from users.models import User
from users.fcm import send_push_v1

def push_order_status(order, status_text):
    owner = User.objects.filter(is_superuser=True).first()
    if owner and owner.fcm_token:
        send_push_v1(
            token=owner.fcm_token,
            title="Статус заказа",
            body=f"Заказ №{order.id}: {status_text}",
            data={"order_id": str(order.id), "status": status_text}
        )
