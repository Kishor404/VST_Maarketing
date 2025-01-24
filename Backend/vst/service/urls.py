from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ServiceViewSet

# Create a router and register the viewsets
router = DefaultRouter()
router.register(r'', ServiceViewSet, basename='serviceentry')

# Include the router URLs
urlpatterns = [
    path('', include(router.urls)),
]
