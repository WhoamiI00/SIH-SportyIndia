class Badge {
  final int id;
  final String name;
  final String description;
  final String badgeType;
  final String iconUrl;
  final Map<String, dynamic> criteria;
  final int pointsReward;
  final bool isActive;
  final DateTime createdAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.badgeType,
    required this.iconUrl,
    required this.criteria,
    required this.pointsReward,
    required this.isActive,
    required this.createdAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      badgeType: json['badge_type'],
      iconUrl: json['icon_url'],
      criteria: Map<String, dynamic>.from(json['criteria'] ?? {}),
      pointsReward: json['points_reward'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
