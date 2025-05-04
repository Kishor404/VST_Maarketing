from django.db import models
from user.models import User  # Import User model from the user app
from card.models import Card
from django.core.exceptions import ValidationError
from datetime import datetime, timedelta

class Service(models.Model):

    STATUS_CHOICES = [
        ('BD', 'Booked'),
        ('SD', 'Serviced'),
        ('NS', 'Not Serviced'),
        ('CC', 'Service Cancelled By Customer'),
        ('CW', 'Service Cancelled By Worker'),
    ]

    customer = models.ForeignKey(User, on_delete=models.CASCADE, related_name="services")
    staff = models.ForeignKey(User, on_delete=models.CASCADE, related_name="servicesstaff", null=True, blank=True)
    card = models.ForeignKey(Card, on_delete=models.CASCADE, related_name="card")

    on_warrenty = models.BooleanField(default=False)
    on_ACM = models.BooleanField(default=False)
    on_contract = models.BooleanField(default=False)

    rating = models.CharField(max_length=255, default="1")
    feedback = models.CharField(max_length=255, blank=True, null=True)

    staff_name = models.CharField(max_length=255, blank=True, null=True)
    customer_data = models.JSONField(blank=False, null=False)

    region = models.CharField(max_length=50, blank=False, null=False)

    complaint = models.CharField(max_length=255, blank=False, null=False)
    description = models.CharField(max_length=255, blank=True, null=True)

    available = models.JSONField(blank=False, null=False)
    available_date = models.CharField(max_length=255, blank=False, null=False)
    date_of_service = models.CharField(max_length=255, blank=False, null=False, default='Service Not Done Yet')

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
        if self.staff:
            self.staff_name=self.staff.name
        
        if self.card and self.customer:
            if self.card.customer_code.id != self.customer.id:  # Assuming customer_code stores the customer's ID
                raise ValidationError("The customer associated with this service must match the customer_code in the card.")
        
        if self.card and self.customer:
            if self.card.customer_code.id != self.customer.id:  # Assuming customer_code stores the customer's ID
                raise ValidationError("The customer associated with this service must match the customer_code in the card.")

            # Check if service is within the card's warranty period (extended by 10 days)
            try:
                warranty_start = datetime.strptime(str(self.card.warranty_start_date), "%Y-%m-%d")
                warranty_end = datetime.strptime(str(self.card.warranty_end_date), "%Y-%m-%d") + timedelta(days=10)
                service_date = datetime.strptime(self.available_date, "%Y-%m-%d")

                if warranty_start <= service_date <= warranty_end:
                    self.on_warrenty = True
                else:
                    self.on_warrenty = False
            except ValueError:
                raise ValidationError("Invalid date format for warranty or service date. Use YYYY-MM-DD.")


        super().save(*args, **kwargs)

    def __str__(self):
        return f"Service {self.id} for {self.customer.name}"
