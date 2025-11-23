import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/grok_chat_service.dart';
import '../services/tts_service.dart';

class ChatProvider extends ChangeNotifier {
  final GrokChatService _grokService = GrokChatService();
  final TTSService _tts = TTSService();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTTSEnabled = true;
  String? _error;

  static const String _messagesKey = 'chat_messages';
  static const String _ttsEnabledKey = 'tts_enabled';

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTTSEnabled => _isTTSEnabled;
  String? get error => _error;
  bool get hasApiKey => _grokService.hasApiKey;

  ChatProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _grokService.initialize();
    await _tts.initialize();
    await _loadMessages();
    await _loadTTSSetting();
    notifyListeners();
  }

  /// Load messages from storage
  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey);

      if (messagesJson != null) {
        final List<dynamic> decoded = jsonDecode(messagesJson);
        _messages.clear();
        _messages.addAll(
          decoded.map((json) => ChatMessage.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  /// Save messages to storage
  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(
        _messages.map((msg) => msg.toJson()).toList(),
      );
      await prefs.setString(_messagesKey, messagesJson);
    } catch (e) {
      print('Error saving messages: $e');
    }
  }

  /// Load TTS setting
  Future<void> _loadTTSSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isTTSEnabled = prefs.getBool(_ttsEnabledKey) ?? true;
    } catch (e) {
      print('Error loading TTS setting: $e');
    }
  }

  /// Toggle TTS on/off
  Future<void> toggleTTS() async {
    _isTTSEnabled = !_isTTSEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ttsEnabledKey, _isTTSEnabled);

    if (!_isTTSEnabled) {
      await _tts.stop();
    }

    notifyListeners();
  }

  /// Send a message to Grok
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Build conversation history for context (last 10 messages)
      final conversationHistory = _messages
          .where((msg) => _messages.indexOf(msg) >= _messages.length - 10)
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.text,
              })
          .toList();

      // Get response from Grok
      final response = await _grokService.sendMessage(
        text,
        conversationHistory: conversationHistory.sublist(
          0,
          conversationHistory.length - 1, // Exclude the message we just added
        ),
      );

      // Add Grok's response
      final grokMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(grokMessage);

      // Read response aloud if TTS is enabled
      if (_isTTSEnabled) {
        await _tts.speak(response);
      }

      // Save messages
      await _saveMessages();
    } catch (e) {
      _error = e.toString();
      print('Chat error: $e');

      // Add error message
      _messages.add(ChatMessage(
        text: 'Oops! Something went wrong. ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a workout plan from Grok
  Future<void> getWorkoutPlan(String workoutType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _grokService.getWorkoutPlan(workoutType);

      final grokMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(grokMessage);

      if (_isTTSEnabled) {
        await _tts.speak(response);
      }

      await _saveMessages();
    } catch (e) {
      _error = e.toString();
      print('Workout plan error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all messages
  Future<void> clearMessages() async {
    _messages.clear();
    await _saveMessages();
    await _tts.stop();
    notifyListeners();
  }

  /// Read a specific message aloud
  Future<void> readMessageAloud(ChatMessage message) async {
    await _tts.speak(message.text);
  }

  /// Stop current speech
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  /// Check if currently speaking
  bool get isSpeaking => _tts.isSpeaking;

  /// Save API key
  Future<void> saveApiKey(String apiKey) async {
    await _grokService.saveApiKey(apiKey);
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isError: json['isError'] as bool? ?? false,
    );
  }
}
