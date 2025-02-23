from django.db import models
from user.models import User 


class EditReq(models.Model):

    staff = models.ForeignKey(User, on_delete=models.CASCADE, related_name="staff")
    customer=models.CharField(max_length=255)
    staff_name=models.CharField(max_length=255, blank=True)
    customerData = models.JSONField(blank=False)

    def save(self, *args, **kwargs):
        if self.staff:
            self.staff_name = self.staff.name

        super().save(*args, **kwargs)

    def __str__(self):
        return f"Edit Request {self.id}"
