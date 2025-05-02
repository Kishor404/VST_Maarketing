from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    SignupView, LoginView, 
    WorkerOnlyView, AdminOnlyView, HeadOnlyView,
    protected_view,
    ChangePasswordView
)

urlpatterns = [
    # User authentication endpoints
    path('signup/', SignupView.as_view(), name='signup'),
    path('login/', LoginView.as_view(), name='login'),

    # Role-Based Protected Views
    path('workers/protected/', WorkerOnlyView.as_view(), name='worker-protected'),
    path('admins/protected/', AdminOnlyView.as_view(), name='admin-protected'),
    path('heads/protected/', HeadOnlyView.as_view(), name='head-protected'),

    # JWT Token Refresh
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # General protected view for authenticated users
    path('protected/', protected_view, name='protected-view'),

    path('change-password/', ChangePasswordView.as_view(), name='change-password'),
]
