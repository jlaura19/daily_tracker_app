// lib/models/user_stats.dart

class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final DateTime unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.unlockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'unlocked_at': unlockedAt.millisecondsSinceEpoch,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      iconName: map['icon_name'],
      unlockedAt: DateTime.fromMillisecondsSinceEpoch(map['unlocked_at']),
    );
  }
}

class UserStats {
  final int? id;
  final int totalXP;
  final int currentLevel;
  final List<Achievement> achievements;
  final DateTime lastUpdated;

  UserStats({
    this.id = 1, // Single row for user stats
    this.totalXP = 0,
    this.currentLevel = 1,
    this.achievements = const [],
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_xp': totalXP,
      'current_level': currentLevel,
      'achievements': achievements.map((a) => a.toMap()).toList().toString(),
      'last_updated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    // Note: achievements parsing simplified - in production use JSON
    return UserStats(
      id: map['id'],
      totalXP: map['total_xp'] ?? 0,
      currentLevel: map['current_level'] ?? 1,
      achievements: [], // Parse from JSON in production
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['last_updated']),
    );
  }

  // Calculate XP needed for next level
  int get xpForNextLevel {
    return currentLevel * 100;
  }

  // Calculate XP progress to next level
  int get xpProgress {
    return totalXP % 100;
  }

  // Calculate progress percentage
  double get progressPercentage {
    return xpProgress / xpForNextLevel;
  }

  UserStats copyWith({
    int? id,
    int? totalXP,
    int? currentLevel,
    List<Achievement>? achievements,
    DateTime? lastUpdated,
  }) {
    return UserStats(
      id: id ?? this.id,
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      achievements: achievements ?? this.achievements,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
