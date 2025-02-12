from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import EditReqViewSet

# Create a router and register the viewset
router = DefaultRouter()
router.register(r'', EditReqViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
