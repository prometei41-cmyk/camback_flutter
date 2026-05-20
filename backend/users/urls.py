from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import save_fcm_token, test_push, create_notification, NotificationViewSet

router = DefaultRouter()
router.register(r'notifications', NotificationViewSet, basename='notification')

urlpatterns = [
    path("save_fcm_token/", save_fcm_token),
    path("push/test/", test_push),
    path("notifications/create/", create_notification),
    path('', include(router.urls)),
]
