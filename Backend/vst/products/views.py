from rest_framework import viewsets
from .models import Product
from .serializers import ProductSerializer


class ProductViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing Product objects.
    """
    queryset = Product.objects.all()
    serializer_class = ProductSerializer