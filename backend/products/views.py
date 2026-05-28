from django.db.models import Q
from rest_framework import generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from .models import Category, Product
from .serializers import CategorySerializer, ProductSerializer


class CategoryListView(generics.ListAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [AllowAny]
    authentication_classes = []


class ProductListView(generics.ListAPIView):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = [AllowAny]
    authentication_classes = []


class ProductDetailView(generics.RetrieveAPIView):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = [AllowAny]
    authentication_classes = []


@api_view(['GET'])
@permission_classes([AllowAny])
def search_products(request):
    """
    Search products by name or description
    Query param: q (minimum 2 characters)
    """
    query = request.query_params.get('q', '').strip()
    
    if not query or len(query) < 2:
        return Response({'error': 'Search query too short (minimum 2 characters)'}, status=400)
    
    # Search by name and description
    products = Product.objects.filter(
        Q(name__icontains=query) | Q(description__icontains=query)
    ).select_related('category')
    
    serializer = ProductSerializer(products, many=True)
    return Response(serializer.data)
