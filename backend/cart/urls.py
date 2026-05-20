from django.urls import path
from .views import CartListView, AddToCartView, UpdateCartItemView, remove_item, clear_cart

urlpatterns = [
    path('', CartListView.as_view()),               # GET /api/cart/
    path('add/', AddToCartView.as_view()),          # POST /api/cart/add/
    path('update/', UpdateCartItemView.as_view()),  # PUT /api/cart/update/
    path('remove/', remove_item),  # POST /api/cart/remove/
    path('clear/', clear_cart),                     # POST /api/cart/clear/
]
