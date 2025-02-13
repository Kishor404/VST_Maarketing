
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from user.models import User
from datetime import datetime


# ====== AVAILABLITY CHECKER =========

from datetime import datetime, timedelta
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import get_user_model

User = get_user_model()

class CheckAvailabilityView(APIView):
    
    def post(self, request):
        from_date_str = request.data.get("from_date")
        to_date_str = request.data.get("to_date")
        
        if not from_date_str or not to_date_str:
            return Response({"message": "Both from_date and to_date are required"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            from_date = datetime.strptime(from_date_str, "%Y-%m-%d").date()
            to_date = datetime.strptime(to_date_str, "%Y-%m-%d").date()
        except ValueError:
            return Response({"message": "Invalid date format. Use YYYY-MM-DD."}, status=status.HTTP_400_BAD_REQUEST)
        
        workers = User.objects.filter(role="worker")
        
        for check_date in (from_date + timedelta(days=i) for i in range((to_date - from_date).days + 1)):
            available_workers = []
            
            for worker in workers:
                unavailable_dates = worker.availability.get("unavailable", [])
                unavailable_dates = {datetime.strptime(date, "%Y-%m-%d").date() for date in unavailable_dates}
                
                if check_date not in unavailable_dates:
                    available_workers.append(worker)
            
            if available_workers:
                selected_worker = min(
                    available_workers,
                    key=lambda w: datetime.strptime(w.last_service, "%Y-%m-%d").date() if w.last_service and w.last_service != "None" else datetime.min.date()
                )
                
                return Response({"worker_id": selected_worker.id, "available_date": check_date.strftime("%Y-%m-%d")}, status=status.HTTP_200_OK)
        
        return Response({"message": "No workers available during this period"}, status=status.HTTP_200_OK)

# ========== UPDATE USER ===============

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from user.models import User
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import PermissionDenied
from user.serializers import UserSerializer

class UserUpdateView(APIView):
    """
    View to handle the partial update of a user profile by id.
    Only allows updating fields if the user has the 'worker' role.
    """
    permission_classes = [IsAuthenticated]  # Ensure the user is authenticated

    def patch(self, request, *args, **kwargs):
        # Get the user id from the URL (e.g., /user/update/{id}/)
        user_id = kwargs.get('id')

        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({"detail": "User not found."}, status=status.HTTP_404_NOT_FOUND)

        # Check if the authenticated user is trying to update their own profile or is an admin/head
        if user != request.user and not (request.user.role == 'head' or request.user.role == 'admin'):
            raise PermissionDenied("You are not allowed to update this profile.")

        # Validate and update user fields using the serializer
        serializer = UserSerializer(user, data=request.data, partial=True)

        if serializer.is_valid():
            serializer.save()  # Update the user with the validated data
            return Response(serializer.data, status=status.HTTP_200_OK)
        
        # If the serializer isn't valid, return the error response
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# ========== FIND NEXT SERVICE =========

from datetime import date
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from card.models import Card, ServiceEntry
from rest_framework import status

class NextServiceView(APIView):
    """
    Get the card with the nearest upcoming service date for the authenticated user.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user  # Get logged-in user from access token
        
        # Get all cards associated with the user
        cards = Card.objects.filter(customer_code=user)

        if not cards.exists():
            return Response({"error": "No cards found for this user"}, status=status.HTTP_404_NOT_FOUND)

        today = date.today()
        nearest_card = None
        min_days_remaining = float('inf')

        for card in cards:
            # Get the latest service entry for each card
            latest_service = ServiceEntry.objects.filter(card=card).order_by('-date').first()

            if latest_service and latest_service.next_service:
                next_service_date = latest_service.next_service
                days_remaining = (next_service_date - today).days

                # Check if this card has the least days remaining
                if days_remaining < min_days_remaining:
                    min_days_remaining = days_remaining
                    nearest_card = {
                        "card_id": card.id,
                        "next_service_date": next_service_date.strftime("%Y-%m-%d"),
                        "days_remaining": days_remaining
                    }

        if nearest_card:
            return Response(nearest_card, status=status.HTTP_200_OK)
        else:
            return Response({"error": "No valid service entry found"}, status=status.HTTP_404_NOT_FOUND)

    
# ======== GET UPCOMING SERVICE =============

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from service.models import Service
from service.serializers import ServiceSerializer

class UpcomingServiceView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        
        user = request.user  
        
        services = Service.objects.filter(staff=user, status='BD')
        
        serializer = ServiceSerializer(services, many=True)
        return Response(serializer.data, status=200)
    

# ======== GET CURRENT SERVICE ===========

from django.utils.timezone import now  # Import the timezone-aware "now" function

class CurrentServiceView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user  
        current_date = now().date()

        services = Service.objects.filter(staff=user, status='BD', available_date=current_date)
        
        serializer = ServiceSerializer(services, many=True)
        return Response(serializer.data, status=200)

# ======== GET COMPLETED SERVICE =============

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from service.models import Service
from service.serializers import ServiceSerializer

class CompletedServiceView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        
        user = request.user  
        
        services = Service.objects.filter(staff=user, status='SD')
        
        serializer = ServiceSerializer(services, many=True)
        return Response(serializer.data, status=200)
    

# =========== GET USET BY ID ==========

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from user.models import User
from user.serializers import UserSerializer

class GetUserByID(APIView):
    """Fetch user by ID with role-based access control"""
    
    permission_classes = [IsAuthenticated]  # Ensure only authenticated users can access

    def get(self, request, *args, **kwargs):
        user_id = kwargs.get('id')
        print(user_id)
        # Extract user role from the authenticated request
        user_role = request.user.role  # Assuming `request.user` is linked to `User` model
        print(user_role)

        # Define allowed roles
        allowed_roles = ["worker", "head", "admin"]

        # Check if the role is authorized
        if user_role not in allowed_roles:
            return Response({"error": "Permission denied"}, status=status.HTTP_403_FORBIDDEN)

        # Fetch the requested user
        user = get_object_or_404(User, id=user_id)
        if user.role in allowed_roles:
            return Response({"error": "Permission denied"}, status=status.HTTP_403_FORBIDDEN)
        
        serializer = UserSerializer(user)

        return Response(serializer.data, status=status.HTTP_200_OK)


# ============ GET COUNT FOR DASHBOARD =========

# views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.exceptions import PermissionDenied
from user.models import User

class RoleCountView(APIView):

    def get(self, request, *args, **kwargs):
        # Check if the user has the 'admin' role in the access token
        if request.user.role != 'admin':  # Adjust based on your actual role attribute
            raise PermissionDenied("You do not have permission to access this resource.")
        
        # Get the counts of users with specific roles
        user_count = User.objects.filter(role='user').count()  # Adjust based on your model's role field
        staff_count = User.objects.filter(role='worker').count()  # Adjust based on your model's role field
        customer_count = User.objects.filter(role='customer').count()  # Adjust based on your model's role field
        head_count = User.objects.filter(role='head').count()  # Adjust based on your model's role field

        return Response({
            'user_count': user_count,
            'staff_count': staff_count,
            'customer_count': customer_count,
            'head_count': head_count
        })
