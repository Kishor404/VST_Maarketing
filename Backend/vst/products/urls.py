from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ProductViewSet

# Create a router and register the viewsets
router = DefaultRouter()
router.register(r'', ProductViewSet, basename='productentry')

# Include the router URLs
urlpatterns = [
    path('', include(router.urls)),
]
