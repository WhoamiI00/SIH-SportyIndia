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