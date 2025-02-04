from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import Service
from .serializers import ServiceSerializer


class ServiceViewSet(viewsets.ModelViewSet):

    """
    ViewSet for managing Service objects.
    """
    serializer_class = ServiceSerializer
    permission_classes = [IsAuthenticated] 

    def get_queryset(self):
        """
        Override get_queryset to return services for the authenticated user.
        """
        user = self.request.user  # Extract user from the token
        return Service.objects.filter(customer=user)
