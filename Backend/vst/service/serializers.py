from rest_framework import serializers
from .models import Service

class ServiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Service
        fields = [
            'id',
            'customer',
            'worker_id',
            'region',
            'available',
            'customer_data',
            'complaint',
            'status',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at', 'customer_data', 'region']  # These fields are auto-filled

    def create(self, validated_data):
        # Get customer instance
        customer = validated_data.get('customer')
        
        # Create a Service instance
        service = Service(**validated_data)

        # Automatically set region from the customer's region
        service.region = customer.region

        # Automatically set customer data
        service.customer_data = {
            'name': customer.name,
            'phone': customer.phone,
            'email': customer.email,
            'region': customer.region,
            'address': customer.address,
            'city': customer.city,
            'district': customer.district,
            'postal_code': customer.postal_code,
        }

        # Save the service instance
        service.save()
        return service
