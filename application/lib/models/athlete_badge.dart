import 'badge.dart';

class AthleteBadge {
  final String athleteId;
  final int badgeId;
  final DateTime earnedAt;
  final String? testRecordingId;
  final String? notes;
  final Badge badgeDetails;

  AthleteBadge({
    required this.athleteId,
    required this.badgeId,
    required this.earnedAt,
    this.testRecordingId,
    this.notes,
    required this.badgeDetails,
  });

  factory AthleteBadge.fromJson(Map<String, dynamic> json) {
    return AthleteBadge(
      athleteId: json['athlete'],
      badgeId: json['badge'],
      earnedAt: DateTime.parse(json['earned_at']),
      testRecordingId: json['test_recording'],
      notes: json['notes'],
      badgeDetails: Badge.fromJson(json['badge_details']),
    );
  }
}