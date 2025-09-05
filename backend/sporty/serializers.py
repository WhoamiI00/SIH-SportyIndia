from rest_framework import serializers
from .models import *
from datetime import date

class AthleteProfileSerializer(serializers.ModelSerializer):
    age = serializers.SerializerMethodField()
    
    class Meta:
        model = AthleteProfile
        fields = '__all__'
        read_only_fields = ('id', 'created_at', 'updated_at', 'overall_talent_score', 
                           'talent_grade', 'national_ranking', 'state_ranking')
    
    def get_age(self, obj):
        if obj.date_of_birth:
            today = date.today()
            return today.year - obj.date_of_birth.year - ((today.month, today.day) < (obj.date_of_birth.month, obj.date_of_birth.day))
        return None

class FitnessTestSerializer(serializers.ModelSerializer):
    class Meta:
        model = FitnessTest
        fields = '__all__'

class AgeBenchmarkSerializer(serializers.ModelSerializer):
    fitness_test_name = serializers.CharField(source='fitness_test.display_name', read_only=True)
    
    class Meta:
        model = AgeBenchmark
        fields = '__all__'

class AssessmentSessionSerializer(serializers.ModelSerializer):
    athlete_name = serializers.CharField(source='athlete.full_name', read_only=True)
    progress_percentage = serializers.SerializerMethodField()
    
    class Meta:
        model = AssessmentSession
        fields = '__all__'
        read_only_fields = ('id', 'created_at', 'completed_at', 'submitted_at')
    
    def get_progress_percentage(self, obj):
        if obj.total_tests > 0:
            return round((obj.completed_tests / obj.total_tests) * 100, 2)
        return 0

class TestRecordingSerializer(serializers.ModelSerializer):
    athlete_name = serializers.CharField(source='athlete.full_name', read_only=True)
    test_name = serializers.CharField(source='fitness_test.display_name', read_only=True)
    
    class Meta:
        model = TestRecording
        fields = '__all__'
        read_only_fields = ('id', 'created_at', 'processed_at')

class VideoUploadSerializer(serializers.Serializer):
    """Serializer for video upload endpoint"""
    session_id = serializers.UUIDField()
    fitness_test_id = serializers.IntegerField()
    video_file = serializers.FileField()
    device_analysis_score = serializers.DecimalField(max_digits=10, decimal_places=3, required=False)
    device_analysis_confidence = serializers.DecimalField(max_digits=5, decimal_places=4, required=False)
    device_analysis_data = serializers.JSONField(required=False)
    device_info = serializers.JSONField(required=False)

class LeaderboardSerializer(serializers.ModelSerializer):
    athlete_name = serializers.CharField(source='athlete.full_name', read_only=True)
    athlete_state = serializers.CharField(source='athlete.state', read_only=True)
    athlete_district = serializers.CharField(source='athlete.district', read_only=True)
    fitness_test_name = serializers.CharField(source='fitness_test.display_name', read_only=True)
    rank_change = serializers.SerializerMethodField()
    
    class Meta:
        model = Leaderboard
        fields = '__all__'
    
    def get_rank_change(self, obj):
        if obj.previous_rank:
            return obj.previous_rank - obj.current_rank  # Positive = rank improved
        return 0

class BadgeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Badge
        fields = '__all__'

class AthleteBadgeSerializer(serializers.ModelSerializer):
    badge_details = BadgeSerializer(source='badge', read_only=True)
    
    class Meta:
        model = AthleteBadge
        fields = '__all__'

class SAISubmissionSerializer(serializers.ModelSerializer):
    athlete_name = serializers.CharField(source='athlete.full_name', read_only=True)
    session_details = AssessmentSessionSerializer(source='assessment_session', read_only=True)
    
    class Meta:
        model = SAISubmission
        fields = '__all__'
        read_only_fields = ('id', 'sai_reference_id', 'submitted_at', 'reviewed_at')

class TalentSummarySerializer(serializers.ModelSerializer):
    """Summary serializer for talent dashboard"""
    recent_sessions = serializers.SerializerMethodField()
    best_performances = serializers.SerializerMethodField()
    earned_badges = serializers.SerializerMethodField()
    current_rankings = serializers.SerializerMethodField()
    
    class Meta:
        model = AthleteProfile
        fields = ('id', 'full_name', 'age', 'state', 'district', 'overall_talent_score', 
                 'talent_grade', 'total_points', 'level', 'recent_sessions', 
                 'best_performances', 'earned_badges', 'current_rankings')
    
    def get_recent_sessions(self, obj):
        sessions = AssessmentSession.objects.filter(athlete=obj).order_by('-created_at')[:3]
        return AssessmentSessionSerializer(sessions, many=True).data
    
    def get_best_performances(self, obj):
        recordings = TestRecording.objects.filter(
            athlete=obj, 
            processing_status='completed'
        ).order_by('-percentile')[:5]
        return TestRecordingSerializer(recordings, many=True).data
    
    def get_earned_badges(self, obj):
        badges = AthleteBadge.objects.filter(athlete=obj).order_by('-earned_at')[:10]
        return AthleteBadgeSerializer(badges, many=True).data
    
    def get_current_rankings(self, obj):
        rankings = Leaderboard.objects.filter(athlete=obj)
        return LeaderboardSerializer(rankings, many=True).data

class BenchmarkComparisonSerializer(serializers.Serializer):
    """For comparing athlete performance against benchmarks"""
    athlete_score = serializers.DecimalField(max_digits=10, decimal_places=3)
    benchmark_excellent = serializers.DecimalField(max_digits=10, decimal_places=3)
    benchmark_good = serializers.DecimalField(max_digits=10, decimal_places=3)
    benchmark_average = serializers.DecimalField(max_digits=10, decimal_places=3)
    benchmark_below_average = serializers.DecimalField(max_digits=10, decimal_places=3)
    performance_category = serializers.CharField()
    percentile = serializers.DecimalField(max_digits=5, decimal_places=2)
    points_earned = serializers.IntegerField()

class AnalysisStatusSerializer(serializers.Serializer):
    """For checking video analysis status"""
    recording_id = serializers.UUIDField()
    processing_status = serializers.CharField()
    progress_percentage = serializers.IntegerField()
    ai_confidence = serializers.DecimalField(max_digits=5, decimal_places=4, required=False)
    cheat_detection_score = serializers.DecimalField(max_digits=5, decimal_places=4, required=False)
    is_suspicious = serializers.BooleanField(required=False)
    estimated_completion_time = serializers.IntegerField(required=False)  # seconds
    
class DeviceCapabilitySerializer(serializers.Serializer):
    """For assessing device capabilities for optimal experience"""
    device_type = serializers.CharField()
    os_version = serializers.CharField()
    available_storage_mb = serializers.IntegerField()
    camera_resolution = serializers.CharField()
    network_speed_mbps = serializers.DecimalField(max_digits=6, decimal_places=2)
    recommended_quality = serializers.CharField()
    offline_analysis_supported = serializers.BooleanField()