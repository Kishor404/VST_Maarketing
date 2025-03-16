from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models

class UserManager(BaseUserManager):
    def create_user(self, phone, password=None, **extra_fields):
        if not phone:
            raise ValueError("The phone number must be set")
        user = self.model(phone=phone, **extra_fields)
        user.set_password(password)  # Hash the password
        user.save(using=self._db)
        return user

    def create_superuser(self, phone, password, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        return self.create_user(phone, password, **extra_fields)

class User(AbstractBaseUser, PermissionsMixin):
    ROLE_CHOICES = [
        ("user", "User"),
        ("customer", "Customer"),
        ("worker", "Worker"),
        ("admin", "Admin"),
        ("head", "Head"),
    ]
    REGION_CHOICES = [
        ("rajapalayam", "Rajapalayam"),
        ("ambasamuthiram", "Ambasamuthiram"),
        ("sankarankovil", "Sankarankovil"),
        ("tenkasi", "Tenkasi"),
        ("tirunelveli", "Tirunelveli"),
        ("chennai", "Chennai"),
    ]
    def default_availability():
        return {"unavailable": []} 

    name = models.CharField(max_length=100)
    email = models.EmailField(blank=True, null=True)
    phone = models.CharField(max_length=15, unique=True)
    address = models.TextField(blank=True, null=True)
    city = models.CharField(max_length=255, blank=True, null=True)
    district = models.CharField(max_length=255, blank=True, null=True)
    postal_code = models.CharField(max_length=255, blank=True, null=True)
    region = models.CharField(max_length=255, choices=REGION_CHOICES)
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default="user")

    FCM_Token = models.CharField(max_length=255, blank=True)

    #  FOR WORKERS ONLY
    availability=models.JSONField(default=default_availability)
    last_service=models.CharField(default="None", max_length=50)


    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)  # Required for Django admin
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    USERNAME_FIELD = "phone"
    REQUIRED_FIELDS = ["name", "email"]  # Required for `createsuperuser`

    objects = UserManager()

    def __str__(self):
        return f"{self.name} ({self.role})"
