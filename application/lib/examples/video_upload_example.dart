import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';

class VideoUploadExample extends StatefulWidget {
  const VideoUploadExample({super.key});

  @override
  State<VideoUploadExample> createState() => _VideoUploadExampleState();
}

class _VideoUploadExampleState extends State<VideoUploadExample> {
  File? _selectedVideo;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _uploadResult;

  Future<void> _selectVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      
      if (video != null) {
        setState(() {
          _selectedVideo = File(video.path);
          _uploadResult = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting video: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a video first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadResult = null;
    });

    try {
      final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
      
      // Example: Upload video for vertical jump test (fitness_test_id: 1)
      final success = await assessmentProvider.uploadVideo(
        1, // fitness_test_id for vertical jump
        _selectedVideo!,
        deviceAnalysisScore: 85.5, // Example device analysis score
        deviceAnalysisConfidence: 0.92, // Example confidence level
        deviceAnalysisData: {
          'jump_height': 45.2,
          'hang_time': 0.65,
          'analysis_method': 'computer_vision',
        },
      );

      if (success) {
        setState(() {
          _uploadResult = 'Video uploaded successfully!\nAI analysis in progress...';
        });
        
        // You could poll for analysis results here
        // _pollAnalysisStatus(recordingId);
        
      } else {
        setState(() {
          _uploadResult = 'Upload failed: ${assessmentProvider.errorMessage}';
        });
      }
    } catch (e) {
      setState(() {
        _uploadResult = 'Upload error: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Upload Example'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedVideo != null) ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Video Selected'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            ElevatedButton.icon(
              onPressed: _selectVideo,
              icon: const Icon(Icons.video_library),
              label: const Text('Select Video'),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _selectedVideo != null && !_isUploading ? _uploadVideo : null,
              icon: _isUploading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(_isUploading ? 'Uploading...' : 'Upload Video'),
            ),
            
            const SizedBox(height: 24),
            
            if (_uploadResult != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _uploadResult!.contains('successfully') 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _uploadResult!.contains('successfully') 
                        ? Colors.green 
                        : Colors.red,
                  ),
                ),
                child: Text(
                  _uploadResult!,
                  style: TextStyle(
                    color: _uploadResult!.contains('successfully') 
                        ? Colors.green[800] 
                        : Colors.red[800],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            const Text(
              'Instructions:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Make sure you have an active assessment session\n'
              '2. Select a fitness test video from your gallery\n'
              '3. Upload the video for AI analysis\n'
              '4. The system will process and provide feedback',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
