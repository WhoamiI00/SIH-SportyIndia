from django.db import models
from django.contrib.auth.models import AbstractUser
import uuid

class AthleteProfile(models.Model):
    GENDER_CHOICES = [
        ('male', 'Male'),
        ('female', 'Female'),
        ('other', 'Other')
    ]
    
    CATEGORY_CHOICES = [
        ('rural', 'Rural'),
        ('urban', 'Urban'),
        ('tribal', 'Tribal Area'),
        ('remote', 'Remote Area')
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    auth_user_id = models.UUIDField(unique=True)  # Supabase auth user ID
    full_name = models.CharField(max_length=255)
    date_of_birth = models.DateField()
    age = models.IntegerField()  # Calculated field for benchmarking
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES)
    height = models.DecimalField(max_digits=5, decimal_places=2, help_text="Height in cm")
    weight = models.DecimalField(max_digits=5, decimal_places=2, help_text="Weight in kg")
    
    # Contact & Location
    phone_number = models.CharField(max_length=15)
    email = models.EmailField(null=True, blank=True)
    address = models.TextField()
    state = models.CharField(max_length=100)
    district = models.CharField(max_length=100)
    pin_code = models.CharField(max_length=10)
    location_category = models.CharField(max_length=20, choices=CATEGORY_CHOICES)
    
    # SAI Specific
    aadhaar_number = models.CharField(max_length=12, unique=True, help_text="For identity verification")
    sports_interests = models.JSONField(default=list)
    previous_sports_experience = models.TextField(null=True, blank=True)
    
    # Profile & Verification
    profile_picture_url = models.URLField(null=True, blank=True)
    is_verified = models.BooleanField(default=False)
    verification_status = models.CharField(max_length=20, default='pending', choices=[
        ('pending', 'Pending'),
        ('document_submitted', 'Documents Submitted'),
        ('verified', 'Verified'),
        ('rejected', 'Rejected')
    ])
    
    # Talent Score & Ranking
    overall_talent_score = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    talent_grade = models.CharField(max_length=5, null=True, blank=True)  # A+, A, B+, B, C
    national_ranking = models.IntegerField(null=True, blank=True)
    state_ranking = models.IntegerField(null=True, blank=True)
    
    # Gamification
    total_points = models.IntegerField(default=0)
    badges_earned = models.JSONField(default=list)
    level = models.IntegerField(default=1)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'athlete_profiles'

class FitnessTest(models.Model):
    """Standard SAI Fitness Tests"""
    TEST_TYPES = [
        ('height_weight', 'Height & Weight Measurement'),
        ('vertical_jump', 'Vertical Jump'),
        ('shuttle_run', 'Shuttle Run'),
        ('situps', 'Sit-ups'),
        ('endurance_run', 'Endurance Run (1600m)'),
        ('flexibility', 'Flexibility Test'),
        ('agility', 'Agility Test')
    ]
    
    name = models.CharField(max_length=50, choices=TEST_TYPES, unique=True)
    display_name = models.CharField(max_length=100)
    description = models.TextField()
    instructions = models.TextField()
    video_demo_url = models.URLField(null=True, blank=True)
    
    # Test Configuration
    duration_seconds = models.IntegerField(null=True, blank=True, help_text="Max time for test")
    requires_video = models.BooleanField(default=True)
    measurement_unit = models.CharField(max_length=20)  # cm, seconds, reps, meters
    
    # AI Analysis Config
    ai_model_config = models.JSONField(default=dict, help_text="Configuration for AI analysis")
    cheat_detection_enabled = models.BooleanField(default=True)
    
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'fitness_tests'

class AgeBenchmark(models.Model):
    """Age and gender specific performance benchmarks"""
    fitness_test = models.ForeignKey(FitnessTest, on_delete=models.CASCADE)
    age_min = models.IntegerField()
    age_max = models.IntegerField()
    gender = models.CharField(max_length=10)
    
    # Performance Thresholds
    excellent_threshold = models.DecimalField(max_digits=10, decimal_places=3)
    good_threshold = models.DecimalField(max_digits=10, decimal_places=3)
    average_threshold = models.DecimalField(max_digits=10, decimal_places=3)
    below_average_threshold = models.DecimalField(max_digits=10, decimal_places=3)
    
    # Points for gamification
    excellent_points = models.IntegerField(default=100)
    good_points = models.IntegerField(default=80)
    average_points = models.IntegerField(default=60)
    below_average_points = models.IntegerField(default=40)
    
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'age_benchmarks'
        unique_together = ['fitness_test', 'age_min', 'age_max', 'gender']

class AssessmentSession(models.Model):
    STATUS_CHOICES = [
        ('created', 'Created'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('submitted_to_sai', 'Submitted to SAI'),
        ('verified_by_sai', 'Verified by SAI')
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    athlete = models.ForeignKey(
        AthleteProfile, 
        on_delete=models.CASCADE,
        null=True,  # Temporarily allow null
        blank=True
    )
    session_name = models.CharField(max_length=255, default="Fitness Assessment")
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='created')
    
    # Test Progress
    total_tests = models.IntegerField(default=7)  # Standard SAI battery
    completed_tests = models.IntegerField(default=0)
    
    # Scores & Results
    overall_score = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    overall_grade = models.CharField(max_length=5, null=True, blank=True)
    percentile_rank = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    
    # SAI Submission
    sai_submission_id = models.CharField(max_length=100, null=True, blank=True)
    sai_officer_notes = models.TextField(null=True, blank=True)
    sai_verification_status = models.CharField(max_length=20, null=True, blank=True)
    
    # Device & Network Info (for analysis)
    device_info = models.JSONField(null=True, blank=True)
    network_quality = models.CharField(max_length=20, null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    submitted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'assessment_sessions'

class TestRecording(models.Model):
    PROCESSING_STATUS_CHOICES = [
        ('uploaded', 'Uploaded'),
        ('analyzing', 'AI Analyzing'),
        ('cheat_checking', 'Cheat Detection'),
        ('completed', 'Analysis Complete'),
        ('failed', 'Analysis Failed'),
        ('flagged', 'Flagged for Review'),
        ('manually_verified', 'Manually Verified')
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    session = models.ForeignKey(AssessmentSession, on_delete=models.CASCADE, related_name='recordings')
    fitness_test = models.ForeignKey(FitnessTest, on_delete=models.CASCADE)
    athlete = models.ForeignKey(AthleteProfile, on_delete=models.CASCADE)
    
    # Video Data
    original_video_url = models.URLField()
    processed_video_url = models.URLField(null=True, blank=True)
    thumbnail_url = models.URLField(null=True, blank=True)
    video_duration = models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)
    video_size_mb = models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)
    
    # Device Analysis (On-device results)
    device_analysis_score = models.DecimalField(max_digits=10, decimal_places=3, null=True, blank=True)
    device_analysis_confidence = models.DecimalField(max_digits=5, decimal_places=4, null=True, blank=True)
    device_analysis_data = models.JSONField(null=True, blank=True)
    
    # Server AI Analysis
    ai_raw_score = models.DecimalField(max_digits=10, decimal_places=3, null=True, blank=True)
    ai_confidence = models.DecimalField(max_digits=5, decimal_places=4, null=True, blank=True)
    ai_analysis_data = models.JSONField(null=True, blank=True)
    
    # Cheat Detection
    cheat_detection_score = models.DecimalField(max_digits=5, decimal_places=4, null=True, blank=True)
    cheat_flags = models.JSONField(default=list)  # List of detected issues
    is_suspicious = models.BooleanField(default=False)
    
    # Manual Verification (SAI Officials)
    manual_score = models.DecimalField(max_digits=10, decimal_places=3, null=True, blank=True)
    verified_by_sai_officer = models.CharField(max_length=100, null=True, blank=True)
    verification_notes = models.TextField(null=True, blank=True)
    
    # Final Results
    final_score = models.DecimalField(max_digits=10, decimal_places=3, null=True, blank=True)
    performance_grade = models.CharField(max_length=10, null=True, blank=True)
    percentile = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    points_earned = models.IntegerField(null=True, blank=True)
    
    # Processing Status
    processing_status = models.CharField(max_length=20, choices=PROCESSING_STATUS_CHOICES, default='uploaded')
    processing_error = models.TextField(null=True, blank=True)
    retry_count = models.IntegerField(default=0)
    
    created_at = models.DateTimeField(auto_now_add=True)
    processed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'test_recordings'

class Leaderboard(models.Model):
    """Gamified leaderboards for athlete engagement"""
    LEADERBOARD_TYPES = [
        ('national', 'National'),
        ('state', 'State'),
        ('district', 'District'),
        ('age_group', 'Age Group'),
        ('test_specific', 'Test Specific')
    ]
    
    athlete = models.ForeignKey(AthleteProfile, on_delete=models.CASCADE)
    leaderboard_type = models.CharField(max_length=20, choices=LEADERBOARD_TYPES)
    fitness_test = models.ForeignKey(FitnessTest, on_delete=models.CASCADE, null=True, blank=True)
    
    # Ranking Info
    current_rank = models.IntegerField()
    previous_rank = models.IntegerField(null=True, blank=True)
    total_participants = models.IntegerField()
    
    # Score Info
    best_score = models.DecimalField(max_digits=10, decimal_places=3)
    total_points = models.IntegerField()
    
    # Filters
    age_group = models.CharField(max_length=20, null=True, blank=True)
    gender = models.CharField(max_length=10, null=True, blank=True)
    state = models.CharField(max_length=100, null=True, blank=True)
    district = models.CharField(max_length=100, null=True, blank=True)
    
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'leaderboards'

class Badge(models.Model):
    """Achievement badges for gamification"""
    BADGE_TYPES = [
        ('performance', 'Performance Achievement'),
        ('consistency', 'Consistency'),
        ('improvement', 'Improvement'),
        ('participation', 'Participation'),
        ('special', 'Special Achievement')
    ]
    
    name = models.CharField(max_length=100)
    description = models.TextField()
    badge_type = models.CharField(max_length=20, choices=BADGE_TYPES)
    icon_url = models.URLField()
    
    # Criteria
    criteria = models.JSONField(help_text="JSON defining criteria to earn this badge")
    points_reward = models.IntegerField(default=0)
    
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'badges'

class AthleteBadge(models.Model):
    """Junction table for athlete badges"""
    athlete = models.ForeignKey(AthleteProfile, on_delete=models.CASCADE)
    badge = models.ForeignKey(Badge, on_delete=models.CASCADE)
    earned_at = models.DateTimeField(auto_now_add=True)
    
    # Context
    test_recording = models.ForeignKey(TestRecording, on_delete=models.SET_NULL, null=True, blank=True)
    notes = models.TextField(null=True, blank=True)

    class Meta:
        db_table = 'athlete_badges'
        unique_together = ['athlete', 'badge']

class SAISubmission(models.Model):
    """Track submissions to SAI for official review"""
    STATUS_CHOICES = [
        ('pending', 'Pending Submission'),
        ('submitted', 'Submitted to SAI'),
        ('under_review', 'Under SAI Review'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
        ('requires_retest', 'Requires Retest')
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    assessment_session = models.ForeignKey(AssessmentSession, on_delete=models.CASCADE)
    athlete = models.ForeignKey(AthleteProfile, on_delete=models.CASCADE)
    
    # Submission Data
    sai_reference_id = models.CharField(max_length=100, unique=True)
    submitted_data = models.JSONField(help_text="Complete athlete and test data")
    
    # SAI Response
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    sai_officer_id = models.CharField(max_length=100, null=True, blank=True)
    sai_comments = models.TextField(null=True, blank=True)
    talent_category = models.CharField(max_length=50, null=True, blank=True)
    recommended_sports = models.JSONField(null=True, blank=True)
    
    # Follow-up
    follow_up_required = models.BooleanField(default=False)
    next_assessment_date = models.DateField(null=True, blank=True)
    
    submitted_at = models.DateTimeField(auto_now_add=True)
    reviewed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'sai_submissions'