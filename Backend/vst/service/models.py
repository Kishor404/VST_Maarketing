from django.db import models
from user.models import User  # Import User model from the user app

class Service(models.Model):
    COMPLAINT_CHOICES = [
        ('GS', 'General Service'),
        ('WL', 'Water Leakage'),
        ('WTB', 'Water Taste Bad'),
    ]

    STATUS_CHOICES = [
        ('BD', 'Booked'),
        ('SP', 'Service Period'),
        ('SD', 'Serviced'),
        ('NS', 'Not Serviced'),
        ('CC', 'Service Cancelled By Customer'),
        ('CW', 'Service Cancelled By Worker'),
    ]

    customer = models.ForeignKey(User, on_delete=models.CASCADE, related_name="services")
    worker_id = models.CharField(max_length=255, blank=True)

    region = models.CharField(max_length=50, blank=False, null=False)  # Removed choices

    available = models.JSONField(blank=False, null=False)

    customer_data = models.JSONField(blank=False, null=False)

    complaint = models.CharField(max_length=255, choices=COMPLAINT_CHOICES, blank=False, null=False, default='GS')

    status = models.CharField(max_length=10, choices=STATUS_CHOICES, blank=False, null=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def save(self, *args, **kwargs):
        """ Automatically set region based on customer's region and store customer data """
        if self.customer:
            self.region = self.customer.region  # Get region from customer
            # Store customer data as a dictionary in the customer_data field
            self.customer_data = {
                'name': self.customer.name,
                'phone': self.customer.phone,
                'email': self.customer.email,
                'region': self.customer.region,
                'address': self.customer.address,
                'city': self.customer.city,
                'district': self.customer.district,
                'postal_code': self.customer.postal_code,
            }

        super().save(*args, **kwargs)

    def __str__(self):
        return f"Service {self.id} for {self.customer.name}"
