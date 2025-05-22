# authentication/serializers.py
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework import serializers
from django.contrib.auth.models import User

class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        # Add custom claims
        token['username'] = user.username
        # You can add more user data if needed
        return token
        
    def validate(self, attrs):
        data = super().validate(attrs)
        # Add user data to response
        from authentication.serializers import UserSerializer  # Import your user serializer
        data['user'] = UserSerializer(self.user).data
        return data
    

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = ['username', 'email', 'password']
    
    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password']
        )
        return user
