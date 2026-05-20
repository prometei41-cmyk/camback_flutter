from django.db import models

from django.db import models
from django.conf import settings

class Address(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="addresses"
    )

    label = models.CharField(max_length=50, default="Дом")  # Название адреса
    street = models.CharField(max_length=255)
    house = models.CharField(max_length=20)
    corpus = models.CharField(max_length=20, blank=True)
    entrance = models.CharField(max_length=10, blank=True)
    floor = models.CharField(max_length=10, blank=True)
    flat = models.CharField(max_length=10, blank=True)
    comment = models.TextField(blank=True)

    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)

    is_default = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.label}: {self.street} {self.house}"

