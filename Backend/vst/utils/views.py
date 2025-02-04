
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from user.models import User
from datetime import datetime


# ====== AVAILABLITY CHECKER =========

class CheckAvailabilityView(APIView):
    
    def post(self, request):
        from_date = request.data.get("from_date")
        to_date = request.data.get("to_date")
        
        if not from_date or not to_date:
            return Response({"message": "Both from_date and to_date are required"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            from_date = datetime.strptime(from_date, "%Y-%m-%d").date()
            to_date = datetime.strptime(to_date, "%Y-%m-%d").date()
        except ValueError:
            return Response({"message": "Invalid date format. Use YYYY-MM-DD."}, status=status.HTTP_400_BAD_REQUEST)
        
        # Get all workers
        workers = User.objects.filter(role="worker")
        available_workers = []
        
        for worker in workers:
            unavailable_dates = worker.availability.get("unavailable", [])
            if not any(from_date <= datetime.strptime(date, "%Y-%m-%d").date() <= to_date for date in unavailable_dates):
                available_workers.append(worker)
        
        if not available_workers:
            return Response({"message": "No workers available during this period"}, status=status.HTTP_404_NOT_FOUND)
        
        # Find the worker with the earliest last service date
        selected_worker = min(available_workers, key=lambda w: datetime.strptime(w.last_service, "%Y-%m-%d").date() if w.last_service and w.last_service != "None" else datetime.min.date())
        
        return Response({"worker_id": selected_worker.id}, status=status.HTTP_200_OK)

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
