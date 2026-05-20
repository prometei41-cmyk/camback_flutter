from rest_framework.decorators import api_view, permission_classes
from rest_framework import generics
from rest_framework.generics import get_object_or_404
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from .models import Order, OrderItem
from products.models import Product
from addresses.models import Address
import requests
from django.conf import settings

from .serializers import OrderSerializer
from .push import push_order_created, push_order_status, push_to_client  # ← ВАЖНО: импортируем пуш-функцию


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_order(request):
    data = request.data

    # Проверяем адрес
    try:
        address = Address.objects.get(id=data['address_id'], user=request.user)
    except Address.DoesNotExist:
        return Response(
            {"error": "Адрес не найден или не принадлежит пользователю"},
            status=400
        )

    # Создаём заказ
    order = Order.objects.create(
        user=request.user,
        address=address,
        comment=data.get('comment', ''),
        payment_method=data['payment_method'],
        delivery_time=data['delivery_time'],
        promo_code=data.get('promo_code', ''),
        total_price=data['total_price'],
    )

    # Создаём позиции заказа
    for item in data['items']:
        try:
            product = Product.objects.get(id=item['product_id'])
        except Product.DoesNotExist:
            return Response({"error": "Товар не найден"}, status=400)

        OrderItem.objects.create(
            order=order,
            product=product,
            quantity=item['quantity'],
            price=product.price
        )

    # 🔥 ПУШ ВЛАДЕЛЬЦУ (через push.py)
    push_order_created(order)

    return Response({"status": "ok", "order_id": order.id}, status=201)

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def set_order_preparing(request, order_id):
    try:
        order = Order.objects.get(id=order_id)
    except Order.DoesNotExist:
        return Response({"error": "Заказ не найден"}, status=404)

    order.status = "preparing"
    order.save()

    push_order_status(order)

    return Response({"status": "ok", "order_id": order.id})

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def set_order_on_the_way(request, order_id):
    try:
        order = Order.objects.get(id=order_id)
    except Order.DoesNotExist:
        return Response({"error": "Заказ не найден"}, status=404)

    order.status = "on_the_way"
    order.save()

    push_order_status(order)

    return Response({"status": "ok", "order_id": order.id})

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def set_order_delivered(request, order_id):
    try:
        order = Order.objects.get(id=order_id)
    except Order.DoesNotExist:
        return Response({"error": "Заказ не найден"}, status=404)

    order.status = "delivered"
    order.save()

    push_order_status(order)

    return Response({"status": "ok", "order_id": order.id})

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def cancel_order(request, order_id):
    try:
        order = Order.objects.get(id=order_id, user=request.user)
    except Order.DoesNotExist:
        return Response({"error": "Заказ не найден"}, status=404)

    order.status = "cancelled"
    order.save()

    push_order_status(order)

    return Response({"status": "ok", "order_id": order.id})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_payment(request):
    order = get_object_or_404(Order, id=request.data['order_id'], user=request.user)
    if order.payment_status != 'pending':
        return Response({'error': 'Заказ уже оплачен'}, status=400)

    # Данные для Эватора
    data = {
        'shop_id': settings.EVOTOR_SHOP_ID,
        'amount': str(order.total_price),
        'currency': 'RUB',
        'description': f'Заказ #{order.id}',
        'success_url': 'yourapp://success',  # Для возврата в app
        'fail_url': 'yourapp://fail',
        'callback_url': 'https://yourdomain.com/api/payments/callback/',
        'email': request.user.email,
    }

    # Отправка в Эватор
    response = requests.post('https://api.evotor.ru/v1/payments', json=data, auth=(settings.EVOTOR_SHOP_ID, settings.EVOTOR_SECRET))
    if response.status_code == 200:
        payment_data = response.json()
        order.payment_id = payment_data['id']
        order.save()
        return Response({'payment_url': payment_data['payment_url']})
    else:
        return Response({'error': 'Ошибка создания платежа'}, status=400)

@api_view(['POST'])
@permission_classes([AllowAny])  # Без авторизации для webhook
def payment_callback(request):
    # Проверь подпись (Эватор отправляет signature)
    # ... код проверки

    payment_id = request.data['id']
    status = request.data['status']  # 'success' или 'failed'

    order = Order.objects.get(payment_id=payment_id)
    order.payment_status = 'paid' if status == 'success' else 'failed'
    order.save()

    # Отправь push пользователю
    if status == 'success':
        push_to_client(order.user, 'Оплата успешна', f'Заказ #{order.id} оплачен')

    return Response({'status': 'ok'})

class OrderHistoryView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Order.objects.filter(user=self.request.user).order_by('-created_at')


