# authentication/views.py
import requests
from django.conf import settings
from rest_framework_simplejwt.views import TokenObtainPairView
from .serializers import MyTokenObtainPairSerializer
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth.models import User
from .serializers import UserSerializer

class MyTokenObtainPairView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer
    
    def post(self, request, *args, **kwargs):
        # Verify captcha before proceeding with authentication
        captcha_token = request.data.get('captcha_token')
        
        if not captcha_token:
            return Response(
                {'error': 'Captcha verification required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if not self.verify_captcha(captcha_token):
            return Response(
                {'error': 'Invalid captcha verification'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        return super().post(request, *args, **kwargs)
    
    def verify_captcha(self, captcha_token):
        """Verify captcha token with Google reCAPTCHA"""
        secret_key = getattr(settings, 'RECAPTCHA_SECRET_KEY', '')
        
        if not secret_key:
            print("Warning: RECAPTCHA_SECRET_KEY not set in settings")
            return True
        
        verify_url = 'https://www.google.com/recaptcha/api/siteverify'
        data = {
            'secret': secret_key,
            'response': captcha_token
        }
        
        try:
            response = requests.post(verify_url, data=data, timeout=10)
            result = response.json()
            return result.get('success', False)
        except requests.RequestException as e:
            print(f"Captcha verification error: {e}")
            return False

class RegisterView(APIView):
    """Register a new user with CAPTCHA verification"""
    
    def verify_captcha(self, captcha_token):
        """Verify captcha token with Google reCAPTCHA"""
        secret_key = getattr(settings, 'RECAPTCHA_SECRET_KEY', '')
        
        if not secret_key:
            print("Warning: RECAPTCHA_SECRET_KEY not set in settings")
            return True
        
        verify_url = 'https://www.google.com/recaptcha/api/siteverify'
        data = {
            'secret': secret_key,
            'response': captcha_token
        }
        
        try:
            response = requests.post(verify_url, data=data, timeout=10)
            result = response.json()
            return result.get('success', False)
        except requests.RequestException as e:
            print(f"Captcha verification error: {e}")
            return False
    
    def post(self, request):
        print("Received registration data:", request.data)
        
        # Verify captcha first
        captcha_token = request.data.get('captcha_token')
        
        if not captcha_token:
            return Response(
                {'error': 'Captcha verification required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if not self.verify_captcha(captcha_token):
            return Response(
                {'error': 'Invalid captcha verification'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Proceed with registration
        serializer = UserSerializer(data=request.data)
        
        if serializer.is_valid():
            user = serializer.save()
            return Response(
                {
                    'message': 'Registration successful! Please login to continue.',
                    'user': {
                        'username': user.username,
                        'email': user.email
                    }
                }, 
                status=status.HTTP_201_CREATED
            )
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
