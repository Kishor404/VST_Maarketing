from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CardViewSet, ServiceEntryViewSet

# Create a router and register the viewsets
router = DefaultRouter()
router.register(r'cards', CardViewSet, basename='card')
router.register(r'service-entries', ServiceEntryViewSet, basename='serviceentry')

# Include the router URLs
urlpatterns = [
    path('', include(router.urls)),
]
