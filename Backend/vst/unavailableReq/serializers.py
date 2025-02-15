from rest_framework import serializers
from .models import UnavailableReq

class UnavailableReqSerializer(serializers.ModelSerializer):
    class Meta:
        model = UnavailableReq
        fields = [
            'id',
            'staff',
            'service'
        ]
        read_only_fields = ['id']

