import 'dart:convert';

/// User entry on the leaderboard
class LeaderboardEntry {
  final String userId;
  final String username;
  final int streak;
  final int totalWorkouts;
  final int totalExercises;
  final int rank;
  final DateTime lastWorkout;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.streak,
    required this.totalWorkouts,
    required this.totalExercises,
    required this.rank,
    required this.lastWorkout,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'streak': streak,
      'totalWorkouts': totalWorkouts,
      'totalExercises': totalExercises,
      'rank': rank,
      'lastWorkout': lastWorkout.toIso8601String(),
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      username: json['username'] as String,
      streak: json['streak'] as int? ?? 0,
      totalWorkouts: json['totalWorkouts'] as int? ?? 0,
      totalExercises: json['totalExercises'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      lastWorkout: DateTime.parse(json['lastWorkout'] as String),
    );
  }

  factory LeaderboardEntry.fromFirestore(Map<String, dynamic> data, String id) {
    return LeaderboardEntry(
      userId: id,
      username: data['username'] as String? ?? 'Anonymous',
      streak: data['streak'] as int? ?? 0,
      totalWorkouts: data['totalWorkouts'] as int? ?? 0,
      totalExercises: data['totalExercises'] as int? ?? 0,
      rank: 0, // Will be calculated
      lastWorkout: data['lastWorkout'] != null
          ? DateTime.parse(data['lastWorkout'] as String)
          : DateTime.now(),
    );
  }

  LeaderboardEntry copyWith({
    String? userId,
    String? username,
    int? streak,
    int? totalWorkouts,
    int? totalExercises,
    int? rank,
    DateTime? lastWorkout,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      streak: streak ?? this.streak,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalExercises: totalExercises ?? this.totalExercises,
      rank: rank ?? this.rank,
      lastWorkout: lastWorkout ?? this.lastWorkout,
    );
  }
}

/// User profile for leaderboard
class UserProfile {
  final String userId;
  final String username;
  final int streak;
  final int totalWorkouts;
  final int totalExercises;
  final DateTime lastWorkout;
  final DateTime createdAt;

  UserProfile({
    required this.userId,
    required this.username,
    required this.streak,
    required this.totalWorkouts,
    required this.totalExercises,
    required this.lastWorkout,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'streak': streak,
      'totalWorkouts': totalWorkouts,
      'totalExercises': totalExercises,
      'lastWorkout': lastWorkout.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String id) {
    return UserProfile(
      userId: id,
      username: data['username'] as String? ?? 'Anonymous',
      streak: data['streak'] as int? ?? 0,
      totalWorkouts: data['totalWorkouts'] as int? ?? 0,
      totalExercises: data['totalExercises'] as int? ?? 0,
      lastWorkout: data['lastWorkout'] != null
          ? DateTime.parse(data['lastWorkout'] as String)
          : DateTime.now(),
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? userId,
    String? username,
    int? streak,
    int? totalWorkouts,
    int? totalExercises,
    DateTime? lastWorkout,
    DateTime? createdAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      streak: streak ?? this.streak,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalExercises: totalExercises ?? this.totalExercises,
      lastWorkout: lastWorkout ?? this.lastWorkout,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
