from rest_framework import viewsets
from .models import Service
from .serializers import ServiceSerializer


class ServiceViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing Service objects.
    """
    queryset = Service.objects.all()
    serializer_class = ServiceSerializer