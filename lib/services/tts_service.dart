import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech service for reading Grok's responses aloud
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  /// Initialize TTS with configuration
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set language
      await _flutterTts.setLanguage("en-US");

      // Set speech rate (1.0 is normal, 0.5 is slower, 2.0 is faster)
      await _flutterTts.setSpeechRate(0.9);

      // Set volume (0.0 to 1.0)
      await _flutterTts.setVolume(1.0);

      // Set pitch (1.0 is normal)
      await _flutterTts.setPitch(1.0);

      // Set up handlers
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        print('TTS Error: $msg');
      });

      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize TTS: $e');
    }
  }

  /// Speak the given text aloud
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Stop any current speech
      if (_isSpeaking) {
        await stop();
      }

      // Speak the text
      await _flutterTts.speak(text);
    } catch (e) {
      print('Failed to speak: $e');
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      print('Failed to stop TTS: $e');
    }
  }

  /// Pause current speech
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print('Failed to pause TTS: $e');
    }
  }

  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Set speech rate (0.0 to 1.0, where 0.5 is half speed, 2.0 is double speed)
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e) {
      print('Failed to set speech rate: $e');
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume);
    } catch (e) {
      print('Failed to set volume: $e');
    }
  }

  /// Set pitch (0.5 to 2.0, where 1.0 is normal)
  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch);
    } catch (e) {
      print('Failed to set pitch: $e');
    }
  }

  /// Get available voices
  Future<List<dynamic>> getVoices() async {
    try {
      return await _flutterTts.getVoices;
    } catch (e) {
      print('Failed to get voices: $e');
      return [];
    }
  }

  /// Set voice by name
  Future<void> setVoice(Map<String, String> voice) async {
    try {
      await _flutterTts.setVoice(voice);
    } catch (e) {
      print('Failed to set voice: $e');
    }
  }

  /// Dispose TTS resources
  void dispose() {
    _flutterTts.stop();
  }
}
