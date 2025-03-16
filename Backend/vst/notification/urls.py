from django.urls import path
from .views import send_notification

urlpatterns = [
    path("send-notification/", send_notification, name="send_notification"),
]
