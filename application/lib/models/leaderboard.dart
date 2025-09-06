class LeaderboardEntry {
  final String athleteId;
  final String leaderboardType;
  final int? fitnessTestId;
  final int currentRank;
  final int? previousRank;
  final int totalParticipants;
  final double bestScore;
  final int totalPoints;
  final String? ageGroup;
  final String? gender;
  final String? state;
  final String? district;
  final DateTime updatedAt;
  final String? athleteName;
  final String? athleteState;
  final String? athleteDistrict;
  final String? fitnessTestName;
  final int rankChange;

  LeaderboardEntry({
    required this.athleteId,
    required this.leaderboardType,
    this.fitnessTestId,
    required this.currentRank,
    this.previousRank,
    required this.totalParticipants,
    required this.bestScore,
    required this.totalPoints,
    this.ageGroup,
    this.gender,
    this.state,
    this.district,
    required this.updatedAt,
    this.athleteName,
    this.athleteState,
    this.athleteDistrict,
    this.fitnessTestName,
    required this.rankChange,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      athleteId: json['athlete'],
      leaderboardType: json['leaderboard_type'],
      fitnessTestId: json['fitness_test'],
      currentRank: json['current_rank'],
      previousRank: json['previous_rank'],
      totalParticipants: json['total_participants'],
      bestScore: double.parse(json['best_score'].toString()),
      totalPoints: json['total_points'],
      ageGroup: json['age_group'],
      gender: json['gender'],
      state: json['state'],
      district: json['district'],
      updatedAt: DateTime.parse(json['updated_at']),
      athleteName: json['athlete_name'],
      athleteState: json['athlete_state'],
      athleteDistrict: json['athlete_district'],
      fitnessTestName: json['fitness_test_name'],
      rankChange: json['rank_change'] ?? 0,
    );
  }
}