import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coaching_response.dart';
import '../services/audio_service.dart';
import '../services/xai_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  XAIService? _xaiService;

  WorkoutSession? _currentSession;
  CoachingResponse? _latestResponse;
  bool _isActive = false;
  String _apiKey = '';

  WorkoutSession? get currentSession => _currentSession;
  CoachingResponse? get latestResponse => _latestResponse;
  bool get isActive => _isActive;
  bool get hasApiKey => _apiKey.isNotEmpty;
  String get apiKey => _apiKey;

  WorkoutProvider() {
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('xai_api_key') ?? '';
    if (_apiKey.isNotEmpty) {
      _xaiService = XAIService(apiKey: _apiKey);
    }
    notifyListeners();
  }

  Future<void> saveApiKey(String key) async {
    _apiKey = key;
    _xaiService = XAIService(apiKey: key);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('xai_api_key', key);
    notifyListeners();
  }

  Future<void> startWorkout() async {
    if (_isActive) return;
    if (_xaiService == null) {
      throw Exception('API key not set. Please configure your xAI API key in settings.');
    }

    _isActive = true;
    _currentSession = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      responses: [],
    );

    notifyListeners();

    try {
      await _audioService.startRecording(
        onAudioSegment: (metadata) async {
          // Analyze voice with Grok
          final response = await _xaiService!.analyzeVoice(
            audioPath: metadata['path'] ?? '',
            audioMetadata: metadata,
            workoutContext: 'Active workout session',
          );

          _latestResponse = response;
          _currentSession?.responses.add(response);
          notifyListeners();
        },
        segmentDuration: const Duration(seconds: 5),
      );
    } catch (e) {
      print('Error starting workout: $e');
      _isActive = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> stopWorkout() async {
    if (!_isActive) return;

    await _audioService.stopRecording();
    _currentSession?.endTime = DateTime.now();
    _isActive = false;

    notifyListeners();
  }

  void clearLatestResponse() {
    _latestResponse = null;
    notifyListeners();
  }

  List<CoachingResponse> get sessionHistory {
    return _currentSession?.responses ?? [];
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
