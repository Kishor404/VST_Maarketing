from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import Service
from .serializers import ServiceSerializer
from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
import requests



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
        Override perform_create to modify staff user after creating a service and send a notification.
        """
        service = serializer.save()  # Save the service instance
        # staff = service.staff  # Get assigned staff
        # available_date = service.available_date  # Extract available date
        user = self.request.user  # Get authenticated user

        # Update staff availability
        # if staff and available_date:
        #     try:
        #         # Ensure availability is a dictionary
        #         if not staff.availability:
        #             staff.availability = {"unavailable": []}
        #         else:
        #             if isinstance(staff.availability, str):
        #                 staff.availability = json.loads(staff.availability)

        #         # Append new date
        #         staff.availability["unavailable"].append(available_date)
        #         staff.save()
        #     except Exception as e:
        #         print(f"Error updating staff availability: {e}")

        # Send notification about service creation
        if user.FCM_Token:
            payload = {
                "token": user.FCM_Token,
                "title": "Service Created",
                "body": f"Your service (ID: {service.id}) has been successfully created."
            }
            try:
                response = requests.post("http://157.173.220.208/firebase/send-notification/", json=payload)
                response.raise_for_status()
                print("Notification sent successfully:", response.json())
            except requests.exceptions.RequestException as e:
                print(f"Error sending notification: {e}")

        # if staff and staff.FCM_Token:
        #     staff_payload = {
        #         "token": staff.FCM_Token,
        #         "title": "New Service Assigned",
        #         "body": f"A new service (ID: {service.id}) has been assigned to you."
        #     }
        #     try:
        #         response = requests.post("http://157.173.220.208/firebase/send-notification/", json=staff_payload)
        #         response.raise_for_status()
        #         print("Staff notification sent successfully:", response.json())
        #     except requests.exceptions.RequestException as e:
        #         print(f"Error sending staff notification: {e}")

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
        
        # Send notification about service cancellation
        if user.FCM_Token:
            payload = {
                "token": user.FCM_Token,
                "title": "Service Cancelled",
                "body": f"Your service (ID: {service.id}) has been cancelled successfully."
            }
            try:
                response = requests.post("http://157.173.220.208/firebase/send-notification/", json=payload)
                response.raise_for_status()
                print("Notification sent successfully:", response.json())
            except requests.exceptions.RequestException as e:
                print(f"Error sending notification: {e}")

        return Response({'message': 'Service status updated successfully'}, status=status.HTTP_200_OK)


from dateutil.relativedelta import relativedelta
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404
from .models import Service


class IsWarrantyService(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        # Get the current service
        service = get_object_or_404(Service, id=id)
        card = service.card
        if not card.warranty_start_date or not card.warranty_end_date:
            return Response({'isWarranty': False, 'reason': 'No warranty dates available'}, status=status.HTTP_200_OK)

        warranty_start = card.warranty_start_date
        warranty_end = card.warranty_end_date

        # Generate all warranty milestone dates (every 4 months from start to end)
        warranty_dates = []
        current_date = warranty_start
        while current_date <= warranty_end:
            warranty_dates.append(current_date)
            current_date += relativedelta(months=4)

        # Count how many warranty services have already been done for this card
        completed_services = Service.objects.filter(card=card, status="SD").order_by('date')
        completed_warranty_services = 0
        used_dates = []

        for done_service in completed_services:
            for warranty_date in warranty_dates:
                if abs((done_service.date - warranty_date).days) <= 15 and warranty_date not in used_dates:
                    completed_warranty_services += 1
                    used_dates.append(warranty_date)
                    break

        # Check if the current service falls within any remaining warranty slot
        for warranty_date in warranty_dates:
            if abs((service.date - warranty_date).days) <= 15 and warranty_date not in used_dates:
                return Response({'isWarranty': True}, status=status.HTTP_200_OK)

        return Response({'isWarranty': False}, status=status.HTTP_200_OK)
