from rest_framework import viewsets
from .models import EditReq
from .serializers import EditReqSerializer


class EditReqViewSet(viewsets.ModelViewSet):

    """
    ViewSet for managing EditReq objects.
    """
    queryset = EditReq.objects.all()
    serializer_class = EditReqSerializer

