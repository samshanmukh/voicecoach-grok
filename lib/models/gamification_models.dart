import 'dart:convert';

/// Achievement/Badge model
class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int requiredValue;
  final AchievementType type;
  final DateTime? unlockedAt;
  final int progress;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.requiredValue,
    required this.type,
    this.unlockedAt,
    this.progress = 0,
  });

  bool get isUnlocked => unlockedAt != null;
  double get progressPercent => requiredValue > 0 ? progress / requiredValue : 0.0;

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    int? requiredValue,
    AchievementType? type,
    DateTime? unlockedAt,
    int? progress,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      requiredValue: requiredValue ?? this.requiredValue,
      type: type ?? this.type,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'requiredValue': requiredValue,
      'type': type.toString(),
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      requiredValue: json['requiredValue'] as int,
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AchievementType.workout,
      ),
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      progress: json['progress'] as int? ?? 0,
    );
  }
}

enum AchievementType {
  workout,    // Total workouts completed
  streak,     // Consecutive days
  exercise,   // Total exercises
  leaderboard, // Leaderboard rank
  special,    // Special events
}

/// Predefined achievements
class Achievements {
  static final List<Achievement> all = [
    // Workout milestones
    Achievement(
      id: 'first_workout',
      name: 'First Steps',
      description: 'Complete your first workout',
      iconName: 'fitness_center',
      requiredValue: 1,
      type: AchievementType.workout,
    ),
    Achievement(
      id: 'workout_10',
      name: 'Getting Started',
      description: 'Complete 10 workouts',
      iconName: 'trending_up',
      requiredValue: 10,
      type: AchievementType.workout,
    ),
    Achievement(
      id: 'workout_25',
      name: 'Quarter Century',
      description: 'Complete 25 workouts',
      iconName: 'star',
      requiredValue: 25,
      type: AchievementType.workout,
    ),
    Achievement(
      id: 'workout_50',
      name: 'Half Century',
      description: 'Complete 50 workouts',
      iconName: 'military_tech',
      requiredValue: 50,
      type: AchievementType.workout,
    ),
    Achievement(
      id: 'workout_100',
      name: 'Century Club',
      description: 'Complete 100 workouts',
      iconName: 'emoji_events',
      requiredValue: 100,
      type: AchievementType.workout,
    ),

    // Streak achievements
    Achievement(
      id: 'streak_3',
      name: 'On Fire',
      description: 'Maintain a 3-day streak',
      iconName: 'local_fire_department',
      requiredValue: 3,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_7',
      name: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      iconName: 'whatshot',
      requiredValue: 7,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_30',
      name: 'Month Master',
      description: 'Maintain a 30-day streak',
      iconName: 'diamond',
      requiredValue: 30,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_100',
      name: 'Unstoppable',
      description: 'Maintain a 100-day streak',
      iconName: 'workspace_premium',
      requiredValue: 100,
      type: AchievementType.streak,
    ),

    // Exercise achievements
    Achievement(
      id: 'exercise_100',
      name: 'Hundred Reps',
      description: 'Complete 100 exercises',
      iconName: 'fitness_center',
      requiredValue: 100,
      type: AchievementType.exercise,
    ),
    Achievement(
      id: 'exercise_500',
      name: 'Rep Master',
      description: 'Complete 500 exercises',
      iconName: 'sports_gymnastics',
      requiredValue: 500,
      type: AchievementType.exercise,
    ),
    Achievement(
      id: 'exercise_1000',
      name: 'Thousand Strong',
      description: 'Complete 1000 exercises',
      iconName: 'self_improvement',
      requiredValue: 1000,
      type: AchievementType.exercise,
    ),

    // Leaderboard achievements
    Achievement(
      id: 'top_100',
      name: 'Top Hundred',
      description: 'Reach top 100 on leaderboard',
      iconName: 'leaderboard',
      requiredValue: 100,
      type: AchievementType.leaderboard,
    ),
    Achievement(
      id: 'top_10',
      name: 'Elite Ten',
      description: 'Reach top 10 on leaderboard',
      iconName: 'military_tech',
      requiredValue: 10,
      type: AchievementType.leaderboard,
    ),
    Achievement(
      id: 'top_3',
      name: 'Podium Finish',
      description: 'Reach top 3 on leaderboard',
      iconName: 'emoji_events',
      requiredValue: 3,
      type: AchievementType.leaderboard,
    ),
    Achievement(
      id: 'rank_1',
      name: 'Champion',
      description: 'Reach #1 on leaderboard',
      iconName: 'emoji_events',
      requiredValue: 1,
      type: AchievementType.leaderboard,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// User's achievement progress
class UserAchievements {
  final Map<String, Achievement> achievements;
  final DateTime lastUpdated;

  UserAchievements({
    required this.achievements,
    required this.lastUpdated,
  });

  List<Achievement> get unlocked =>
      achievements.values.where((a) => a.isUnlocked).toList()
        ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));

  List<Achievement> get locked =>
      achievements.values.where((a) => !a.isUnlocked).toList()
        ..sort((a, b) => b.progressPercent.compareTo(a.progressPercent));

  int get totalUnlocked => unlocked.length;
  int get totalAchievements => achievements.length;
  double get completionPercent => totalAchievements > 0
      ? totalUnlocked / totalAchievements
      : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'achievements': achievements.map((key, value) => MapEntry(key, value.toJson())),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UserAchievements.fromJson(Map<String, dynamic> json) {
    return UserAchievements(
      achievements: (json['achievements'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          Achievement.fromJson(value as Map<String, dynamic>),
        ),
      ),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  factory UserAchievements.initial() {
    final achievementMap = <String, Achievement>{};
    for (final achievement in Achievements.all) {
      achievementMap[achievement.id] = achievement;
    }
    return UserAchievements(
      achievements: achievementMap,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Daily challenge
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  final ChallengeType type;
  final DateTime date;
  final int progress;
  final bool isCompleted;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.type,
    required this.date,
    this.progress = 0,
    this.isCompleted = false,
  });

  double get progressPercent => targetValue > 0 ? progress / targetValue : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'type': type.toString(),
      'date': date.toIso8601String(),
      'progress': progress,
      'isCompleted': isCompleted,
    };
  }

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetValue: json['targetValue'] as int,
      type: ChallengeType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ChallengeType.workout,
      ),
      date: DateTime.parse(json['date'] as String),
      progress: json['progress'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

enum ChallengeType {
  workout,
  exercises,
  duration,
}
