from rest_framework import serializers
from .models import EditReq

class EditReqSerializer(serializers.ModelSerializer):
    class Meta:
        model = EditReq
        fields = [
            'id',
            'customerData',
            'staff',
        ]
        read_only_fields = ['id']

