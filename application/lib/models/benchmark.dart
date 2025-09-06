class AgeBenchmark {
  final int id;
  final int fitnessTestId;
  final int ageMin;
  final int ageMax;
  final String gender;
  final double excellentThreshold;
  final double goodThreshold;
  final double averageThreshold;
  final double belowAverageThreshold;
  final int excellentPoints;
  final int goodPoints;
  final int averagePoints;
  final int belowAveragePoints;
  final DateTime createdAt;
  final String? fitnessTestName;

  AgeBenchmark({
    required this.id,
    required this.fitnessTestId,
    required this.ageMin,
    required this.ageMax,
    required this.gender,
    required this.excellentThreshold,
    required this.goodThreshold,
    required this.averageThreshold,
    required this.belowAverageThreshold,
    required this.excellentPoints,
    required this.goodPoints,
    required this.averagePoints,
    required this.belowAveragePoints,
    required this.createdAt,
    this.fitnessTestName,
  });

  factory AgeBenchmark.fromJson(Map<String, dynamic> json) {
    return AgeBenchmark(
      id: json['id'],
      fitnessTestId: json['fitness_test'],
      ageMin: json['age_min'],
      ageMax: json['age_max'],
      gender: json['gender'],
      excellentThreshold: double.parse(json['excellent_threshold'].toString()),
      goodThreshold: double.parse(json['good_threshold'].toString()),
      averageThreshold: double.parse(json['average_threshold'].toString()),
      belowAverageThreshold: double.parse(json['below_average_threshold'].toString()),
      excellentPoints: json['excellent_points'] ?? 100,
      goodPoints: json['good_points'] ?? 80,
      averagePoints: json['average_points'] ?? 60,
      belowAveragePoints: json['below_average_points'] ?? 40,
      createdAt: DateTime.parse(json['created_at']),
      fitnessTestName: json['fitness_test_name'],
    );
  }
}