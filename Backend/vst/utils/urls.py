from django.urls import path
from .views import (CheckAvailabilityView, UserUpdateView)

urlpatterns = [
    # User authentication endpoints
    path('checkstaffavailability/', CheckAvailabilityView.as_view(), name='checker'),
    path('updateuser/<int:id>/', UserUpdateView.as_view(), name='updateuser')

]
