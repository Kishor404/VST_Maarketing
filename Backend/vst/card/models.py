from django.db import models
from user.models import User 

def signature_image_upload_path(instance, filename):
    # Upload to media/Signature/<service_id>.ext
    ext = filename.split('.')[-1]
    return f'Signature/{instance.id}.{ext}' if instance.id else f'Signature/temp.{ext}'

class Card(models.Model):

    model = models.CharField(max_length=100)
    customer_code = models.ForeignKey(User, on_delete=models.CASCADE, related_name="cards")
    customer_name = models.CharField(max_length=255)
    region = models.CharField(max_length=255)
    date_of_installation = models.DateField()
    address = models.TextField()
    warranty_start_date = models.DateField()
    warranty_end_date = models.DateField()
    acm_start_date = models.DateField(null=True, blank=True)
    acm_end_date = models.DateField(null=True, blank=True)
    contract_start_date = models.DateField(null=True, blank=True)
    contract_end_date = models.DateField(null=True, blank=True)

    def save(self, *args, **kwargs):
        """ Automatically set region based on customer's region and store customer data """
        if self.customer_code:
            self.customer_name = getattr(self.customer_code, 'name', 'Unknown')
            self.region = getattr(self.customer_code, 'region', 'Unknown')
            
            address_parts = [
                getattr(self.customer_code, 'address', ''),
                getattr(self.customer_code, 'city', ''),
                getattr(self.customer_code, 'district', ''),
                getattr(self.customer_code, 'postal_code', '')
            ]
            self.address = ",".join(filter(None, address_parts))  # Join non-empty parts

        super().save(*args, **kwargs)


    def __str__(self):
        return f"{self.model} - {self.customer_code}"


class ServiceEntry(models.Model):
    card = models.ForeignKey(Card, related_name="service_entries", on_delete=models.CASCADE)
    service = models.CharField(max_length=255, blank=True)
    date = models.DateField()
    next_service = models.DateField()
    visit_type = models.CharField(max_length=10, choices=[('I', 'Installation'), ('C', 'Complaint'), ('MS', 'Mandatory Service'), ('CS', 'Contract Service'), ('CC', 'Courtesy Call')])
    nature_of_complaint = models.TextField(null=True, blank=True)
    work_details = models.TextField()
    parts_replaced = models.TextField(null=True, blank=True)
    icr_number = models.CharField(max_length=50, null=True, blank=True)
    amount_charged = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    customer_signature = models.JSONField(null=True, blank=True)
    Signature_Image = models.ImageField(upload_to=signature_image_upload_path, blank=True, null=True)
    Signature_By = models.CharField(max_length=255, blank=True, null=True)
    Signature_At = models.DateTimeField(blank=True, null=True)
    OTP_Verified = models.BooleanField(default=False)

    def __str__(self):
        return f"Service Entry for {self.card.customer_code} on {self.date}"
