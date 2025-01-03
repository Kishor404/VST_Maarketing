from rest_framework import viewsets
from .models import Card, ServiceEntry
from .serializers import CardSerializer, ServiceEntrySerializer


class CardViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing Card objects.
    """
    queryset = Card.objects.all()
    serializer_class = CardSerializer


class ServiceEntryViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing ServiceEntry objects.
    """
    queryset = ServiceEntry.objects.all()
    serializer_class = ServiceEntrySerializer
