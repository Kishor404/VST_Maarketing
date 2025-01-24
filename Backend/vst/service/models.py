from django.db import models

class Service(models.Model):
    REGION_CHOICES = [
        ('IND', 'India'),
        ('USA', 'United States'),
        ('AUS', 'Australia'),
    ]

    STATUS_CHOICES = [
        ('BD', 'Booked'),
        ('SP', 'Service Period'),
        ('SD', 'Serviced'),
        ('NS', 'Not Serviced'),
        ('CC', 'Service Cancelled By Customer'),
        ('CW', 'Service Cancelled By Worker'),
    ]

    customer_id = models.CharField(max_length=255, blank=False, null=False)
    worker_id = models.CharField(max_length=255)

    region = models.CharField(max_length=10, choices=REGION_CHOICES, blank=False, null=False)

    status = models.CharField(max_length=10, choices=STATUS_CHOICES, blank=False, null=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} {self.city}"