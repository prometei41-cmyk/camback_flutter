from django.shortcuts import render
from requests import Response
from rest_framework import generics
from rest_framework.decorators import api_view
from rest_framework.permissions import IsAuthenticated


from .models import Address
from .serializers import AddressSerializer


class AddressListView(generics.ListAPIView):
    serializer_class = AddressSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Address.objects.filter(user=self.request.user)

class AddressCreateView(generics.CreateAPIView):
    serializer_class = AddressSerializer

    def perform_create(self, serializer):
        user = self.request.user

        # Если это первый адрес — делаем его default
        is_first = not Address.objects.filter(user=user).exists()

        serializer.save(
            user=user,
            is_default=is_first
        )

class AddressUpdateView(generics.UpdateAPIView):
    serializer_class = AddressSerializer
    queryset = Address.objects.all()

    def get_queryset(self):
        return Address.objects.filter(user=self.request.user)

class AddressDeleteView(generics.DestroyAPIView):
    serializer_class = AddressSerializer

    def get_queryset(self):
        return Address.objects.filter(user=self.request.user)

@api_view(['POST'])
def set_default_address(request, pk):
    user = request.user

    Address.objects.filter(user=user, is_default=True).update(is_default=False)
    Address.objects.filter(user=user, id=pk).update(is_default=True)

    return Response({"status": "ok"})
