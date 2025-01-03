from django.db import models

class Card(models.Model):
    model = models.CharField(max_length=100)
    customer_code = models.CharField(unique=True, max_length=100)
    date_of_installation = models.DateField()
    address = models.TextField()
    warranty_start_date = models.DateField()
    warranty_end_date = models.DateField()
    acm_start_date = models.DateField(null=True, blank=True)
    acm_end_date = models.DateField(null=True, blank=True)
    contract_start_date = models.DateField(null=True, blank=True)
    contract_end_date = models.DateField(null=True, blank=True)

    def __str__(self):
        return f"{self.model} - {self.customer_code}"


class ServiceEntry(models.Model):
    card = models.ForeignKey(Card, related_name="service_entries", on_delete=models.CASCADE)
    date = models.DateField()
    visit_type = models.CharField(max_length=10, choices=[('I', 'Installation'), ('C', 'Complaint'), ('MS', 'Mandatory Service'), ('CS', 'Contract Service'), ('CC', 'Courtesy Call')])
    nature_of_complaint = models.TextField(null=True, blank=True)
    work_details = models.TextField()
    parts_replaced = models.TextField(null=True, blank=True)
    icr_number = models.CharField(max_length=50, null=True, blank=True)
    amount_charged = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    customer_signature = models.JSONField(null=True, blank=True)
    cse_signature = models.JSONField(null=True, blank=True)

    def __str__(self):
        return f"Service Entry for {self.card.customer_code} on {self.date}"
