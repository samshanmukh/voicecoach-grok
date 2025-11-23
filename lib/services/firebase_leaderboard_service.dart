import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard_models.dart';

/// Firebase service for leaderboard operations
class FirebaseLeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _userIdKey = 'anonymous_user_id';

  /// Get or create anonymous user ID
  Future<String> getOrCreateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);

    if (userId == null) {
      // Generate anonymous user ID
      userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_userIdKey, userId);
    }

    return userId;
  }

  /// Get current user profile
  Future<UserProfile?> getUserProfile() async {
    try {
      final userId = await getOrCreateUserId();
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return UserProfile.fromFirestore(doc.data()!, doc.id);
      }

      // Create new user profile
      final newProfile = UserProfile(
        userId: userId,
        username: 'Athlete ${userId.substring(userId.length - 4)}',
        streak: 0,
        totalWorkouts: 0,
        totalExercises: 0,
        lastWorkout: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .set(newProfile.toFirestore());

      return newProfile;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile after workout completion
  Future<void> updateWorkoutStats({
    required int exercisesCompleted,
  }) async {
    try {
      final userId = await getOrCreateUserId();
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);

        if (!snapshot.exists) {
          // Create new user
          final newProfile = UserProfile(
            userId: userId,
            username: 'Athlete ${userId.substring(userId.length - 4)}',
            streak: 1,
            totalWorkouts: 1,
            totalExercises: exercisesCompleted,
            lastWorkout: DateTime.now(),
            createdAt: DateTime.now(),
          );
          transaction.set(userRef, newProfile.toFirestore());
        } else {
          // Update existing user
          final data = snapshot.data()!;
          final lastWorkout = data['lastWorkout'] != null
              ? DateTime.parse(data['lastWorkout'] as String)
              : DateTime.now();

          // Calculate streak
          final daysSinceLastWorkout =
              DateTime.now().difference(lastWorkout).inDays;
          int newStreak = data['streak'] as int? ?? 0;

          if (daysSinceLastWorkout == 0) {
            // Same day - keep streak
          } else if (daysSinceLastWorkout == 1) {
            // Next day - increment streak
            newStreak++;
          } else {
            // Streak broken - reset to 1
            newStreak = 1;
          }

          transaction.update(userRef, {
            'totalWorkouts': FieldValue.increment(1),
            'totalExercises': FieldValue.increment(exercisesCompleted),
            'streak': newStreak,
            'lastWorkout': DateTime.now().toIso8601String(),
          });
        }
      });
    } catch (e) {
      print('Error updating workout stats: $e');
    }
  }

  /// Get top leaderboard entries
  Stream<List<LeaderboardEntry>> getLeaderboard({int limit = 100}) {
    return _firestore
        .collection('users')
        .orderBy('streak', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final entries = snapshot.docs.map((doc) {
        return LeaderboardEntry.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Assign ranks
      for (int i = 0; i < entries.length; i++) {
        entries[i] = entries[i].copyWith(rank: i + 1);
      }

      return entries;
    });
  }

  /// Get user's rank
  Future<int> getUserRank() async {
    try {
      final userId = await getOrCreateUserId();
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) return 0;

      final userStreak = userDoc.data()?['streak'] as int? ?? 0;

      // Count users with higher streak
      final higherStreakCount = await _firestore
          .collection('users')
          .where('streak', isGreaterThan: userStreak)
          .count()
          .get();

      return (higherStreakCount.count ?? 0) + 1;
    } catch (e) {
      print('Error getting user rank: $e');
      return 0;
    }
  }

  /// Update username
  Future<void> updateUsername(String newUsername) async {
    try {
      final userId = await getOrCreateUserId();
      await _firestore.collection('users').doc(userId).update({
        'username': newUsername,
      });
    } catch (e) {
      print('Error updating username: $e');
    }
  }

  /// Get username
  Future<String> getUsername() async {
    try {
      final userId = await getOrCreateUserId();
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return doc.data()?['username'] as String? ??
            'Athlete ${userId.substring(userId.length - 4)}';
      }

      return 'Athlete ${userId.substring(userId.length - 4)}';
    } catch (e) {
      print('Error getting username: $e');
      return 'Anonymous';
    }
  }
}
