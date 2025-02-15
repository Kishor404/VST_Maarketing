from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ServiceViewSet, CancelServiceByCustomer

# Create a router and register the viewsets for ServiceViewSet
router = DefaultRouter()
router.register(r'', ServiceViewSet, basename='serviceentry')

urlpatterns = [
    path('', include(router.urls)),
    path('cancleservicebycustomer/<int:id>', CancelServiceByCustomer.as_view(), name='cancel-service-by-user'),
]
