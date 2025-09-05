# models.py
from django.db import models
from django.contrib.auth.models import AbstractUser
import uuid

class UserProfile(models.Model):
    GENDER_CHOICES = [
        ('male', 'Male'),
        ('female', 'Female'),
        ('other', 'Other')
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    auth_user_id = models.UUIDField(unique=True)  # Supabase auth user ID
    full_name = models.CharField(max_length=255)
    date_of_birth = models.DateField(null=True, blank=True)
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES)
    height = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    weight = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    phone_number = models.CharField(max_length=15, null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    state = models.CharField(max_length=100, null=True, blank=True)
    district = models.CharField(max_length=100, null=True, blank=True)
    pin_code = models.CharField(max_length=10, null=True, blank=True)
    profile_picture_url = models.URLField(null=True, blank=True)
    sports_interests = models.JSONField(default=list)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class TestCategory(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(null=True, blank=True)
    instructions = models.TextField(null=True, blank=True)
    video_demo_url = models.URLField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

class AgeGroupBenchmark(models.Model):
    test_category = models.ForeignKey(TestCategory, on_delete=models.CASCADE)
    age_group = models.CharField(max_length=20)
    gender = models.CharField(max_length=10)
    excellent_min = models.DecimalField(max_digits=10, decimal_places=3)
    good_min = models.DecimalField(max_digits=10, decimal_places=3)
    average_min = models.DecimalField(max_digits=10, decimal_places=3)
    below_average_max = models.DecimalField(max_digits=10, decimal_places=3)
    unit = models.CharField(max_length=20)
    created_at = models.DateTimeField(auto_now_add=True)

class AssessmentSession(models.Model):
    STATUS_CHOICES = [
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('submitted', 'Submitted')
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(UserProfile, on_delete=models.CASCADE)
    session_name = models.CharField(max_length=255)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='in_progress')
    total_tests = models.IntegerField(default=0)
    completed_tests = models.IntegerField(default=0)
    overall_score = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    overall_grade = models.CharField(max_length=10, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)

class TestRecording(models.Model):
    PROCESSING_STATUS_CHOICES = [
        ('uploaded', 'Uploaded'),
        ('processing', 'Processing'),
        ('completed', 'Completed'),
        ('failed', 'Failed')
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    session = models.ForeignKey(AssessmentSession, on_delete=models.CASCADE)
    test_category = models.ForeignKey(TestCategory, on_delete=models.CASCADE)
    user = models.ForeignKey(UserProfile, on_delete=models.CASCADE)
    
    # Video URLs
    original_video_url = models.URLField(null=True, blank=True)
    processed_video_url = models.URLField(null=True, blank=True)
    thumbnail_url = models.URLField(null=True, blank=True)
    
    # AI Results
    ai_raw_score = models.DecimalField(max_digits=10, decimal_places=3, null=True, blank=True)
    ai_confidence = models.DecimalField(max_digits=5, decimal_places=4, null=True, blank=True)
    ai_analysis_data = models.JSONField(null=True, blank=True)
    
    # Manual verification
    manual_score = models.DecimalField(max_digits=10, decimal_places=3, null=True, blank=True)
    verified_by = models.UUIDField(null=True, blank=True)
    verification_notes = models.TextField(null=True, blank=True)
    
    # Final results
    final_score = models.DecimalField(max_digits=10, decimal_places=3, null=True, blank=True)
    grade = models.CharField(max_length=10, null=True, blank=True)
    percentile = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    
    # Flags
    is_flagged = models.BooleanField(default=False)
    flag_reason = models.TextField(null=True, blank=True)
    cheat_detection_score = models.DecimalField(max_digits=5, decimal_places=4, null=True, blank=True)
    
    # Processing
    processing_status = models.CharField(max_length=20, choices=PROCESSING_STATUS_CHOICES, default='uploaded')
    processing_error = models.TextField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    processed_at = models.DateTimeField(null=True, blank=True)