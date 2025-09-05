# views.py
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.core.files.storage import default_storage
from .models import *
from .serializers import *
from .ai_processor import VideoAnalyzer

class TestRecordingViewSet(viewsets.ModelViewSet):
    queryset = TestRecording.objects.all()
    serializer_class = TestRecordingSerializer
    
    @action(detail=False, methods=['post'])
    def upload_video(self, request):
        """Handle video upload and trigger AI analysis"""
        try:
            video_file = request.FILES['video']
            session_id = request.data['session_id']
            test_category_id = request.data['test_category_id']
            
            # Save video to Supabase Storage
            video_url = self.save_to_supabase_storage(video_file)
            
            # Create test recording
            recording = TestRecording.objects.create(
                session_id=session_id,
                test_category_id=test_category_id,
                user_id=request.data['user_id'],
                original_video_url=video_url,
                processing_status='uploaded'
            )
            
            # Trigger AI analysis (async task)
            from .tasks import process_video_analysis
            process_video_analysis.delay(recording.id)
            
            return Response({
                'recording_id': recording.id,
                'status': 'uploaded',
                'message': 'Video uploaded successfully. Analysis in progress.'
            })
            
        except Exception as e:
            return Response({
                'error': str(e)
            }, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['get'])
    def analysis_status(self, request, pk=None):
        """Check analysis status of a recording"""
        recording = self.get_object()
        
        return Response({
            'recording_id': recording.id,
            'processing_status': recording.processing_status,
            'ai_results': recording.ai_analysis_data,
            'final_score': recording.final_score,
            'grade': recording.grade
        })

class LeaderboardViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = TestRecording.objects.filter(processing_status='completed')
    serializer_class = LeaderboardSerializer
    
    @action(detail=False, methods=['get'])
    def get_rankings(self, request):
        """Get leaderboard rankings"""
        test_category = request.query_params.get('test_category')
        age_group = request.query_params.get('age_group')
        gender = request.query_params.get('gender')
        
        # Build query based on filters
        queryset = self.get_queryset()
        if test_category:
            queryset = queryset.filter(test_category_id=test_category)
        
        # Add ranking logic
        rankings = self.calculate_rankings(queryset, age_group, gender)
        
        return Response(rankings)
    
from django.http import JsonResponse
from sporty.utils.supabase_utils import fetch_from_supabase, insert_to_supabase

def list_data(request):
    return JsonResponse(fetch_from_supabase('your_table'), safe=False)

def add_data(request):
    if request.method == 'POST':
        return JsonResponse(insert_to_supabase('your_table', request.POST.dict()), safe=False)
