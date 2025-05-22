# authentication/views.py
from rest_framework_simplejwt.views import TokenObtainPairView
from .serializers import MyTokenObtainPairSerializer
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth.models import User
from .serializers import UserSerializer  # Make sure you have this serializer

class MyTokenObtainPairView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer


class RegisterView(APIView):
    """
    Register a new user
    """
    def post(self, request):
        # Print request data for debugging
        print("Received registration data:", request.data)
        
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)