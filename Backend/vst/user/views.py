from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.hashers import make_password, check_password
from .models import User
from .serializers import UserSerializer
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.decorators import api_view, permission_classes
import requests
from django.http import JsonResponse


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def protected_view(request):
    return Response({"message": "You have access to this protected API"}, status=200)

class SignupView(APIView):
    permission_classes = [AllowAny]
    
    def post(self, request):
        print(request.data)
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            # No need to hash the password manually; let the serializer handle it.
            serializer.save()
            return Response({"message": "Signup successful"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    permission_classes = [AllowAny]
    
    def post(self, request):
        phone = request.data.get('phone')
        password = request.data.get('password')
        fcm_token = request.data.get('FCM_Token')
        print(fcm_token)
        
        if not phone or not password:
            return Response({"message": "Phone and password are required"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user = User.objects.get(phone=phone)
            
            if check_password(password, user.password):  # Check if password matches the hashed one
                if fcm_token and (user.role == "worker" or user.role == "customer"):
                    user.fcm_token = fcm_token
                    user.save()
                    print("FCM Token updated")
                try:
                    payload = {
                            "token": user.FCM_Token,
                            "title": "Login Successful",
                            "body": "You have successfully logged in!"
                        }
                    response = requests.post("http://192.168.116.222:8000/firebase/send-notification/", json=payload)
                    data = response.json()
                    print(data)
                except Exception as e:
                    print(JsonResponse({"error": str(e)}))
                
                refresh = RefreshToken.for_user(user)
                access_token = str(refresh.access_token)
                serializer = UserSerializer(user)
                
                return Response({
                    "message": "Login successful",
                    "login": 1,
                    "access_token": access_token,
                    "refresh_token": str(refresh),
                    "data": serializer.data
                }, status=status.HTTP_200_OK)
            else:
                return Response({"message": "Invalid password", "login": 0}, status=status.HTTP_401_UNAUTHORIZED)
        
        except User.DoesNotExist:
            return Response({"message": "User not found", "login": 0}, status=status.HTTP_404_NOT_FOUND)

# Role-Based Access Views
class WorkerOnlyView(APIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        if request.user.role == "worker":
            return Response({"message": "Worker Access Granted!"})
        return Response({"message": "Unauthorized"}, status=status.HTTP_403_FORBIDDEN)

class AdminOnlyView(APIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        if request.user.role == "admin":
            return Response({"message": "Admin Access Granted!"})
        return Response({"message": "Unauthorized"}, status=status.HTTP_403_FORBIDDEN)

class HeadOnlyView(APIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        if request.user.role == "head":
            return Response({"message": "Head Access Granted!"})
        return Response({"message": "Unauthorized"}, status=status.HTTP_403_FORBIDDEN)
    

