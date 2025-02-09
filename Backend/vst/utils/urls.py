from django.urls import path
from .views import (CheckAvailabilityView, UserUpdateView, NextServiceView)

urlpatterns = [
    # User authentication endpoints
    path('checkstaffavailability/', CheckAvailabilityView.as_view(), name='checker'),
    path('updateuser/<int:id>/', UserUpdateView.as_view(), name='updateuser'),
    path('next-service/', NextServiceView.as_view(), name='next-service-info'),
]
