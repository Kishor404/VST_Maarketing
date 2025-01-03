from rest_framework import serializers
from .models import Card, ServiceEntry


class ServiceEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = ServiceEntry
        fields = [
            'id',
            'card',
            'date',
            'visit_type',
            'nature_of_complaint',
            'work_details',
            'parts_replaced',
            'icr_number',
            'amount_charged',
            'customer_signature',
            'cse_signature',
        ]
        read_only_fields = ['id']


class CardSerializer(serializers.ModelSerializer):
    service_entries = ServiceEntrySerializer(many=True, read_only=True)

    class Meta:
        model = Card
        fields = [
            'id',
            'model',
            'customer_code',
            'date_of_installation',
            'address',
            'warranty_start_date',
            'warranty_end_date',
            'acm_start_date',
            'acm_end_date',
            'contract_start_date',
            'contract_end_date',
            'service_entries',
        ]
        read_only_fields = ['id']
