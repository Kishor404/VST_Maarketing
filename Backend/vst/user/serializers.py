from rest_framework import serializers
from .models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "name", "phone", "email","address" ,"city" ,"district","postal_code","region" ,"role", "password", "availability", "last_service","FCM_Token", "created_at", "updated_at"]
        extra_kwargs = {"password": {"write_only": True}}

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user
