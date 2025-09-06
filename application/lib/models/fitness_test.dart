class FitnessTest {
  final int id;
  final String name;
  final String displayName;
  final String description;
  final String instructions;
  final String? videoDemoUrl;
  final int? durationSeconds;
  final bool requiresVideo;
  final String measurementUnit;
  final Map<String, dynamic> aiModelConfig;
  final bool cheatDetectionEnabled;
  final bool isActive;
  final DateTime createdAt;

  FitnessTest({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.instructions,
    this.videoDemoUrl,
    this.durationSeconds,
    required this.requiresVideo,
    required this.measurementUnit,
    required this.aiModelConfig,
    required this.cheatDetectionEnabled,
    required this.isActive,
    required this.createdAt,
  });

  factory FitnessTest.fromJson(Map<String, dynamic> json) {
    return FitnessTest(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'],
      description: json['description'],
      instructions: json['instructions'],
      videoDemoUrl: json['video_demo_url'],
      durationSeconds: json['duration_seconds'],
      requiresVideo: json['requires_video'] ?? true,
      measurementUnit: json['measurement_unit'],
      aiModelConfig: Map<String, dynamic>.from(json['ai_model_config'] ?? {}),
      cheatDetectionEnabled: json['cheat_detection_enabled'] ?? true,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}