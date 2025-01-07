from rest_framework import serializers
from .models import Customer

class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = [
            'id', 'name', 'email', 'phone',
            'address', 'city', 'state', 'postal_code', 'country',
            'region', 'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']
