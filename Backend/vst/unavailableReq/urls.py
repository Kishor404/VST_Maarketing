from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UnavailableReqViewSet

# Create a router and register the viewset
router = DefaultRouter()
router.register(r'', UnavailableReqViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
