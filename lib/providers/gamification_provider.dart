import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gamification_models.dart';

/// Manages achievements, badges, and gamification
class GamificationProvider extends ChangeNotifier {
  UserAchievements _userAchievements = UserAchievements.initial();
  List<Achievement> _recentlyUnlocked = [];

  static const String _achievementsKey = 'user_achievements';

  UserAchievements get userAchievements => _userAchievements;
  List<Achievement> get recentlyUnlocked => _recentlyUnlocked;
  List<Achievement> get unlockedAchievements => _userAchievements.unlocked;
  List<Achievement> get lockedAchievements => _userAchievements.locked;
  int get totalUnlocked => _userAchievements.totalUnlocked;
  int get totalAchievements => _userAchievements.totalAchievements;
  double get completionPercent => _userAchievements.completionPercent;

  GamificationProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadAchievements();
  }

  /// Load achievements from storage
  Future<void> _loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = prefs.getString(_achievementsKey);

      if (achievementsJson != null) {
        final data = jsonDecode(achievementsJson);
        _userAchievements = UserAchievements.fromJson(data);
      }

      notifyListeners();
    } catch (e) {
      print('Error loading achievements: $e');
    }
  }

  /// Save achievements to storage
  Future<void> _saveAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = jsonEncode(_userAchievements.toJson());
      await prefs.setString(_achievementsKey, achievementsJson);
    } catch (e) {
      print('Error saving achievements: $e');
    }
  }

  /// Check and update achievements based on stats
  Future<List<Achievement>> checkAchievements({
    required int totalWorkouts,
    required int totalExercises,
    required int currentStreak,
    int? leaderboardRank,
  }) async {
    final newlyUnlocked = <Achievement>[];

    // Check all achievements
    for (final achievement in Achievements.all) {
      final userAchievement = _userAchievements.achievements[achievement.id];
      if (userAchievement == null || userAchievement.isUnlocked) continue;

      int progress = 0;
      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.workout:
          progress = totalWorkouts;
          shouldUnlock = totalWorkouts >= achievement.requiredValue;
          break;

        case AchievementType.exercise:
          progress = totalExercises;
          shouldUnlock = totalExercises >= achievement.requiredValue;
          break;

        case AchievementType.streak:
          progress = currentStreak;
          shouldUnlock = currentStreak >= achievement.requiredValue;
          break;

        case AchievementType.leaderboard:
          if (leaderboardRank != null && leaderboardRank > 0) {
            progress = 101 - leaderboardRank; // Invert for progress
            shouldUnlock = leaderboardRank <= achievement.requiredValue;
          }
          break;

        case AchievementType.special:
          // Handle special achievements separately
          break;
      }

      // Update progress
      final updatedAchievement = userAchievement.copyWith(
        progress: progress,
        unlockedAt: shouldUnlock ? DateTime.now() : null,
      );

      _userAchievements.achievements[achievement.id] = updatedAchievement;

      if (shouldUnlock && !userAchievement.isUnlocked) {
        newlyUnlocked.add(updatedAchievement);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      _recentlyUnlocked = newlyUnlocked;
      await _saveAchievements();
      notifyListeners();
    }

    return newlyUnlocked;
  }

  /// Clear recently unlocked (after showing celebration)
  void clearRecentlyUnlocked() {
    _recentlyUnlocked = [];
    notifyListeners();
  }

  /// Get achievement by ID
  Achievement? getAchievement(String id) {
    return _userAchievements.achievements[id];
  }

  /// Get achievements by type
  List<Achievement> getAchievementsByType(AchievementType type) {
    return _userAchievements.achievements.values
        .where((a) => a.type == type)
        .toList()
      ..sort((a, b) => a.requiredValue.compareTo(b.requiredValue));
  }

  /// Get next achievement to unlock
  Achievement? getNextAchievement() {
    final locked = _userAchievements.locked;
    if (locked.isEmpty) return null;

    // Return the one closest to completion
    locked.sort((a, b) => b.progressPercent.compareTo(a.progressPercent));
    return locked.first;
  }

  /// Reset all achievements (for testing)
  Future<void> resetAchievements() async {
    _userAchievements = UserAchievements.initial();
    _recentlyUnlocked = [];
    await _saveAchievements();
    notifyListeners();
  }
}
