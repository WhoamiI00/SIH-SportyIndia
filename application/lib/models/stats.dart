class AthleteStats {
  final List<PersonalBestScore> personalBestScores;
  final List<AssessmentHistory> assessmentHistory;
  final int badgesEarned;
  final int currentLevel;
  final int totalPoints;
  final List<RankImprovement> rankImprovements;

  AthleteStats({
    required this.personalBestScores,
    required this.assessmentHistory,
    required this.badgesEarned,
    required this.currentLevel,
    required this.totalPoints,
    required this.rankImprovements,
  });

  factory AthleteStats.fromJson(Map<String, dynamic> json) {
    return AthleteStats(
      personalBestScores: (json['personal_best_scores'] as List)
          .map((e) => PersonalBestScore.fromJson(e))
          .toList(),
      assessmentHistory: (json['assessment_history'] as List)
          .map((e) => AssessmentHistory.fromJson(e))
          .toList(),
      badgesEarned: json['badges_earned'] ?? 0,
      currentLevel: json['current_level'] ?? 1,
      totalPoints: json['total_points'] ?? 0,
      rankImprovements: (json['rank_improvements'] as List)
          .map((e) => RankImprovement.fromJson(e))
          .toList(),
    );
  }
}

class PersonalBestScore {
  final String testName;
  final double bestScore;

  PersonalBestScore({required this.testName, required this.bestScore});

  factory PersonalBestScore.fromJson(Map<String, dynamic> json) {
    return PersonalBestScore(
      testName: json['fitness_test__display_name'],
      bestScore: double.parse(json['best_score'].toString()),
    );
  }
}

class AssessmentHistory {
  final DateTime createdAt;
  final double? overallScore;
  final String? overallGrade;

  AssessmentHistory({
    required this.createdAt,
    this.overallScore,
    this.overallGrade,
  });

  factory AssessmentHistory.fromJson(Map<String, dynamic> json) {
    return AssessmentHistory(
      createdAt: DateTime.parse(json['created_at']),
      overallScore: json['overall_score'] != null 
          ? double.parse(json['overall_score'].toString()) 
          : null,
      overallGrade: json['overall_grade'],
    );
  }
}

class RankImprovement {
  final String testName;
  final int improvement;
  final int currentRank;
  final int previousRank;

  RankImprovement({
    required this.testName,
    required this.improvement,
    required this.currentRank,
    required this.previousRank,
  });

  factory RankImprovement.fromJson(Map<String, dynamic> json) {
    return RankImprovement(
      testName: json['test_name'],
      improvement: json['improvement'],
      currentRank: json['current_rank'],
      previousRank: json['previous_rank'],
    );
  }
}