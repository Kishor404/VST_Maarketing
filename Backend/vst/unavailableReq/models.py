from django.db import models
from user.models import User 
from service.models import Service 


class UnavailableReq(models.Model):

    staff = models.ForeignKey(User, on_delete=models.CASCADE, related_name="unavailable_requests")
    staff_name = models.CharField(max_length=255, blank=True)
    service = models.ForeignKey(Service, on_delete=models.CASCADE, related_name="unavailable_services")

    def save(self, *args, **kwargs):
        if self.staff:
            self.staff_name = self.staff.name

        super().save(*args, **kwargs)

    def __str__(self):
        return f"Unavailable Request {self.id}"
