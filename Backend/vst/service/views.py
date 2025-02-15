from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import Service
from .serializers import ServiceSerializer
from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404


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



class CancelServiceByCustomer(APIView):
    
    def patch(self, request, *args, **kwargs):
        service_id = kwargs.get('id')
        user = request.user  # Get the user from the access token
        
        # Fetch the service instance
        service = get_object_or_404(Service, id=service_id)
        
        # Check if the service's customer is the logged-in user
        if service.customer != user:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)
        
        # Update the status
        service.status = 'CC'
        service.save()
        
        return Response({'message': 'Service status updated successfully'}, status=status.HTTP_200_OK)
