from rest_framework import serializers
from .models import EditReq

class EditReqSerializer(serializers.ModelSerializer):
    class Meta:
        model = EditReq
        fields = [
            'id',
            'customer',
            'customerData',
            'staff',
            'staff_name',
        ]
        read_only_fields = ['id']

