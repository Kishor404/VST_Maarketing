from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ServiceViewSet, CancelServiceByCustomer, IsWarrantyService

# Create a router and register the viewsets for ServiceViewSet
router = DefaultRouter()
router.register(r'', ServiceViewSet, basename='serviceentry')

urlpatterns = [
    path('', include(router.urls)),
    path('cancleservicebycustomer/<int:id>', CancelServiceByCustomer.as_view(), name='cancel-service-by-user'),
    path('/is-warranty/<int:id>', IsWarrantyService.as_view(), name='is-warranty'),
]
