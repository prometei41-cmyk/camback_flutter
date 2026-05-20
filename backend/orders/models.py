from django.conf import settings
from django.db import models
from products.models import Product

class Order(models.Model):
    PAYMENT_CHOICES = [
        ('card', 'Card online'),
        ('cash', 'Cash to courier'),
    ]

    DELIVERY_CHOICES = [
        ('asap', 'As soon as possible'),
        ('30min', 'In 30 minutes'),
        ('interval', 'Selected interval'),
    ]

    STATUS_CHOICES = [
        ('pending', 'Ожидает подтверждения'),
        ('preparing', 'Готовится'),
        ('on_the_way', 'В пути'),
        ('delivered', 'Доставлен'),
    ]

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending'
    )

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    address = models.ForeignKey(
        'addresses.Address',
        on_delete=models.CASCADE,
        related_name='orders'
    )

    comment = models.TextField(blank=True)
    payment_method = models.CharField(max_length=20, choices=PAYMENT_CHOICES)
    delivery_time = models.CharField(max_length=20, choices=DELIVERY_CHOICES)
    promo_code = models.CharField(max_length=50, blank=True)
    total_price = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)
    payment_id = models.CharField(max_length=255, blank=True, null=True)  # ID от Эватора
    payment_status = models.CharField(max_length=20, default='pending')  # pending, paid, failed


class OrderItem(models.Model):
    order = models.ForeignKey(Order, related_name="items", on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField()
    price = models.DecimalField(max_digits=10, decimal_places=2)