from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework import viewsets
from .fcm import send_push_v1
from .models import Notification
from .serializers import NotificationSerializer

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def save_fcm_token(request):
    token = request.data.get("token")
    if not token:
        return Response({"error": "Token is required"}, status=400)

    request.user.fcm_token = token
    request.user.save()

    return Response({"status": "ok"})

@api_view(["POST"])
@permission_classes([AllowAny])
def test_push(request):
    token = request.data.get("token")
    if not token:
        return Response({"error": "token required"}, status=400)

    result = send_push_v1(
        token=token,
        title="Тестовый пуш",
        body="Проверяем доставку",
        data={"order_id": "123"}
    )

    return Response({"status": "sent", "google": result})

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def create_notification(request):
    serializer = NotificationSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(user=request.user)
        return Response(serializer.data, status=201)
    return Response(serializer.errors, status=400)

class NotificationViewSet(viewsets.ModelViewSet):
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return self.request.user.notifications.all()

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
