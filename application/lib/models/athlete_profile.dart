class AthleteProfile {
  final String id;
  final String authUserId;
  final String fullName;
  final DateTime dateOfBirth;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String phoneNumber;
  final String? email;
  final String address;
  final String state;
  final String district;
  final String pinCode;
  final String locationCategory;
  final String aadhaarNumber;
  final List<String> sportsInterests;
  final String? previousSportsExperience;
  final String? profilePictureUrl;
  final bool isVerified;
  final String verificationStatus;
  final double? overallTalentScore;
  final String? talentGrade;
  final int? nationalRanking;
  final int? stateRanking;
  final int totalPoints;
  final List<String> badgesEarned;
  final int level;
  final DateTime createdAt;
  final DateTime updatedAt;

  AthleteProfile({
    required this.id,
    required this.authUserId,
    required this.fullName,
    required this.dateOfBirth,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.phoneNumber,
    this.email,
    required this.address,
    required this.state,
    required this.district,
    required this.pinCode,
    required this.locationCategory,
    required this.aadhaarNumber,
    required this.sportsInterests,
    this.previousSportsExperience,
    this.profilePictureUrl,
    required this.isVerified,
    required this.verificationStatus,
    this.overallTalentScore,
    this.talentGrade,
    this.nationalRanking,
    this.stateRanking,
    required this.totalPoints,
    required this.badgesEarned,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AthleteProfile.fromJson(Map<String, dynamic> json) {
    return AthleteProfile(
      id: json['id'],
      authUserId: json['auth_user_id'],
      fullName: json['full_name'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      age: json['age'],
      gender: json['gender'],
      height: double.parse(json['height'].toString()),
      weight: double.parse(json['weight'].toString()),
      phoneNumber: json['phone_number'],
      email: json['email'],
      address: json['address'],
      state: json['state'],
      district: json['district'],
      pinCode: json['pin_code'],
      locationCategory: json['location_category'],
      aadhaarNumber: json['aadhaar_number'],
      sportsInterests: List<String>.from(json['sports_interests'] ?? []),
      previousSportsExperience: json['previous_sports_experience'],
      profilePictureUrl: json['profile_picture_url'],
      isVerified: json['is_verified'] ?? false,
      verificationStatus: json['verification_status'] ?? 'pending',
      overallTalentScore: json['overall_talent_score'] != null 
          ? double.parse(json['overall_talent_score'].toString()) 
          : null,
      talentGrade: json['talent_grade'],
      nationalRanking: json['national_ranking'],
      stateRanking: json['state_ranking'],
      totalPoints: json['total_points'] ?? 0,
      badgesEarned: List<String>.from(json['badges_earned'] ?? []),
      level: json['level'] ?? 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auth_user_id': authUserId,
      'full_name': fullName,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'state': state,
      'district': district,
      'pin_code': pinCode,
      'location_category': locationCategory,
      'aadhaar_number': aadhaarNumber,
      'sports_interests': sportsInterests,
      'previous_sports_experience': previousSportsExperience,
      'profile_picture_url': profilePictureUrl,
      'is_verified': isVerified,
      'verification_status': verificationStatus,
      'overall_talent_score': overallTalentScore,
      'talent_grade': talentGrade,
      'national_ranking': nationalRanking,
      'state_ranking': stateRanking,
      'total_points': totalPoints,
      'badges_earned': badgesEarned,
      'level': level,
    };
  }
}