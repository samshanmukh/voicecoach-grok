import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_models.dart';

/// Manages workout sessions with timer, tracking, and persistence
class WorkoutProvider extends ChangeNotifier {
  WorkoutSession? _activeSession;
  List<WorkoutSession> _sessionHistory = [];

  // Timer state
  Timer? _exerciseTimer;
  Timer? _restTimer;
  int _remainingSeconds = 0;
  bool _isResting = false;

  static const String _sessionHistoryKey = 'workout_session_history';
  static const String _activeSessionKey = 'active_workout_session';

  // Getters
  WorkoutSession? get activeSession => _activeSession;
  List<WorkoutSession> get sessionHistory => _sessionHistory;
  int get remainingSeconds => _remainingSeconds;
  bool get isResting => _isResting;
  bool get hasActiveSession => _activeSession != null;
  bool get isTimerRunning => _exerciseTimer != null || _restTimer != null;

  Exercise? get currentExercise => _activeSession?.currentExercise;
  int get currentExerciseIndex => _activeSession?.currentExerciseIndex ?? 0;
  double get sessionProgress => _activeSession?.progress ?? 0.0;
  int get completedExercises => _activeSession?.completedExercises ?? 0;
  int get totalExercises => _activeSession?.totalExercises ?? 0;

  WorkoutProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSessionHistory();
    await _loadActiveSession();
    notifyListeners();
  }

  /// Load session history from storage
  Future<void> _loadSessionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_sessionHistoryKey);

      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        _sessionHistory = decoded
            .map((json) => WorkoutSession.fromJson(json))
            .toList();

        // Keep only last 30 sessions
        if (_sessionHistory.length > 30) {
          _sessionHistory = _sessionHistory.sublist(_sessionHistory.length - 30);
        }
      }
    } catch (e) {
      print('Error loading session history: $e');
    }
  }

  /// Save session history to storage
  Future<void> _saveSessionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(
        _sessionHistory.map((session) => session.toJson()).toList(),
      );
      await prefs.setString(_sessionHistoryKey, historyJson);
    } catch (e) {
      print('Error saving session history: $e');
    }
  }

  /// Load active session from storage
  Future<void> _loadActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_activeSessionKey);

      if (sessionJson != null) {
        _activeSession = WorkoutSession.fromJson(jsonDecode(sessionJson));
      }
    } catch (e) {
      print('Error loading active session: $e');
    }
  }

  /// Save active session to storage
  Future<void> _saveActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_activeSession != null) {
        final sessionJson = jsonEncode(_activeSession!.toJson());
        await prefs.setString(_activeSessionKey, sessionJson);
      } else {
        await prefs.remove(_activeSessionKey);
      }
    } catch (e) {
      print('Error saving active session: $e');
    }
  }

  /// Start a new workout session
  Future<void> startWorkout(WorkoutRoutine routine) async {
    if (_activeSession != null) {
      throw Exception('A workout is already in progress');
    }

    _activeSession = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      routine: routine,
      startTime: DateTime.now(),
    );

    await _saveActiveSession();
    notifyListeners();
  }

  /// Start exercise timer (for timed exercises like planks)
  void startExerciseTimer({int? customSeconds}) {
    if (_activeSession == null) return;

    final exercise = currentExercise;
    if (exercise == null) return;

    _stopAllTimers();
    _isResting = false;

    // For timed exercises, use reps as seconds
    _remainingSeconds = customSeconds ?? exercise.reps;

    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _exerciseTimer?.cancel();
        _exerciseTimer = null;
        notifyListeners();
      }
    });

    notifyListeners();
  }

  /// Complete current set
  Future<void> completeSet() async {
    if (_activeSession == null) return;

    final exercise = currentExercise;
    if (exercise == null) return;

    // Increment completed sets
    exercise.completedSets++;

    // Check if exercise is complete
    if (exercise.completedSets >= exercise.sets) {
      exercise.isCompleted = true;

      // Auto-advance to next exercise
      if (_activeSession!.currentExerciseIndex < _activeSession!.routine.exercises.length - 1) {
        _activeSession!.currentExerciseIndex++;
        // Start rest timer before next exercise
        startRestTimer();
      }
    } else {
      // Start rest timer between sets
      startRestTimer();
    }

    await _saveActiveSession();
    notifyListeners();
  }

  /// Skip current exercise
  Future<void> skipExercise() async {
    if (_activeSession == null) return;

    final exercise = currentExercise;
    if (exercise != null) {
      exercise.isCompleted = true;
    }

    if (_activeSession!.currentExerciseIndex < _activeSession!.routine.exercises.length - 1) {
      _activeSession!.currentExerciseIndex++;
      _stopAllTimers();
    }

    await _saveActiveSession();
    notifyListeners();
  }

  /// Go to previous exercise
  Future<void> previousExercise() async {
    if (_activeSession == null) return;

    if (_activeSession!.currentExerciseIndex > 0) {
      _activeSession!.currentExerciseIndex--;
      _stopAllTimers();
    }

    await _saveActiveSession();
    notifyListeners();
  }

  /// Start rest timer
  void startRestTimer({int? customSeconds}) {
    final exercise = currentExercise;
    if (exercise == null) return;

    _stopAllTimers();
    _isResting = true;
    _remainingSeconds = customSeconds ?? exercise.restSeconds;

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _restTimer?.cancel();
        _restTimer = null;
        _isResting = false;
        notifyListeners();
      }
    });

    notifyListeners();
  }

  /// Pause/Resume timer
  void pauseTimer() {
    _stopAllTimers();
    notifyListeners();
  }

  /// Stop all timers
  void _stopAllTimers() {
    _exerciseTimer?.cancel();
    _restTimer?.cancel();
    _exerciseTimer = null;
    _restTimer = null;
    _remainingSeconds = 0;
    _isResting = false;
  }

  /// Complete workout session
  Future<void> completeWorkout() async {
    if (_activeSession == null) return;

    _activeSession!.endTime = DateTime.now();
    _activeSession!.isCompleted = true;

    // Add to history
    _sessionHistory.add(_activeSession!);
    await _saveSessionHistory();

    // Clear active session
    _activeSession = null;
    await _saveActiveSession();

    _stopAllTimers();
    notifyListeners();
  }

  /// Cancel workout session
  Future<void> cancelWorkout() async {
    if (_activeSession == null) return;

    _activeSession = null;
    await _saveActiveSession();

    _stopAllTimers();
    notifyListeners();
  }

  /// Get workout statistics
  Map<String, dynamic> getStats() {
    final totalWorkouts = _sessionHistory.where((s) => s.isCompleted).length;
    final totalExercises = _sessionHistory
        .where((s) => s.isCompleted)
        .fold(0, (sum, session) => sum + session.completedExercises);

    final totalDuration = _sessionHistory
        .where((s) => s.isCompleted)
        .fold(Duration.zero, (sum, session) => sum + session.duration);

    return {
      'totalWorkouts': totalWorkouts,
      'totalExercises': totalExercises,
      'totalDuration': totalDuration,
      'averageDuration': totalWorkouts > 0
          ? totalDuration ~/ totalWorkouts
          : Duration.zero,
    };
  }

  /// Get recent workout sessions
  List<WorkoutSession> getRecentSessions({int limit = 10}) {
    return _sessionHistory
        .where((s) => s.isCompleted)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  /// Clear all workout history
  Future<void> clearHistory() async {
    _sessionHistory.clear();
    await _saveSessionHistory();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopAllTimers();
    super.dispose();
  }
}
