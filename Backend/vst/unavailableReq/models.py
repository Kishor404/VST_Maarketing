from django.db import models
from user.models import User 
from service.models import Service 


class UnavailableReq(models.Model):

    staff = models.ForeignKey(User, on_delete=models.CASCADE, related_name="unavailable_requests")
    service = models.ForeignKey(Service, on_delete=models.CASCADE, related_name="unavailable_services")

    def __str__(self):
        return f"Unavailable Request {self.id}"
