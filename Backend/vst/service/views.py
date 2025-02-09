from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import Service
from .serializers import ServiceSerializer
from rest_framework.response import Response
from rest_framework import status

from user.models import User


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
    
    def perform_create(self, serializer):
        """
        Override perform_create to modify staff user after creating a service.
        """
        service = serializer.save()  # Save the service instance
        staff = service.staff  # Directly get the staff object
        available_date = service.available_date  # Extract available_date

        if staff and available_date:
            try:
                # Ensure availability is a dictionary with a key 'unavailable'
                if not staff.availability or not isinstance(staff.availability, dict):
                    staff.availability = {"unavailable": []}
                
                # Append new date to unavailable list
                staff.availability["unavailable"].append(available_date)

                staff.save()  # Save changes
            except Exception as e:
                print(f"Error updating staff availability: {e}")  # Debugging purpose

        return Response(serializer.data, status=status.HTTP_201_CREATED)
