from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.hashers import make_password, check_password
from .models import Customer,Head,Admin,Worker
from .serializers import CustomerSerializer,HeadSerializer,AdminSerializer,WorkerSerializer

class SignupView(APIView):
    def post(self, request):
        # Use the CustomerSerializer to handle data validation and saving
        serializer = CustomerSerializer(data=request.data)
        if serializer.is_valid():
            # Hash the password before saving
            serializer.save(password=make_password(serializer.validated_data['password']))
            return Response({"message": "Signup successful"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    def post(self, request):
        # Get phone and password from the request
        phone = request.data.get('phone')
        password = request.data.get('password')

        if not phone or not password:
            return Response({"error": "Phone and password are required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Retrieve the customer by phone
            customer = Customer.objects.get(phone=phone)
            
            # Check if the provided password matches the stored hashed password
            if check_password(password, customer.password):
                return Response({"message": "Login successful","login":1}, status=status.HTTP_200_OK)
            else:
                return Response({"error": "Invalid password","login":0}, status=status.HTTP_401_UNAUTHORIZED)
        
        except Customer.DoesNotExist:
            return Response({"error": "Customer not found","login":0}, status=status.HTTP_404_NOT_FOUND)

class HeadSignupView(APIView):
    def post(self, request):
        # Use the HeadSerializer to handle data validation and saving
        serializer = HeadSerializer(data=request.data)
        if serializer.is_valid():
            # Hash the password before saving
            serializer.save(password=make_password(serializer.validated_data['password']))
            return Response({"message": "Signup successful"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class HeadLoginView(APIView):
    def post(self, request):
        # Get phone and password from the request
        phone = request.data.get('phone')
        password = request.data.get('password')

        if not phone or not password:
            return Response({"error": "Phone and password are required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Retrieve the Head by phone
            head = Head.objects.get(phone=phone)
            
            # Check if the provided password matches the stored hashed password
            if check_password(password, head.password):
                return Response({"message": "Login successful","login":1}, status=status.HTTP_200_OK)
            else:
                return Response({"error": "Invalid password","login":0}, status=status.HTTP_401_UNAUTHORIZED)
        
        except Head.DoesNotExist:
            return Response({"error": "Head not found","login":0}, status=status.HTTP_404_NOT_FOUND)

class WorkerSignupView(APIView):
    def post(self, request):
        # Use the WorkerSerializer to handle data validation and saving
        serializer = WorkerSerializer(data=request.data)
        if serializer.is_valid():
            # Hash the password before saving
            serializer.save(password=make_password(serializer.validated_data['password']))
            return Response({"message": "Signup successful"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class WorkerLoginView(APIView):
    def post(self, request):
        # Get phone and password from the request
        phone = request.data.get('phone')
        password = request.data.get('password')

        if not phone or not password:
            return Response({"error": "Phone and password are required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Retrieve the Worker by phone
            worker = Worker.objects.get(phone=phone)
            
            # Check if the provided password matches the stored hashed password
            if check_password(password, worker.password):
                return Response({"message": "Login successful","login":1}, status=status.HTTP_200_OK)
            else:
                return Response({"error": "Invalid password","login":0}, status=status.HTTP_401_UNAUTHORIZED)
        
        except Worker.DoesNotExist:
            return Response({"error": "Worker not found","login":0}, status=status.HTTP_404_NOT_FOUND)

class AdminSignupView(APIView):
    def post(self, request):
        # Use the AdminSerializer to handle data validation and saving
        serializer = AdminSerializer(data=request.data)
        if serializer.is_valid():
            # Hash the password before saving
            serializer.save(password=make_password(serializer.validated_data['password']))
            return Response({"message": "Signup successful"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class AdminLoginView(APIView):
    def post(self, request):
        # Get phone and password from the request
        phone = request.data.get('phone')
        password = request.data.get('password')

        if not phone or not password:
            return Response({"error": "Phone and password are required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Retrieve the Admin by phone
            admin = Admin.objects.get(phone=phone)
            
            # Check if the provided password matches the stored hashed password
            if check_password(password, admin.password):
                return Response({"message": "Login successful","login":1}, status=status.HTTP_200_OK)
            else:
                return Response({"error": "Invalid password","login":0}, status=status.HTTP_401_UNAUTHORIZED)
        
        except Admin.DoesNotExist:
            return Response({"error": "Admin not found","login":0}, status=status.HTTP_404_NOT_FOUND)
