# tasks.py
from celery import shared_task
from .models import TestRecording
from .ai_processor import VideoAnalyzer
import logging

@shared_task
def process_video_analysis(recording_id):
    """Background task to process video analysis"""
    try:
        recording = TestRecording.objects.get(id=recording_id)
        recording.processing_status = 'processing'
        recording.save()
        
        analyzer = VideoAnalyzer()
        
        # Determine analysis type based on test category
        if recording.test_category.name == 'Vertical Jump':
            results = analyzer.analyze_vertical_jump(recording.original_video_url)
        elif recording.test_category.name == 'Sit-ups':
            results = analyzer.analyze_situps(recording.original_video_url)
        # Add other test types...
        
        # Update recording with results
        recording.ai_raw_score = results['score']
        recording.ai_confidence = results['confidence']
        recording.ai_analysis_data = results['analysis_data']
        recording.processing_status = 'completed'
        
        # Calculate grade and percentile
        grade, percentile = calculate_performance_grade(
            recording.ai_raw_score,
            recording.test_category,
            recording.user
        )
        recording.grade = grade
        recording.percentile = percentile
        recording.final_score = recording.ai_raw_score
        
        recording.save()
        
        # Update leaderboards
        update_leaderboards(recording)
        
        logging.info(f"Successfully processed recording {recording_id}")
        
    except Exception as e:
        recording.processing_status = 'failed'
        recording.processing_error = str(e)
        recording.save()
        logging.error(f"Failed to process recording {recording_id}: {str(e)}")