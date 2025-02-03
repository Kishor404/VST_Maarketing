from rest_framework import viewsets
from .models import Service
from .serializers import ServiceSerializer
from rest_framework.permissions import AllowAny


class ServiceViewSet(viewsets.ModelViewSet):
    permission_classes = [AllowAny]

    """
    ViewSet for managing Service objects.
    """
    queryset = Service.objects.all()
    serializer_class = ServiceSerializer