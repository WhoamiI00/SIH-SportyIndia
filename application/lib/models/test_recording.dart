class TestRecording {
  final String id;
  final String sessionId;
  final int fitnessTestId;
  final String athleteId;
  final String originalVideoUrl;
  final String? processedVideoUrl;
  final String? thumbnailUrl;
  final double? videoDuration;
  final double? videoSizeMb;
  final double? deviceAnalysisScore;
  final double? deviceAnalysisConfidence;
  final Map<String, dynamic>? deviceAnalysisData;
  final double? aiRawScore;
  final double? aiConfidence;
  final Map<String, dynamic>? aiAnalysisData;
  final double? cheatDetectionScore;
  final List<String> cheatFlags;
  final bool isSuspicious;
  final double? manualScore;
  final String? verifiedBySaiOfficer;
  final String? verificationNotes;
  final double? finalScore;
  final String? performanceGrade;
  final double? percentile;
  final int? pointsEarned;
  final String processingStatus;
  final String? processingError;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? athleteName;
  final String? testName;

  TestRecording({
    required this.id,
    required this.sessionId,
    required this.fitnessTestId,
    required this.athleteId,
    required this.originalVideoUrl,
    this.processedVideoUrl,
    this.thumbnailUrl,
    this.videoDuration,
    this.videoSizeMb,
    this.deviceAnalysisScore,
    this.deviceAnalysisConfidence,
    this.deviceAnalysisData,
    this.aiRawScore,
    this.aiConfidence,
    this.aiAnalysisData,
    this.cheatDetectionScore,
    required this.cheatFlags,
    required this.isSuspicious,
    this.manualScore,
    this.verifiedBySaiOfficer,
    this.verificationNotes,
    this.finalScore,
    this.performanceGrade,
    this.percentile,
    this.pointsEarned,
    required this.processingStatus,
    this.processingError,
    required this.retryCount,
    required this.createdAt,
    this.processedAt,
    this.athleteName,
    this.testName,
  });

  factory TestRecording.fromJson(Map<String, dynamic> json) {
    return TestRecording(
      id: json['id'],
      sessionId: json['session'],
      fitnessTestId: json['fitness_test'],
      athleteId: json['athlete'],
      originalVideoUrl: json['original_video_url'],
      processedVideoUrl: json['processed_video_url'],
      thumbnailUrl: json['thumbnail_url'],
      videoDuration: json['video_duration'] != null 
          ? double.parse(json['video_duration'].toString()) 
          : null,
      videoSizeMb: json['video_size_mb'] != null 
          ? double.parse(json['video_size_mb'].toString()) 
          : null,
      deviceAnalysisScore: json['device_analysis_score'] != null 
          ? double.parse(json['device_analysis_score'].toString()) 
          : null,
      deviceAnalysisConfidence: json['device_analysis_confidence'] != null 
          ? double.parse(json['device_analysis_confidence'].toString()) 
          : null,
      deviceAnalysisData: json['device_analysis_data'] != null 
          ? Map<String, dynamic>.from(json['device_analysis_data']) 
          : null,
      aiRawScore: json['ai_raw_score'] != null 
          ? double.parse(json['ai_raw_score'].toString()) 
          : null,
      aiConfidence: json['ai_confidence'] != null 
          ? double.parse(json['ai_confidence'].toString()) 
          : null,
      aiAnalysisData: json['ai_analysis_data'] != null 
          ? Map<String, dynamic>.from(json['ai_analysis_data']) 
          : null,
      cheatDetectionScore: json['cheat_detection_score'] != null 
          ? double.parse(json['cheat_detection_score'].toString()) 
          : null,
      cheatFlags: List<String>.from(json['cheat_flags'] ?? []),
      isSuspicious: json['is_suspicious'] ?? false,
      manualScore: json['manual_score'] != null 
          ? double.parse(json['manual_score'].toString()) 
          : null,
      verifiedBySaiOfficer: json['verified_by_sai_officer'],
      verificationNotes: json['verification_notes'],
      finalScore: json['final_score'] != null 
          ? double.parse(json['final_score'].toString()) 
          : null,
      performanceGrade: json['performance_grade'],
      percentile: json['percentile'] != null 
          ? double.parse(json['percentile'].toString()) 
          : null,
      pointsEarned: json['points_earned'],
      processingStatus: json['processing_status'],
      processingError: json['processing_error'],
      retryCount: json['retry_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at']) 
          : null,
      athleteName: json['athlete_name'],
      testName: json['test_name'],
    );
  }
}
