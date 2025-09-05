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