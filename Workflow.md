# AI-Powered Sports Talent Assessment Platform - Complete Development Workflow

## Tech Stack Overview
- **Backend**: Django + Django REST Framework
- **Database**: PostgreSQL (via Supabase)
- **Storage**: Supabase Storage (for videos and files)
- **Mobile App**: Flutter
- **AI/ML**: TensorFlow Lite, MediaPipe, OpenCV
- **Authentication**: Supabase Auth
- **Real-time**: Supabase Realtime

---

## Phase 1: Project Setup & Architecture

### 1.1 Backend Setup (Django)
```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install django djangorestframework
pip install supabase
pip install django-cors-headers
pip install pillow opencv-python
pip install tensorflow mediapipe
pip install celery redis  # For background tasks
pip install python-decouple  # For environment variables
```

### 1.2 Flutter App Setup
```bash
flutter create sports_talent_app
cd sports_talent_app
flutter pub add supabase_flutter
flutter pub add camera
flutter pub add video_player
flutter pub add path_provider
flutter pub add http
flutter pub add flutter_bloc  # State management
flutter pub add tflite_flutter  # For on-device ML
```

---

## Phase 2: Database Design & Models

### 2.1 Database Schema (PostgreSQL via Supabase)

#### Core Tables:

**1. User Profile Table**
```sql
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_user_id UUID REFERENCES auth.users(id),
    full_name VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    height DECIMAL(5,2),  -- in cm
    weight DECIMAL(5,2),  -- in kg
    phone_number VARCHAR(15),
    address TEXT,
    state VARCHAR(100),
    district VARCHAR(100),
    pin_code VARCHAR(10),
    profile_picture_url TEXT,
    sports_interests TEXT[],
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

**2. Test Categories Table**
```sql
CREATE TABLE test_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,  -- 'Vertical Jump', 'Shuttle Run', etc.
    description TEXT,
    instructions TEXT,
    video_demo_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**3. Age Group Benchmarks Table**
```sql
CREATE TABLE age_group_benchmarks (
    id SERIAL PRIMARY KEY,
    test_category_id INTEGER REFERENCES test_categories(id),
    age_group VARCHAR(20),  -- '14-16', '17-19', etc.
    gender VARCHAR(10),
    excellent_min DECIMAL(10,3),
    good_min DECIMAL(10,3),
    average_min DECIMAL(10,3),
    below_average_max DECIMAL(10,3),
    unit VARCHAR(20),  -- 'cm', 'seconds', 'count'
    created_at TIMESTAMP DEFAULT NOW()
);
```

**4. Assessment Sessions Table**
```sql
CREATE TABLE assessment_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id),
    session_name VARCHAR(255),
    status VARCHAR(20) DEFAULT 'in_progress', -- 'in_progress', 'completed', 'submitted'
    total_tests INTEGER DEFAULT 0,
    completed_tests INTEGER DEFAULT 0,
    overall_score DECIMAL(5,2),
    overall_grade VARCHAR(10),  -- 'A+', 'A', 'B+', etc.
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);
```

**5. Test Recordings Table**
```sql
CREATE TABLE test_recordings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES assessment_sessions(id),
    test_category_id INTEGER REFERENCES test_categories(id),
    user_id UUID REFERENCES user_profiles(id),
    
    -- Video and file paths
    original_video_url TEXT,
    processed_video_url TEXT,
    thumbnail_url TEXT,
    
    -- AI Analysis Results
    ai_raw_score DECIMAL(10,3),
    ai_confidence DECIMAL(5,4),  -- 0.0 to 1.0
    ai_analysis_data JSONB,  -- Store detailed AI results
    
    -- Manual verification
    manual_score DECIMAL(10,3),
    verified_by UUID REFERENCES auth.users(id),
    verification_notes TEXT,
    
    -- Final results
    final_score DECIMAL(10,3),
    grade VARCHAR(10),
    percentile DECIMAL(5,2),
    
    -- Flags
    is_flagged BOOLEAN DEFAULT FALSE,
    flag_reason TEXT,
    cheat_detection_score DECIMAL(5,4),
    
    -- Processing status
    processing_status VARCHAR(20) DEFAULT 'uploaded',  -- 'uploaded', 'processing', 'completed', 'failed'
    processing_error TEXT,
    
    created_at TIMESTAMP DEFAULT NOW(),
    processed_at TIMESTAMP
);
```

**6. Performance Metrics Table**
```sql
CREATE TABLE performance_metrics (
    id SERIAL PRIMARY KEY,
    recording_id UUID REFERENCES test_recordings(id),
    metric_name VARCHAR(100),  -- 'jump_height', 'rep_count', 'time_taken'
    metric_value DECIMAL(10,3),
    metric_unit VARCHAR(20),
    confidence_score DECIMAL(5,4),
    extraction_method VARCHAR(50),  -- 'ai', 'manual', 'sensor'
    created_at TIMESTAMP DEFAULT NOW()
);
```

**7. Leaderboards Table**
```sql
CREATE TABLE leaderboards (
    id SERIAL PRIMARY KEY,
    test_category_id INTEGER REFERENCES test_categories(id),
    user_id UUID REFERENCES user_profiles(id),
    score DECIMAL(10,3),
    rank INTEGER,
    age_group VARCHAR(20),
    gender VARCHAR(10),
    state VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);
```

**8. Achievements Table**
```sql
CREATE TABLE achievements (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    icon_url TEXT,
    criteria JSONB,  -- Conditions for earning achievement
    points INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE user_achievements (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id),
    achievement_id INTEGER REFERENCES achievements(id),
    earned_at TIMESTAMP DEFAULT NOW(),
    session_id UUID REFERENCES assessment_sessions(id)
);
```

### 2.2 Django Models

```python
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
```

---

## Phase 3: AI/ML Implementation Strategy

### 3.1 On-Device AI Models (TensorFlow Lite)

**Vertical Jump Analysis**
- Use MediaPipe Pose estimation
- Track key points (hip, knee, ankle)
- Calculate jump height using trajectory analysis
- Detect takeoff and landing frames

**Sit-ups Counter**
- MediaPipe Pose for body landmarks
- Track torso angle changes
- Count complete repetitions
- Validate proper form

**Shuttle Run Timer**
- Object detection for start/end positions
- Motion analysis for direction changes
- Automatic timing calculation

**Cheat Detection System**
- Frame consistency analysis
- Motion smoothness validation
- Timestamp verification
- Device sensor data correlation

### 3.2 AI Processing Pipeline

```python
# ai_processor.py
import cv2
import mediapipe as mp
import numpy as np
from tensorflow.lite import Interpreter

class VideoAnalyzer:
    def __init__(self):
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose()
        self.mp_drawing = mp.solutions.drawing_utils
    
    def analyze_vertical_jump(self, video_path):
        """Analyze vertical jump performance"""
        cap = cv2.VideoCapture(video_path)
        jump_heights = []
        
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
                
            # Process frame with MediaPipe
            results = self.pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            
            if results.pose_landmarks:
                # Extract hip position for jump height calculation
                hip = results.pose_landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_HIP]
                jump_heights.append(hip.y)
        
        cap.release()
        
        # Calculate max jump height
        baseline = np.median(jump_heights[:30])  # Standing position
        max_height = min(jump_heights)  # Lowest y-value = highest jump
        jump_height_cm = (baseline - max_height) * 180  # Convert to cm (approximate)
        
        return {
            'jump_height': jump_height_cm,
            'confidence': 0.85,
            'analysis_data': {
                'baseline_position': baseline,
                'peak_position': max_height,
                'total_frames': len(jump_heights)
            }
        }
    
    def analyze_situps(self, video_path):
        """Count sit-ups and validate form"""
        cap = cv2.VideoCapture(video_path)
        rep_count = 0
        positions = []
        
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
                
            results = self.pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            
            if results.pose_landmarks:
                # Calculate torso angle
                shoulder = results.pose_landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_SHOULDER]
                hip = results.pose_landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_HIP]
                knee = results.pose_landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_KNEE]
                
                angle = self.calculate_angle(shoulder, hip, knee)
                positions.append(angle)
        
        cap.release()
        
        # Count complete repetitions
        rep_count = self.count_repetitions(positions, threshold_up=160, threshold_down=90)
        
        return {
            'rep_count': rep_count,
            'confidence': 0.90,
            'analysis_data': {
                'angle_sequence': positions,
                'total_frames': len(positions)
            }
        }
```

---

## Phase 4: Backend API Development

### 4.1 Django REST API Endpoints

```python
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
```

### 4.2 Celery Tasks for Background Processing

```python
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
```

---

## Phase 5: Flutter Mobile App Development

### 5.1 App Architecture (BLoC Pattern)

```dart
// lib/models/test_recording.dart
class TestRecording {
  final String id;
  final String sessionId;
  final String testCategoryId;
  final String originalVideoUrl;
  final double? aiRawScore;
  final double? aiConfidence;
  final Map<String, dynamic>? aiAnalysisData;
  final String processingStatus;
  final DateTime createdAt;

  TestRecording({
    required this.id,
    required this.sessionId,
    required this.testCategoryId,
    required this.originalVideoUrl,
    this.aiRawScore,
    this.aiConfidence,
    this.aiAnalysisData,
    required this.processingStatus,
    required this.createdAt,
  });

  factory TestRecording.fromJson(Map<String, dynamic> json) {
    return TestRecording(
      id: json['id'],
      sessionId: json['session_id'],
      testCategoryId: json['test_category_id'],
      originalVideoUrl: json['original_video_url'],
      aiRawScore: json['ai_raw_score']?.toDouble(),
      aiConfidence: json['ai_confidence']?.toDouble(),
      aiAnalysisData: json['ai_analysis_data'],
      processingStatus: json['processing_status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// lib/bloc/recording_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final RecordingRepository _repository;

  RecordingBloc(this._repository) : super(RecordingInitial()) {
    on<StartRecording>(_onStartRecording);
    on<StopRecording>(_onStopRecording);
    on<UploadVideo>(_onUploadVideo);
    on<CheckAnalysisStatus>(_onCheckAnalysisStatus);
  }

  Future<void> _onStartRecording(
    StartRecording event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      emit(RecordingInProgress());
      // Start camera recording logic
    } catch (e) {
      emit(RecordingError(e.toString()));
    }
  }

  Future<void> _onUploadVideo(
    UploadVideo event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      emit(UploadingVideo());
      
      final recording = await _repository.uploadVideo(
        videoPath: event.videoPath,
        sessionId: event.sessionId,
        testCategoryId: event.testCategoryId,
      );
      
      emit(VideoUploaded(recording));
      
      // Start polling for analysis results
      add(CheckAnalysisStatus(recording.id));
      
    } catch (e) {
      emit(RecordingError(e.toString()));
    }
  }
}
```

### 5.2 Camera Recording Screen

```dart
// lib/screens/camera_recording_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraRecordingScreen extends StatefulWidget {
  final String testCategoryId;
  final String sessionId;

  const CameraRecordingScreen({
    Key? key,
    required this.testCategoryId,
    required this.sessionId,
  }) : super(key: key);

  @override
  _CameraRecordingScreenState createState() => _CameraRecordingScreenState();
}

class _CameraRecordingScreenState extends State<CameraRecordingScreen> {
  CameraController? _controller;
  bool _isRecording = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
    );
    
    await _controller!.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Performance'),
        backgroundColor: Colors.blue[800],
      ),
      body: BlocConsumer<RecordingBloc, RecordingState>(
        listener: (context, state) {
          if (state is VideoUploaded) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AnalysisWaitingScreen(
                  recordingId: state.recording.id,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (!_isInitialized) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Instructions Panel
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[800]),
                    SizedBox(height: 8),
                    Text(
                      'Position camera 2 meters away. Ensure full body is visible.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Camera Preview
              Expanded(
                child: Stack(
                  children: [
                    CameraPreview(_controller!),
                    
                    // Overlay guidelines
                    CustomPaint(
                      size: Size(double.infinity, double.infinity),
                      painter: GuidelinePainter(),
                    ),
                    
                    // Recording indicator
                    if (_isRecording)
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.fiber_manual_record, 
                                   color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text('REC', 
                                   style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Control Panel
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        minimumSize: Size(100, 50),
                      ),
                      child: Text('Cancel'),
                    ),
                    
                    // Record/Stop Button
                    GestureDetector(
                      onTap: _toggleRecording,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? Colors.red : Colors.blue[800],
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.videocam,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    
                    // Next Button (disabled during recording)
                    ElevatedButton(
                      onPressed: _isRecording ? null : _proceedToUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        minimumSize: Size(100, 50),
                      ),
                      child: Text('Next'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleRecording() async {
    if (_isRecording) {
      final videoFile = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });
      
      // Trigger upload
      context.read<RecordingBloc>().add(UploadVideo(
        videoPath: videoFile.path,
        sessionId: widget.sessionId,
        testCategoryId: widget.testCategoryId,
      ));
    } else {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    }
  }

  void _proceedToUpload() {
    // Logic for manual upload after recording
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please record a video first')),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

// Custom painter for camera guidelines
class GuidelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw human silhouette guidelines
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Head circle
    canvas.drawCircle(
      Offset(centerX, centerY - 100),
      30,
      paint,
    );
    
    // Body rectangle
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: 80,
        height: 150,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### 5.3 Analysis Waiting Screen

```dart
// lib/screens/analysis_waiting_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class AnalysisWaitingScreen extends StatefulWidget {
  final String recordingId;

  const AnalysisWaitingScreen({
    Key? key,
    required this.recordingId,
  }) : super(key: key);

  @override
  _AnalysisWaitingScreenState createState() => _AnalysisWaitingScreenState();
}

class _AnalysisWaitingScreenState extends State<AnalysisWaitingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    
    // Start polling for results
    _startPolling();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      context.read<RecordingBloc>().add(
        CheckAnalysisStatus(widget.recordingId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: BlocConsumer<RecordingBloc, RecordingState>(
        listener: (context, state) {
          if (state is AnalysisCompleted) {
            _pollTimer?.cancel();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResultsScreen(recording: state.recording),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // AI Brain Animation
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1 + 0.1 * _animation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.blue[400]!, Colors.blue[800]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.psychology,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Progress indicator
                  LinearProgressIndicator(
                    backgroundColor: Colors.blue[100],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Status text
                  Text(
                    'AI Analysis in Progress',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  
                  SizedBox(height: 12),
                  
                  Text(
                    'Our advanced AI is analyzing your performance.\nThis may take 30-60 seconds.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Analysis steps
                  _buildAnalysisSteps(),
                  
                  Spacer(),
                  
                  // Cancel button
                  ElevatedButton(
                    onPressed: () {
                      _pollTimer?.cancel();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('Cancel Analysis'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalysisSteps() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStepItem(
            icon: Icons.video_camera_back,
            title: 'Video Processing',
            subtitle: 'Analyzing video quality and frames',
            isCompleted: true,
          ),
          _buildStepItem(
            icon: Icons.person,
            title: 'Pose Detection',
            subtitle: 'Identifying body landmarks',
            isCompleted: true,
          ),
          _buildStepItem(
            icon: Icons.calculate,
            title: 'Performance Calculation',
            subtitle: 'Computing metrics and scores',
            isCompleted: false,
            isActive: true,
          ),
          _buildStepItem(
            icon: Icons.shield,
            title: 'Authenticity Verification',
            subtitle: 'Checking for anomalies',
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isCompleted = false,
    bool isActive = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted 
                  ? Colors.green[500]
                  : isActive 
                      ? Colors.blue[500] 
                      : Colors.grey[300],
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCompleted || isActive 
                        ? Colors.grey[800] 
                        : Colors.grey[500],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }
}
```

### 5.4 Results Screen

```dart
// lib/screens/results_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultsScreen extends StatelessWidget {
  final TestRecording recording;

  const ResultsScreen({
    Key? key,
    required this.recording,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Performance Results'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey[800],
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareResults(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score Card
            _buildScoreCard(),
            
            SizedBox(height: 20),
            
            // Performance Breakdown
            _buildPerformanceBreakdown(),
            
            SizedBox(height: 20),
            
            // Benchmark Comparison
            _buildBenchmarkComparison(),
            
            SizedBox(height: 20),
            
            // AI Insights
            _buildAIInsights(),
            
            SizedBox(height: 20),
            
            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    final grade = recording.grade ?? 'N/A';
    final score = recording.finalScore ?? 0.0;
    final percentile = recording.percentile ?? 0.0;
    
    Color gradeColor = _getGradeColor(grade);
    
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradeColor.withOpacity(0.8), gradeColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradeColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Grade Display
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                grade,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: gradeColor,
                ),
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          Text(
            'Your Score: ${score.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: 8),
          
          Text(
            '${percentile.toStringAsFixed(1)}th Percentile',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Confidence indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                'AI Confidence: ${((recording.aiConfidence ?? 0.0) * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBreakdown() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 16),
          
          // Extract metrics from AI analysis data
          if (recording.aiAnalysisData != null)
            ..._buildMetricItems(recording.aiAnalysisData!),
        ],
      ),
    );
  }

  List<Widget> _buildMetricItems(Map<String, dynamic> analysisData) {
    List<Widget> items = [];
    
    // Example for vertical jump
    if (analysisData.containsKey('jump_height')) {
      items.add(_buildMetricItem(
        'Jump Height',
        '${analysisData['jump_height'].toStringAsFixed(1)} cm',
        Icons.trending_up,
        Colors.blue,
      ));
    }
    
    if (analysisData.containsKey('rep_count')) {
      items.add(_buildMetricItem(
        'Repetitions',
        '${analysisData['rep_count']} reps',
        Icons.repeat,
        Colors.green,
      ));
    }
    
    if (analysisData.containsKey('time_taken')) {
      items.add(_buildMetricItem(
        'Time Taken',
        '${analysisData['time_taken'].toStringAsFixed(2)}s',
        Icons.timer,
        Colors.orange,
      ));
    }
    
    return items;
  }

  Widget _buildMetricItem(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarkComparison() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benchmark Comparison',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 16),
          
          // Radar chart showing performance across different aspects
          Container(
            height: 200,
            child: _buildRadarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChart() {
    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            entryRadius: 3,
            dataEntries: [
              RadarEntry(value: (recording.finalScore ?? 0) / 10),
              RadarEntry(value: (recording.percentile ?? 0) / 100),
              RadarEntry(value: (recording.aiConfidence ?? 0)),
              RadarEntry(value: 0.8), // Form accuracy
              RadarEntry(value: 0.9), // Consistency
            ],
            borderColor: Colors.blue[800]!,
            fillColor: Colors.blue[800]!.withOpacity(0.2),
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
        titlePositionPercentageOffset: 0.2,
        titleTextStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        getTitle: (index, angle) {
          switch (index) {
            case 0:
              return RadarChartTitle(text: 'Score');
            case 1:
              return RadarChartTitle(text: 'Percentile');
            case 2:
              return RadarChartTitle(text: 'AI Confidence');
            case 3:
              return RadarChartTitle(text: 'Form');
            case 4:
              return RadarChartTitle(text: 'Consistency');
            default:
              return RadarChartTitle(text: '');
          }
        },
        tickCount: 4,
        ticksTextStyle: TextStyle(
          color: Colors.transparent,
          fontSize: 10,
        ),
        tickBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
        gridBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
    );
  }

  Widget _buildAIInsights() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: Colors.blue[800]),
              SizedBox(width: 8),
              Text(
                'AI Insights & Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          _buildInsightItem(
            '✓ Excellent takeoff technique detected',
            Colors.green,
          ),
          _buildInsightItem(
            '⚠ Landing could be more controlled',
            Colors.orange,
          ),
          _buildInsightItem(
            '💡 Focus on explosive leg strength training',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String text, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _retakeTest(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text('Retake Test'),
        ),
        
        SizedBox(height: 12),
        
        ElevatedButton(
          onPressed: () => _viewDetailedAnalysis(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text('View Detailed Analysis'),
        ),
        
        SizedBox(height: 12),
        
        ElevatedButton(
          onPressed: () => _continueAssessment(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text('Continue Assessment'),
        ),
      ],
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
        return Colors.green[600]!;
      case 'B+':
      case 'B':
        return Colors.blue[600]!;
      case 'C+':
      case 'C':
        return Colors.orange[600]!;
      default:
        return Colors.red[600]!;
    }
  }

  void _shareResults(BuildContext context) {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing results...')),
    );
  }

  void _retakeTest(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CameraRecordingScreen(
          testCategoryId: recording.testCategoryId,
          sessionId: recording.sessionId,
        ),
      ),
    );
  }

  void _viewDetailedAnalysis(BuildContext context) {
    // Navigate to detailed analysis screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailedAnalysisScreen(recording: recording),
      ),
    );
  }

  void _continueAssessment(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
```

---

## Phase 6: Deployment & DevOps

### 6.1 Django Deployment (Docker)

```dockerfile
# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput

# Expose port
EXPOSE 8000

# Run application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "sports_platform.wsgi:application"]
```

### 6.2 Docker Compose for Development

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DEBUG=1
      - DATABASE_URL=postgresql://user:pass@db:5432/sports_db
      - SUPABASE_URL=${SUPABASE_URL}
      - SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    volumes:
      - .:/app

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: sports_db
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:6-alpine
    ports:
      - "6379:6379"

  celery:
    build: .
    command: celery -A sports_platform worker --loglevel=info
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/sports_db
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    volumes:
      - .:/app

volumes:
  postgres_data:
```

### 6.3 CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.9
    
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
    
    - name: Run tests
      run: |
        python manage.py test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Deploy to DigitalOcean
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USERNAME }}
        key: ${{ secrets.KEY }}
        script: |
          cd /var/www/sports-platform
          git pull origin main
          docker-compose build
          docker-compose up -d
```

---

## Phase 7: Testing Strategy

### 7.1 Backend Testing

```python
# tests/test_ai_processor.py
import unittest
import tempfile
import cv2
import numpy as np
from ai_processor import VideoAnalyzer

class TestVideoAnalyzer(unittest.TestCase):
    def setUp(self):
        self.analyzer = VideoAnalyzer()
        self.test_video_path = self.create_test_video()
    
    def create_test_video(self):
        """Create a synthetic test video for testing"""
        # Create temporary video file
        temp_file = tempfile.NamedTemporaryFile(suffix='.mp4', delete=False)
        
        # Create video writer
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        out = cv2.VideoWriter(temp_file.name, fourcc, 30.0, (640, 480))
        
        # Generate frames with simulated jump motion
        for i in range(90):  # 3 seconds at 30fps
            frame = np.zeros((480, 640, 3), dtype=np.uint8)
            
            # Simulate person jumping (simple rectangle)
            if i < 30:  # Standing
                y_pos = 400
            elif i < 60:  # Jumping
                y_pos = 400 - (i - 30) * 5  # Going up
            else:  # Landing
                y_pos = 250 + (i - 60) * 5  # Coming down
            
            cv2.rectangle(frame, (300, y_pos), (340, y_pos + 60), (255, 255, 255), -1)
            out.write(frame)
        
        out.release()
        return temp_file.name
    
    def test_vertical_jump_analysis(self):
        """Test vertical jump analysis"""
        result = self.analyzer.analyze_vertical_jump(self.test_video_path)
        
        self.assertIn('jump_height', result)
        self.assertIn('confidence', result)
        self.assertIn('analysis_data', result)
        self.assertGreater(result['jump_height'], 0)
        self.assertGreaterEqual(result['confidence'], 0.5)

# tests/test_api.py
from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from django.contrib.auth.models import User
from .models import UserProfile, TestCategory, AssessmentSession

class TestRecordingAPI(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user_profile = UserProfile.objects.create(
            auth_user_id='test-user-id',
            full_name='Test User',
            gender='male'
        )
        self.test_category = TestCategory.objects.create(
            name='Vertical Jump',