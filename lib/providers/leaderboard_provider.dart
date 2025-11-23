import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/leaderboard_models.dart';
import '../services/firebase_leaderboard_service.dart';

/// Manages leaderboard data and user profile
class LeaderboardProvider extends ChangeNotifier {
  final FirebaseLeaderboardService _firebaseService =
      FirebaseLeaderboardService();

  List<LeaderboardEntry> _leaderboard = [];
  UserProfile? _userProfile;
  int _userRank = 0;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _leaderboardSubscription;

  List<LeaderboardEntry> get leaderboard => _leaderboard;
  UserProfile? get userProfile => _userProfile;
  int get userRank => _userRank;
  bool get isLoading => _isLoading;
  String? get error => _error;

  LeaderboardProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadUserProfile();
    await startLeaderboardStream();
  }

  /// Load user profile
  Future<void> loadUserProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      _userProfile = await _firebaseService.getUserProfile();
      _userRank = await _firebaseService.getUserRank();
      _error = null;
    } catch (e) {
      _error = 'Failed to load profile: $e';
      print('Error loading user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start listening to leaderboard updates
  Future<void> startLeaderboardStream() async {
    try {
      _leaderboardSubscription?.cancel();
      _leaderboardSubscription = _firebaseService
          .getLeaderboard(limit: 100)
          .listen((entries) {
        _leaderboard = entries;
        _updateUserRank();
        notifyListeners();
      }, onError: (error) {
        _error = 'Failed to load leaderboard: $error';
        print('Leaderboard stream error: $error');
        notifyListeners();
      });
    } catch (e) {
      _error = 'Failed to start leaderboard stream: $e';
      print('Error starting leaderboard stream: $e');
      notifyListeners();
    }
  }

  /// Update user's rank based on current leaderboard
  void _updateUserRank() {
    if (_userProfile == null) return;

    final userEntry = _leaderboard.firstWhere(
      (entry) => entry.userId == _userProfile!.userId,
      orElse: () => LeaderboardEntry(
        userId: _userProfile!.userId,
        username: _userProfile!.username,
        streak: _userProfile!.streak,
        totalWorkouts: _userProfile!.totalWorkouts,
        totalExercises: _userProfile!.totalExercises,
        rank: _leaderboard.length + 1,
        lastWorkout: _userProfile!.lastWorkout,
      ),
    );

    _userRank = userEntry.rank;
  }

  /// Record a completed workout
  Future<void> recordWorkout({required int exercisesCompleted}) async {
    try {
      await _firebaseService.updateWorkoutStats(
        exercisesCompleted: exercisesCompleted,
      );

      // Reload user profile to get updated stats
      await loadUserProfile();
    } catch (e) {
      _error = 'Failed to record workout: $e';
      print('Error recording workout: $e');
      notifyListeners();
    }
  }

  /// Update username
  Future<void> updateUsername(String newUsername) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firebaseService.updateUsername(newUsername);
      await loadUserProfile();

      _error = null;
    } catch (e) {
      _error = 'Failed to update username: $e';
      print('Error updating username: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get top 3 entries
  List<LeaderboardEntry> getTopThree() {
    return _leaderboard.take(3).toList();
  }

  /// Get user's entry
  LeaderboardEntry? getUserEntry() {
    if (_userProfile == null) return null;

    try {
      return _leaderboard.firstWhere(
        (entry) => entry.userId == _userProfile!.userId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if user is in top 3
  bool isUserInTopThree() {
    return _userRank > 0 && _userRank <= 3;
  }

  /// Refresh leaderboard
  Future<void> refresh() async {
    await loadUserProfile();
    // Stream will automatically update
  }

  @override
  void dispose() {
    _leaderboardSubscription?.cancel();
    super.dispose();
  }
}
