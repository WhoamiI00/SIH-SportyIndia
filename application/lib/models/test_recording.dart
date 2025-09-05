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

