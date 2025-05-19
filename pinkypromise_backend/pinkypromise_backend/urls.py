# pinkypromise_backend/urls.py
from django.contrib import admin
from django.urls import path, include
from rest_framework.authtoken import views
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('authentication.urls')),
    # path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    # path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    # # For token authentication
    # path('api-token-auth/', views.obtain_auth_token),
    # # Include accounts URLs
    # path('api/accounts/', include('accounts.urls')),
]
