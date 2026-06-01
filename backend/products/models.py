
from django.db import models
from django.utils.translation import gettext_lazy as _ # Импорт для перевода

class Category(models.Model):
    name = models.CharField(max_length=100, verbose_name=_('Category Name'))
    image = models.URLField(blank=True, null=True, verbose_name=_('Category Image'))

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = _('Category')
        verbose_name_plural = _('Categories')


# Определяем варианты для поля 'badge'
BADGE_CHOICES = [
    ('new', _('New')),
    ('hit', _('Hit')),
    ('sale', _('Sale')),
    ('none', _('None')), # Для товаров без ярлыка
]

class Product(models.Model):
    category = models.ForeignKey(
        Category,
        on_delete=models.CASCADE,
        related_name='products',
        verbose_name=_('Category')
    )
    name = models.CharField(max_length=200, verbose_name=_('Product Name'))
    description = models.TextField(blank=True, verbose_name=_('Description'))
    price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name=_('Price'))
    image = models.URLField(blank=True, null=True, verbose_name=_('Product Image URL'))

    # Изменения:
    weight = models.DecimalField(
        max_digits=6,
        decimal_places=2,
        verbose_name=_('Weight (kg)'),
        blank=True,
        null=True,
        help_text=_('Enter weight in kilograms (e.g., 0.50 for 500g).')
    )
    calories = models.IntegerField(
        verbose_name=_('Calories'),
        blank=True,
        null=True,
        help_text=_('Enter the approximate calorie count.')
    )
    allergens = models.TextField(
        verbose_name=_('Allergens'),
        blank=True,
        null=True,
        help_text=_('List of allergens, separated by commas (e.g., Milk, Nuts, Gluten).')
    )
    badge = models.CharField(
        max_length=10,  # Уменьшили длину, так как варианты ограничены
        choices=BADGE_CHOICES,
        default='none',
        verbose_name=_('Badge'),
        help_text=_('Select a badge for the product.')
    )

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = _('Product')
        verbose_name_plural = _('Products')
