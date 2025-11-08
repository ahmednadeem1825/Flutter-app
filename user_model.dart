// lib/models/app_user.dart
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? profileImage;
  final int credits;
  final bool isActive;
  final DateTime createdAt;

  // Dashboard metrics
  final int weeklyCheckins;
  final double hoursSpent;
  final double payments;

  final List<double> earningsHistory;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.profileImage,
    this.credits = 0,
    this.isActive = true,
    required this.createdAt,
    this.weeklyCheckins = 0,
    this.hoursSpent = 0.0,
    this.payments = 0.0,
    this.earningsHistory = const [], // default empty list
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] as String,
      fullName: data['full_name'] ?? '',
      email: data['email'] ?? '',
      profileImage: data['profile_image'],
      credits: data['credits'] ?? 0,
      isActive: data['is_active'] ?? true,
      createdAt: DateTime.parse(data['created_at']),
      weeklyCheckins: data['weekly_checkins'] ?? 0,
      hoursSpent: (data['hours_spent'] ?? 0).toDouble(),
      payments: (data['payments'] ?? 0).toDouble(),

      earningsHistory: data['earnings_history'] == null
          ? []
          : List<double>.from(data['earnings_history']
              .map((e) => (e as num).toDouble())),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'profile_image': profileImage,
      'credits': credits,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'weekly_checkins': weeklyCheckins,
      'hours_spent': hoursSpent,
      'payments': payments,
      'earnings_history': earningsHistory,
    };
  }
}
