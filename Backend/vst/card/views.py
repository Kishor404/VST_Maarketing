from rest_framework import viewsets
from .models import Card, ServiceEntry
from .serializers import CardSerializer, ServiceEntrySerializer
from rest_framework.response import Response
from rest_framework import status
from rest_framework.viewsets import ReadOnlyModelViewSet

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

class CardListView(ReadOnlyModelViewSet):

    serializer_class = CardSerializer
    queryset = Card.objects.all()  # Default queryset
    
    def get_queryset(self):
        user = self.request.user
        allowed_roles = {"customer", "worker", "head", "admin"}
        print("ID "+user.role)

        if user.role not in allowed_roles:
            return Card.objects.none()  # Return empty queryset if unauthorized
        return Card.objects.filter(customer_code=user.id)