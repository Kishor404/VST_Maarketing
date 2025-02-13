from django.db import models
from user.models import User 


class EditReq(models.Model):

    staff = models.ForeignKey(User, on_delete=models.CASCADE, related_name="staff")
    customer=models.CharField(max_length=255)
    customerData = models.JSONField(blank=False)

    def __str__(self):
        return f"Edit Request {self.id}"
