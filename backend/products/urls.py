from django.urls import path
from .views import CategoryListView, ProductListView, ProductDetailView, search_products

urlpatterns = [
    path('categories/', CategoryListView.as_view()),
    path('products/', ProductListView.as_view()),
    path("products/<int:pk>/", ProductDetailView.as_view()),
    path('search/', search_products, name='search_products'),
]
