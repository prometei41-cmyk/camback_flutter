
from rest_framework import serializers
from .models import Category, Product 

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'image'] # Поля для категории

class ProductSerializer(serializers.ModelSerializer):
    # Добавляем сериализатор для поля category, чтобы передавать его данные
    category = CategorySerializer()

    class Meta:
        model = Product
        fields = [
            'id',
            'name',
            'description',
            'price',
            'image',
            'weight',      # Уже есть
            'calories',    # Добавлено
            'allergens',   # Добавлено
            'badge',       # Уже есть
            'category'     # Добавлено
        ]
