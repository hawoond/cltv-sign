import 'package:uuid/uuid.dart';

enum UserPlan { free, personal, team, teamPro, enterprise }

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? company;
  final String? department;
  final String? position;
  final String? avatarUrl;
  final UserPlan plan;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final UserSettings settings;
  final int documentCount;
  final int signedCount;
  final int monthlyUsage;
  final int monthlyLimit;

  User({
    String? id,
    required this.name,
    required this.email,
    this.phone,
    this.company,
    this.department,
    this.position,
    this.avatarUrl,
    this.plan = UserPlan.free,
    DateTime? createdAt,
    this.lastLoginAt,
    UserSettings? settings,
    this.documentCount = 0,
    this.signedCount = 0,
    this.monthlyUsage = 0,
    this.monthlyLimit = 5,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        settings = settings ?? UserSettings();

  String get planLabel {
    switch (plan) {
      case UserPlan.free: return '무료';
      case UserPlan.personal: return 'Personal';
      case UserPlan.team: return 'Team';
      case UserPlan.teamPro: return 'Team Pro';
      case UserPlan.enterprise: return 'Enterprise';
    }
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  User copyWith({
    String? name,
    String? phone,
    String? company,
    String? department,
    String? position,
    String? avatarUrl,
    UserPlan? plan,
    UserSettings? settings,
    int? documentCount,
    int? signedCount,
    int? monthlyUsage,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      department: department ?? this.department,
      position: position ?? this.position,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      plan: plan ?? this.plan,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      settings: settings ?? this.settings,
      documentCount: documentCount ?? this.documentCount,
      signedCount: signedCount ?? this.signedCount,
      monthlyUsage: monthlyUsage ?? this.monthlyUsage,
      monthlyLimit: monthlyLimit,
    );
  }
}

class UserSettings {
  final bool emailNotification;
  final bool kakaoNotification;
  final bool smsNotification;
  final String language;
  final String timezone;
  final bool twoFactorAuth;
  final bool autoSave;

  UserSettings({
    this.emailNotification = true,
    this.kakaoNotification = false,
    this.smsNotification = false,
    this.language = 'ko',
    this.timezone = 'Asia/Seoul',
    this.twoFactorAuth = false,
    this.autoSave = true,
  });

  UserSettings copyWith({
    bool? emailNotification,
    bool? kakaoNotification,
    bool? smsNotification,
    bool? twoFactorAuth,
    bool? autoSave,
  }) {
    return UserSettings(
      emailNotification: emailNotification ?? this.emailNotification,
      kakaoNotification: kakaoNotification ?? this.kakaoNotification,
      smsNotification: smsNotification ?? this.smsNotification,
      language: language,
      timezone: timezone,
      twoFactorAuth: twoFactorAuth ?? this.twoFactorAuth,
      autoSave: autoSave ?? this.autoSave,
    );
  }
}

class Notification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? documentId;
  final String? actionUrl;

  Notification({
    String? id,
    required this.title,
    required this.message,
    required this.type,
    DateTime? createdAt,
    this.isRead = false,
    this.documentId,
    this.actionUrl,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}

enum NotificationType {
  signRequest,
  signCompleted,
  signRejected,
  documentExpiring,
  documentExpired,
  system,
}
