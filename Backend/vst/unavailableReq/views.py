from rest_framework import viewsets
from .models import UnavailableReq
from .serializers import UnavailableReqSerializer


class UnavailableReqViewSet(viewsets.ModelViewSet):

    """
    ViewSet for managing UnavailableReq objects.
    """
    queryset = UnavailableReq.objects.all()
    serializer_class = UnavailableReqSerializer

