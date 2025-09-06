// lib/screens/assessment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:async';
import '../providers/assessment_provider.dart';
import '../models/fitness_test.dart';
import '../models/assessment_session.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTestIndex = 0;
  bool _isRecording = false;
  bool _isProcessing = false;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  File? _recordedVideo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
      if (assessmentProvider.fitnessTests.isEmpty) {
        assessmentProvider.loadFitnessTests();
      }
      if (assessmentProvider.currentSession == null) {
        assessmentProvider.loadAssessmentSessions();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
    });

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds++;
      });
    });

    // TODO: Implement actual video recording
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video recording started (simulated)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
    });

    // TODO: Implement actual video recording stop and get file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video recording stopped (simulated)'),
        backgroundColor: Colors.orange,
      ),
    );
    
    // Simulate video file creation
    // _recordedVideo = File('path/to/recorded/video.mp4');
  }

  Future<void> _submitTest() async {
    if (_recordedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please record a video first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
    final currentTest = assessmentProvider.fitnessTests[_currentTestIndex];

    setState(() {
      _isProcessing = true;
    });

    // Simulate device analysis
    final mockDeviceAnalysis = {
      'detected_reps': 15,
      'form_score': 85.5,
      'timing_accuracy': 92.3,
      'body_posture_score': 88.0,
    };

    final success = await assessmentProvider.uploadVideo(
      currentTest.id,
      _recordedVideo!,
      deviceAnalysisScore: 85.5,
      deviceAnalysisConfidence: 0.92,
      deviceAnalysisData: mockDeviceAnalysis,
    );

    setState(() {
      _isProcessing = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Move to next test or completion
      if (_currentTestIndex < assessmentProvider.fitnessTests.length - 1) {
        setState(() {
          _currentTestIndex++;
          _recordedVideo = null;
        });
      } else {
        _showAssessmentComplete();
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(assessmentProvider.errorMessage ?? 'Failed to submit test'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAssessmentComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Assessment Complete!'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Congratulations! You have completed all fitness tests.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Your results will be processed and submitted to SAI for evaluation.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Assessment'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.fitness_center), text: 'Current Test'),
            Tab(icon: Icon(Icons.list), text: 'Progress'),
          ],
        ),
      ),
      body: Consumer<AssessmentProvider>(
        builder: (context, assessmentProvider, child) {
          if (assessmentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (assessmentProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${assessmentProvider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      assessmentProvider.loadFitnessTests();
                      assessmentProvider.loadAssessmentSessions();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (assessmentProvider.fitnessTests.isEmpty) {
            return const Center(
              child: Text('No fitness tests available'),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCurrentTestTab(assessmentProvider),
              _buildProgressTab(assessmentProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentTestTab(AssessmentProvider assessmentProvider) {
    if (_currentTestIndex >= assessmentProvider.fitnessTests.length) {
      return const Center(
        child: Text('All tests completed!'),
      );
    }

    final currentTest = assessmentProvider.fitnessTests[_currentTestIndex];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Test Progress Indicator
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test ${_currentTestIndex + 1} of ${assessmentProvider.fitnessTests.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentTestIndex + 1) / assessmentProvider.fitnessTests.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Current Test Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentTest.displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentTest.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        currentTest.durationSeconds != null
                            ? 'Duration: ${_formatTime(currentTest.durationSeconds!)}'
                            : 'No time limit',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.straighten, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Unit: ${currentTest.measurementUnit}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Instructions Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentTest.instructions,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  if (currentTest.videoDemoUrl != null) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement video demo playback
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Video demo feature coming soon!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_circle),
                      label: const Text('Watch Demo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recording Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Record Your Performance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Camera Preview Area
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _isRecording
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.videocam,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Recording: ${_formatTime(_recordingSeconds)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.video_camera_front,
                                size: 48,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _recordedVideo != null 
                                    ? 'Video recorded successfully!'
                                    : 'Camera preview will appear here',
                                style: TextStyle(
                                  color: _recordedVideo != null ? Colors.green : Colors.grey[600],
                                  fontWeight: _recordedVideo != null ? FontWeight.bold : null,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Recording Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!_isRecording && _recordedVideo == null)
                        ElevatedButton.icon(
                          onPressed: _startRecording,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Recording'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        )
                      else if (_isRecording)
                        ElevatedButton.icon(
                          onPressed: _stopRecording,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop Recording'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        )
                      else ...[
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _recordedVideo = null;
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Record Again'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _submitTest,
                          icon: _isProcessing 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.upload),
                          label: Text(_isProcessing ? 'Processing...' : 'Submit Test'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tips Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recording Tips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Ensure good lighting and clear camera view\n'
                    '• Position camera to capture your full body\n'
                    '• Maintain steady phone position during recording\n'
                    '• Follow the exercise form as demonstrated\n'
                    '• Complete the full duration or repetitions',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab(AssessmentProvider assessmentProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Progress Card
          if (assessmentProvider.currentSession != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assessment Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: assessmentProvider.currentSession!.progressPercentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${assessmentProvider.currentSession!.completedTests}/${assessmentProvider.currentSession!.totalTests} tests completed '
                      '(${assessmentProvider.currentSession!.progressPercentage.toStringAsFixed(1)}%)',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Started: ${assessmentProvider.currentSession!.createdAt.toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Test List
          const Text(
            'All Fitness Tests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          ...assessmentProvider.fitnessTests.asMap().entries.map((entry) {
            final index = entry.key;
            final test = entry.value;
            final isCompleted = index < _currentTestIndex;
            final isCurrent = index == _currentTestIndex;
            final isUpcoming = index > _currentTestIndex;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isCompleted 
                      ? Colors.green 
                      : isCurrent 
                          ? Colors.orange 
                          : Colors.grey[300],
                  child: Icon(
                    isCompleted 
                        ? Icons.check 
                        : isCurrent 
                            ? Icons.play_arrow 
                            : Icons.fitness_center,
                    color: isUpcoming ? Colors.grey[600] : Colors.white,
                  ),
                ),
                title: Text(
                  test.displayName,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isUpcoming ? Colors.grey[600] : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.description,
                      style: TextStyle(
                        color: isUpcoming ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted 
                          ? 'Completed' 
                          : isCurrent 
                              ? 'In Progress' 
                              : 'Upcoming',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCompleted 
                            ? Colors.green 
                            : isCurrent 
                                ? Colors.orange 
                                : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                trailing: isCompleted 
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : isCurrent 
                        ? const Icon(Icons.radio_button_checked, color: Colors.orange)
                        : Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
                onTap: isCurrent 
                    ? () {
                        _tabController.animateTo(0);
                      } 
                    : null,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}