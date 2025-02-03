from rest_framework import serializers
from .models import Service


class ServiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Service
        fields = [
            'id',
            'customer',
            'customer_data',
            'worker_id',
            'available',
            'complaint',
            'region',
            'status',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id','created_at', 'updated_at']