from rest_framework import viewsets
from .models import Card, ServiceEntry
from .serializers import CardSerializer, ServiceEntrySerializer
from rest_framework.response import Response
from rest_framework import status
from rest_framework.viewsets import ReadOnlyModelViewSet
from rest_framework import generics
from rest_framework.exceptions import PermissionDenied
from service.models import Service
import requests
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated

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

        if user.role not in allowed_roles:
            return Card.objects.none()  # Return empty queryset if unauthorized
        return Card.objects.filter(customer_code=user.id)
    

class CardCreateByHead(generics.CreateAPIView):
    queryset = Card.objects.all()
    serializer_class = CardSerializer

    def create(self, request, *args, **kwargs):
        user_role = request.user.role if hasattr(request.user, 'role') else None
        if user_role != 'head':
            raise PermissionDenied("You are not authorized to perform this action.")

        return super().create(request, *args, **kwargs)
    
class CardUpdateByHead(generics.UpdateAPIView):
    queryset = Card.objects.all()
    serializer_class = CardSerializer
    lookup_field = 'id'

    def patch(self, request, *args, **kwargs):
        card_id = kwargs.get('id')
        user_role = request.user.role if hasattr(request.user, 'role') else None

        if user_role != 'head':
            raise PermissionDenied("You are not authorized to perform this action.")

        try:
            card = Card.objects.get(id=card_id)
        except Card.DoesNotExist:
            raise PermissionDenied("Card not found.")

        return super().patch(request, *args, **kwargs)


class CardListByHead(generics.ListAPIView):
    serializer_class = CardSerializer

    def get_queryset(self):
        user = self.request.user
        user_role = getattr(user, 'role', None)

        if user_role not in {"head", "worker"}:
            raise PermissionDenied("You are not authorized to perform this action.")

        # Assuming the user has a 'region' attribute
        user_region = getattr(user, 'region', None)
        if not user_region:
            return Card.objects.none()

        return Card.objects.filter(region=user_region)
    
class CardListByHeadByID(generics.RetrieveAPIView):
    queryset = Card.objects.all()
    serializer_class = CardSerializer
    lookup_field = 'id'

    def get(self, request, *args, **kwargs):
        card_id = kwargs.get('id')
        user_role = request.user.role if hasattr(request.user, 'role') else None

        if user_role not in {"head", "worker"}:
            raise PermissionDenied("You are not authorized to perform this action.")

        try:
            card = Card.objects.get(id=card_id)
        except Card.DoesNotExist:
            raise PermissionDenied("Card not found.")

        serializer = self.get_serializer(card)
        return Response(serializer.data)

class ServiceEntryCreateByHeadAndWorker(generics.CreateAPIView):
    
    queryset = ServiceEntry.objects.all()
    serializer_class = ServiceEntrySerializer

    def create(self, request, *args, **kwargs):
        user_role = request.user.role if hasattr(request.user, 'role') else None

        if user_role not in {"head", "worker"}:
            raise PermissionDenied("You are not authorized to perform this action.")

        return super().create(request, *args, **kwargs)
    
    def perform_create(self, serializer):
        """
        Override perform_create to send a notification to the customer after creating a ServiceEntry.
        """
        service_entry = serializer.save()  # Save the new ServiceEntry instance
        customer = service_entry.card.customer_code  # Get the customer associated with this service entr

        # Send notification to the customer
        if customer and customer.FCM_Token:
            payload = {
                "token": customer.FCM_Token,
                "title": "Service Entry",
                "body": f"A new service entry (ID: {service_entry.id}) has been added to your service."
            }
            try:
                response = requests.post("http://157.173.220.208/firebase/send-notification/", json=payload)
                response.raise_for_status()
                print(f"Notification sent to customer {customer}: {response.json()}")
            except requests.exceptions.RequestException as e:
                print(f"Error sending notification to customer {customer}: {e}")

        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
class ServiceEntryUpdateByHeadAndWorker(generics.UpdateAPIView):
    
    queryset = ServiceEntry.objects.all()
    serializer_class = ServiceEntrySerializer
    lookup_field = 'id'

    def patch(self, request, *args, **kwargs):
        user_role = request.user.role if hasattr(request.user, 'role') else None

        if user_role not in {"head", "worker"}:
            raise PermissionDenied("You are not authorized to perform this action.")

        return super().patch(request, *args, **kwargs)


class ServiceEntryCustomerSignatureUpdate(generics.UpdateAPIView):
    """
    API view for updating only the customer_signature field. 
    Only accessible by customers for their own service entries.
    """
    queryset = ServiceEntry.objects.all()
    serializer_class = ServiceEntrySerializer
    lookup_field = 'id'

    def patch(self, request, *args, **kwargs):
        user = request.user
        user_role = getattr(user, 'role', None)

        # Ensure only customers can access this endpoint
        if user_role != "customer":
            raise PermissionDenied("You are not authorized to update this field.")

        # Fetch the service entry
        try:
            service_entry = ServiceEntry.objects.get(id=kwargs["id"])
        except ServiceEntry.DoesNotExist:
            raise PermissionDenied("Service entry not found.")

        # Get the associated card
        card = service_entry.card  # Assuming ServiceEntry has a ForeignKey to Card

        # Verify that the requesting user is the owner (customer_code == user.id)
        if card.customer_code.id != user.id:  
            raise PermissionDenied("You are not authorized to update this service entry.")

        # Get the associated Service and update its status
        service_id = service_entry.service  # Assuming it's an ID, not an object
        if service_id:
            try:
                service = Service.objects.get(id=service_id)  # Fetch the actual service object
                service.status = "SD"
                service.feedback = request.data.get("feedback")
                service.rating = request.data.get("rating")
                service.save()
            except Service.DoesNotExist:
                raise PermissionDenied("Associated service not found.")


        # Create a modified data dictionary
        updated_data = {"customer_signature": request.data.get("customer_signature")}

        # Perform the partial update
        serializer = self.get_serializer(service_entry, data=updated_data, partial=True)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)

        return Response(serializer.data)

class ServiceEntryByServiceID(APIView):
    """
    Get all ServiceEntry instances related to a given Service ID.
    Only accessible by worker, head, or admin.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        user = request.user
        allowed_roles = {"worker", "head", "admin"}

        if getattr(user, 'role', None) not in allowed_roles:
            raise PermissionDenied("You are not authorized to access service entries.")

        service_id = kwargs.get("id")
        service_entries = ServiceEntry.objects.filter(service=service_id)
        serializer = ServiceEntrySerializer(service_entries, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)