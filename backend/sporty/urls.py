"""sporty URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework.documentation import include_docs_urls
from django.conf import settings
from django.conf.urls.static import static

from . import views

# Create router and register viewsets
router = DefaultRouter()
router.register(r'athletes', views.AthleteProfileViewSet, basename='athletes')
router.register(r'fitness-tests', views.FitnessTestViewSet, basename='fitness-tests')
router.register(r'assessment-sessions', views.AssessmentSessionViewSet, basename='assessment-sessions')
router.register(r'test-recordings', views.TestRecordingViewSet, basename='test-recordings')
router.register(r'leaderboards', views.LeaderboardViewSet, basename='leaderboards')
router.register(r'badges', views.BadgeViewSet, basename='badges')
router.register(r'sai-submissions', views.SAISubmissionViewSet, basename='sai-submissions')
router.register(r'stats', views.StatsViewSet, basename='stats')
from rest_framework.authtoken.views import obtain_auth_token

urlpatterns = [
    # Admin interface
    path('admin/', admin.site.urls),

    path('api/auth/login/', obtain_auth_token, name='api_token_auth'),
    # API endpoints
    path('api/v1/', include(router.urls)),
    
    # Authentication endpoints (Django REST Framework)
    path('api/auth/', include('rest_framework.urls')),
    
    # Custom API endpoints
    path('api/v1/device/optimize/', views.optimize_for_device, name='optimize-device'),
    
    # Health check endpoint
    path('health/', views.health_check, name='health-check'),
    
    # API Documentation
    path('api/docs/', include_docs_urls(title='SAI Talent Assessment API')),
    
    # Root redirect to API docs
    path('', views.api_root, name='api-root'),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)

# Add custom error handlers
handler404 = 'sporty.views.custom_404'
handler500 = 'sporty.views.custom_500'