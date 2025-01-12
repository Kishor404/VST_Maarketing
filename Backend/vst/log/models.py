from django.db import models
from django.contrib.auth.hashers import make_password

class Customer(models.Model):
    REGION_CHOICES = [
        ('IND', 'India'),
        ('USA', 'United States'),
        ('AUS', 'Australia'),
    ]

    name = models.CharField(max_length=100)

    password = models.CharField(max_length=255)

    email = models.EmailField(blank=True, null=True)
    phone = models.CharField(max_length=15, unique=True)

    address = models.TextField(blank=True, null=True)
    city = models.CharField(max_length=50, blank=True, null=True)
    state = models.CharField(max_length=50, blank=True, null=True)
    postal_code = models.CharField(max_length=20, blank=True, null=True)
    country = models.CharField(max_length=50, blank=True, null=True)

    region = models.CharField(max_length=10, choices=REGION_CHOICES)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} {self.city}"

class Head(models.Model):
    REGION_CHOICES = [
        ('IND', 'India'),
        ('USA', 'United States'),
        ('AUS', 'Australia'),
    ]

    name = models.CharField(max_length=100)

    password = models.CharField(max_length=255)

    email = models.EmailField(blank=True, null=True)
    phone = models.CharField(max_length=15, unique=True)

    region = models.CharField(max_length=10, choices=REGION_CHOICES)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} {self.region}"
    
class Worker(models.Model):
    REGION_CHOICES = [
        ('IND', 'India'),
        ('USA', 'United States'),
        ('AUS', 'Australia'),
    ]

    name = models.CharField(max_length=100)

    password = models.CharField(max_length=255)

    email = models.EmailField(blank=True, null=True)
    phone = models.CharField(max_length=15, unique=True)

    region = models.CharField(max_length=10, choices=REGION_CHOICES)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} {self.region}"
    
class Admin(models.Model):

    name = models.CharField(max_length=100)

    password = models.CharField(max_length=255)

    email = models.EmailField(blank=True, null=True)
    phone = models.CharField(max_length=15, unique=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name}"