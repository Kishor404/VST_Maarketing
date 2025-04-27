
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from user.models import User
from datetime import datetime

# ==========================================

# 1. Availability Checker
# 2. Find Next Service
# 3. Get Upcoming Service
# 4. Get Current Service
# 5. Get Completed Service
# 6. Get Count for Dashboard
# 7. Head Accept and Delete the EditReq
# 8. Head Reject EditReq
# 9. Head Reject UnavailableReq
# 10. Get User by ID
# 11. Reassign Staff
# 12. Get EditReq by Head
# 13. Get UnavailableReq by Head
# 14. Get All User by Head and Admin
# 15. Edit User by Head and Admin
# 16. Get Staff by ID
# 17. Get Warranty by ID
# 18. Get Service by Head

# ==========================================

# ====== 1. AVAILABLITY CHECKER =========

from datetime import datetime, timedelta
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import get_user_model

User = get_user_model()

class CheckAvailabilityView(APIView):
    
    def post(self, request):

        reqSender_region=request.user.region
        from_date_str = request.data.get("from_date")
        to_date_str = request.data.get("to_date")
        
        if not from_date_str or not to_date_str:
            return Response({"message": "Both from_date and to_date are required"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            from_date = datetime.strptime(from_date_str, "%Y-%m-%d").date()
            to_date = datetime.strptime(to_date_str, "%Y-%m-%d").date()
        except ValueError:
            return Response({"message": "Invalid date format. Use YYYY-MM-DD."}, status=status.HTTP_400_BAD_REQUEST)
        
        workers = User.objects.filter(role="worker",region=reqSender_region)
        
        for check_date in (from_date + timedelta(days=i) for i in range((to_date - from_date).days + 1)):
            available_workers = []
            
            for worker in workers:
                unavailables = worker.availability.get("unavailable", [])
                unavailables = {datetime.strptime(date, "%Y-%m-%d").date() for date in unavailables}
                
                if check_date not in unavailables:
                    available_workers.append(worker)
            
            if available_workers:
                selected_worker = min(
                    available_workers,
                    key=lambda w: datetime.strptime(w.last_service, "%Y-%m-%d").date() if w.last_service and w.last_service != "None" else datetime.min.date()
                )
                
                return Response({"worker_id": selected_worker.id, "available": check_date.strftime("%Y-%m-%d")}, status=status.HTTP_200_OK)
        
        return Response({"message": "No workers available during this period"}, status=status.HTTP_200_OK)


# ========== 2. FIND NEXT SERVICE =========

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

    
# ======== 3. GET UPCOMING SERVICE =============

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from service.models import Service
from service.serializers import ServiceSerializer

class UpcomingServiceView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user  
        current_date = now().date()


        services = Service.objects.filter(staff=user, status='BD', available_date__gt=current_date)
        
        serializer = ServiceSerializer(services, many=True)
        return Response(serializer.data, status=200)
    

# ======== 4. GET CURRENT SERVICE ===========

from django.utils.timezone import now  # Import the timezone-aware "now" function

class CurrentServiceView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user  
        current_date = now().date()

        services = Service.objects.filter(staff=user, status='BD', available_date=current_date)
        serializer = ServiceSerializer(services, many=True)
        return Response(serializer.data, status=200)

# ======== 5. GET COMPLETED SERVICE =============

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
    



# ============ 6. GET COUNT FOR DASHBOARD =========

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


# ================ 7. HEAD ACCEPT AND DELETE THE EDITREQ ===========


from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from editReq.models import EditReq
from user.models import User
from user.serializers import UserSerializer

class HeadEdit(APIView):
    
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):

        reqSender_region=request.user.region
        print(reqSender_region)
        editreq_id = kwargs.get('id')

        # Ensure only 'head' can access this API
        if request.user.role != 'head':
            return Response({"error": "Permission denied"}, status=status.HTTP_403_FORBIDDEN)

        # Get the EditReq object
        edit_req = get_object_or_404(EditReq, id=editreq_id)

        # Get the customer ID from the EditReq
        customer_id = edit_req.customer  

        # Get the user linked to that customer ID
        user = get_object_or_404(User, id=customer_id)
        print(edit_req.staff.region)
        # Update the user with the new customer data
        user_serializer = UserSerializer(user, data=edit_req.customerData, partial=True)

        if (user_serializer.is_valid() and edit_req.staff.region==reqSender_region):
            user_serializer.save()

            # Delete the EditReq entry after a successful update
            edit_req.delete()

            return Response({"message": "User updated successfully and EditReq deleted."}, status=status.HTTP_200_OK)
        
        return Response(user_serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ================ 8. HEAD REJECT EDITREQ ===========


from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from editReq.models import EditReq
from user.models import User
from user.serializers import UserSerializer

class RejectEditReq(APIView):
    
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):

        reqSender_region=request.user.region
        print(reqSender_region)
        editreq_id = kwargs.get('id')

        # Ensure only 'head' can access this API
        if request.user.role != 'head':
            return Response({"error": "Permission denied"}, status=status.HTTP_403_FORBIDDEN)

        # Get the EditReq object
        edit_req = get_object_or_404(EditReq, id=editreq_id)

        if (edit_req.staff.region==reqSender_region):
            edit_req.delete()

            return Response({"message": "User updated successfully and EditReq deleted."}, status=status.HTTP_200_OK)
        
        return Response("Rejected Successfully", status=status.HTTP_400_BAD_REQUEST)

# ================ 9. HEAD REJECT UNAVAILABLEREQ ===========


from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from unavailableReq.models import UnavailableReq
from user.models import User
from user.serializers import UserSerializer

class RejectUnavaReq(APIView):
    
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):

        reqSender_region=request.user.region
        print(reqSender_region)
        Unavailablereq_id = kwargs.get('id')

        # Ensure only 'head' can access this API
        if request.user.role != 'head':
            return Response({"error": "Permission denied"}, status=status.HTTP_403_FORBIDDEN)

        # Get the UnavailableReq object
        unava_req = get_object_or_404(UnavailableReq, id=Unavailablereq_id)

        if (unava_req.staff.region==reqSender_region):
            unava_req.delete()

            return Response({"message": "User updated successfully and UnavailableReq deleted."}, status=status.HTTP_200_OK)
        
        return Response("Rejected Successfully", status=status.HTTP_400_BAD_REQUEST)
    
# =========== 10. GET USER BY ID ==========

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


# =========== 11. REASSIGN STAFF ==========

import json
from datetime import datetime, timedelta
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404
from django.contrib.auth import get_user_model
from unavailableReq.models import UnavailableReq
from service.models import Service

User = get_user_model()

class AssignAvailableStaffView(APIView):
    def post(self, request, *args, **kwargs):
        # Fetch unavailable request by ID
        reqSender_region=request.user.region
        req_id = kwargs.get("id") or request.data.get("id")
        if not req_id:
            return Response({"message": "Request ID is required."}, status=status.HTTP_400_BAD_REQUEST)

        unavailable_req = get_object_or_404(UnavailableReq, id=req_id)
        service = unavailable_req.service
        current_staff = unavailable_req.staff

        # Debugging: Print the available data
        print("Raw available:", service.available, type(service.available))

        # Parse available from JSON format and normalize date format
        try:
            if isinstance(service.available, str):
                available = json.loads(service.available)  # Convert string to JSON
            else:
                available = service.available  # Already a dictionary

            # Ensure required keys exist
            if "from" not in available or "to" not in available:
                raise KeyError("Missing 'from' or 'to' in available.")

            # Normalize date format (replace '/' with '-')
            from_date_str = available["from"].replace("/", "-")
            to_date_str = available["to"].replace("/", "-")

            # Convert to date format
            from_date = datetime.strptime(from_date_str, "%Y-%m-%d").date()
            to_date = datetime.strptime(to_date_str, "%Y-%m-%d").date()
        except (KeyError, ValueError, json.JSONDecodeError) as e:
            print("Error parsing available:", str(e))  # Debugging
            return Response({"message": "Invalid available format.", "error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

        # Fetch workers excluding the current staff
        workers = User.objects.filter(role="worker", region=reqSender_region).exclude(id=current_staff.id)
        available_worker = None

        for check_date in (from_date + timedelta(days=i) for i in range((to_date - from_date).days + 1)):
            available_workers = []

            for worker in workers:
                try:
                    # Parse worker availability if stored as JSON string
                    worker_availability = json.loads(worker.availability) if isinstance(worker.availability, str) else worker.availability
                    unavailables = worker_availability.get("unavailable", [])
                    unavailables = {datetime.strptime(date, "%Y-%m-%d").date() for date in unavailables}
                except (json.JSONDecodeError, AttributeError, ValueError):
                    unavailables = set()  # Handle malformed availability data

                if check_date not in unavailables:
                    available_workers.append(worker)

            if available_workers:
                # Select the worker with the earliest last service date
                available_worker = min(
                    available_workers,
                    key=lambda w: datetime.strptime(w.last_service, "%Y-%m-%d").date() if w.last_service and w.last_service != "None" else datetime.min.date()
                )
                break

        if available_worker:
            # Assign new worker to the service
            service.staff = available_worker
            service.save()
            unavailable_req.delete()
            return Response({
                "message": "Staff reassigned successfully.",
                "worker_id": available_worker.id,
                "available": check_date.strftime("%Y-%m-%d")
            }, status=status.HTTP_200_OK)
        
        return Response({"message": "No available workers found."}, status=status.HTTP_200_OK)


# =========== 12. GET EDITREQ BY HEAD ===========

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from editReq.models import EditReq
from editReq.serializers import EditReqSerializer

class EditReqView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        """Fetch edit requests if the role is head"""
        role = request.user.role
        reqSender_region=request.user.region

        if role != "head":
            return Response({"detail": "Unauthorized"}, status=status.HTTP_403_FORBIDDEN)

        edit_requests = EditReq.objects.filter(staff__region=reqSender_region)
        serializer = EditReqSerializer(edit_requests, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
# =========== 13. GET UNAVAILABLEREQ BY HEAD ===========

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from unavailableReq.models import UnavailableReq
from unavailableReq.serializers import UnavailableReqSerializer

class UnavailableReqView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        """Fetch edit requests if the role is head"""
        role = request.user.role
        reqSender_region=request.user.region

        if role != "head":
            return Response({"detail": "Unauthorized"}, status=status.HTTP_403_FORBIDDEN)

        edit_requests = UnavailableReq.objects.filter(staff__region=reqSender_region)
        serializer = UnavailableReqSerializer(edit_requests, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

# =========== 14. GET ALL USER BY HEAD AND ADMIN ==========

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from user.models import User
from user.serializers import UserSerializer

class GetAllUsersByRoleAndRegion(APIView):
    """Fetch users by role and region with role-based access control"""
    
    permission_classes = [IsAuthenticated]  # Ensure only authenticated users can access

    def post(self, request):
        # Extract user role from the authenticated request
        user_role = request.user.role

        role=request.data.get("role")
        region=request.data.get("region")
        # Define allowed roles
        allowed_roles = ["head", "admin"]

        # Check if the role is authorized
        if user_role not in allowed_roles:
            return Response({"error": "Permission denied"}, status=status.HTTP_403_FORBIDDEN)

        # Fetch the requested users
        users = User.objects.filter(role=role, region=region)
        
        serializer = UserSerializer(users, many=True)

        return Response(serializer.data, status=status.HTTP_200_OK)

# =========== 15. EDIT USER BY HEAD AND ADMIN ==========

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from user.models import User
from user.serializers import UserSerializer

class EditUsersByHeadAndAdmin(APIView):
    """Fetch users by role and region with role-based access control"""
    
    permission_classes = [IsAuthenticated]  # Ensure only authenticated users can access

    def post(self, request):
        # Extract user role from the authenticated request
        user_role = request.user.role
        user_region = request.user.region

        allowed_roles = ["head", "admin"]

        # Check if the role is authorized
        if user_role not in allowed_roles:
            return Response({"error": "Permission denied"}, status=status.HTTP_403_FORBIDDEN)

        customer_id = request.data.get('id')

        # Get the user linked to that customer ID
        user = get_object_or_404(User, id=customer_id)

        # Update the user with the new customer data
        user_serializer = UserSerializer(user, data=request.data, partial=True)

        if (user_serializer.is_valid() and user_region==user.region):
            user_serializer.save()

            return Response({"message": "User updated successfully and EditReq deleted."}, status=status.HTTP_200_OK)
        
        return Response(user_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# =========== 16. GET STAFF BY ID ==========

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from user.models import User
from user.serializers import UserSerializer

class GetStaffByID(APIView):
    """Fetch user by ID with role-based access control"""
    
    permission_classes = [IsAuthenticated]  # Ensure only authenticated users can access

    def get(self, request, *args, **kwargs):
        user_id = kwargs.get('id')
        print(user_id)
        # Extract user role from the authenticated request
        user_role = request.user.role  # Assuming `request.user` is linked to `User` model
        print(user_role)

        # Define allowed roles
        allowed_roles = ["head", "admin"]

        # Check if the role is authorized
        if user_role not in allowed_roles:
            return Response({"error": "Permission denied"}, status=status.HTTP_403_FORBIDDEN)

        # Fetch the requested user
        user = get_object_or_404(User, id=user_id)
        if user.role in allowed_roles:
            return Response({"error": "Permission denied"}, status=status.HTTP_403_FORBIDDEN)
        
        serializer = UserSerializer(user)

        return Response(serializer.data, status=status.HTTP_200_OK)


# =========== 17. GET WARRENTY BY ID ==========


from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from card.models import Card
from datetime import date

class GetWarrentyByID(APIView):
    """Fetch warranty details by Card ID with role-based access control"""

    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        user_role = request.user.role
        card_id = kwargs.get('id')
        print(card_id)
        print(user_role)

        card = get_object_or_404(Card, id=card_id)
        
        warranty_start_date = card.warranty_start_date
        warranty_end_date = card.warranty_end_date
        today = date.today()
        is_warranty = today <= warranty_end_date

        warranty_end_in = (warranty_end_date - today).days if is_warranty else 0

        data = {
            'warranty_start_date': warranty_start_date,
            'warranty_end_date': warranty_end_date,
            'is_warranty': is_warranty,
            'warranty_end_in': warranty_end_in,
        }

        return Response(data, status=status.HTTP_200_OK)


#============= 18. GET ALL SERVICE BY HEAD ==========

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from service.models import Service
from service.serializers import ServiceSerializer

class GetServiceByHead(APIView):
    """Fetch all services by role and region with role-based access control"""
    permission_classes = [IsAuthenticated]
    def get(self, request, *args, **kwargs):
        user_role = request.user.role
        user_region = request.user.region

        allowed_roles = ["head"]

        if user_role not in allowed_roles:
            return Response({"error": "Permission denied"}, status=status.HTTP_403_FORBIDDEN)

        services = Service.objects.filter(customer__region=user_region)
        
        serializer = ServiceSerializer(services, many=True)

        return Response(serializer.data, status=status.HTTP_200_OK)
    
