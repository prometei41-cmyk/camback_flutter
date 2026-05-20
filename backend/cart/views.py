from django.shortcuts import render

from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.authentication import JWTAuthentication

from .models import CartItem
from .serializers import CartItemSerializer
from products.models import Product

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def clear_cart(request):
    CartItem.objects.filter(user=request.user).delete()
    return Response({'status': 'ok'})

class CartListView(generics.ListAPIView):
    serializer_class = CartItemSerializer
    authentication_classes = [JWTAuthentication]

    def get_queryset(self):
        return CartItem.objects.filter(user=self.request.user)


class AddToCartView(generics.CreateAPIView):
    authentication_classes = [JWTAuthentication]

    def post(self, request):
        product_id = request.data.get('product_id')
        quantity = int(request.data.get('quantity', 1))

        product = Product.objects.get(id=product_id)

        item, created = CartItem.objects.get_or_create(
            user=request.user,
            product=product,
        )

        if not created:
            item.quantity += quantity

        item.save()

        return Response({'message': 'Added to cart'})


class UpdateCartItemView(generics.UpdateAPIView):
    serializer_class = CartItemSerializer
    authentication_classes = [JWTAuthentication]
    queryset = CartItem.objects.all()

    def put(self, request, *args, **kwargs):
        item_id = request.data.get('item_id')
        qty = request.data.get('quantity')

        item = CartItem.objects.get(id=item_id, user=request.user)
        item.quantity = qty
        item.save()

        return Response({'message': 'Updated'})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
@authentication_classes([JWTAuthentication])
def remove_item(request):
    item_id = request.data.get('item_id')
    CartItem.objects.filter(id=item_id, user=request.user).delete()
    return Response({'message': 'Removed'})


