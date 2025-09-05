from rest_framework import serializers
from .models import TestRecording

class TestRecordingSerializer(serializers.ModelSerializer):
    class Meta:
        model = TestRecording
        fields = '__all__'


class LeaderboardSerializer(serializers.ModelSerializer):
    class Meta:
        model = TestRecording
        fields = '__all__'