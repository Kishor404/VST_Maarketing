from django.urls import path
from .views import SignupView, LoginView, HeadLoginView, HeadSignupView, AdminLoginView, AdminSignupView, WorkerLoginView, WorkerSignupView

urlpatterns = [
    path('customers/signup/', SignupView.as_view(), name='signup'),
    path('customers/login/', LoginView.as_view(), name='login'),
    path('Heads/signup/', HeadSignupView.as_view(), name='headsignup'),
    path('Heads/login/', HeadLoginView.as_view(), name='headlogin'),
    path('Admins/signup/', AdminSignupView.as_view(), name='adminsignup'),
    path('Admins/login/', AdminLoginView.as_view(), name='adminlogin'),
    path('Workers/signup/', WorkerSignupView.as_view(), name='workersignup'),
    path('Workers/login/', WorkerLoginView.as_view(), name='workerlogin'),
]
