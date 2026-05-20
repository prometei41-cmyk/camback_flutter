from django.urls import path
from .views import create_order, OrderHistoryView, set_order_on_the_way, set_order_preparing, set_order_delivered, \
    cancel_order, create_payment, payment_callback

urlpatterns = [
    path('create/', create_order, name='create_order'),
    path('history/', OrderHistoryView.as_view()),
    path("<int:order_id>/preparing/", set_order_preparing),
    path("<int:order_id>/on_the_way/", set_order_on_the_way),
    path("<int:order_id>/delivered/", set_order_delivered),
    path("<int:order_id>/cancel/", cancel_order),
    path('create_payment/', create_payment),
    path('callback/', payment_callback),
]
