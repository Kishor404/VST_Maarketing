from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CustomerViewSet

# Create a router and register the viewsets
router = DefaultRouter()
router.register(r'customers', CustomerViewSet, basename='Customer')

# Include the router URLs
urlpatterns = [
    path('', include(router.urls)),
]
