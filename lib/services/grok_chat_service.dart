import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Grok Chat Service for real-time conversations
/// Uses grok-4-1-fast-non-reasoning model for optimal performance
class GrokChatService {
  static const String _baseUrl = 'https://api.x.ai/v1/chat/completions';
  static const String _model = 'grok-4-1-fast-non-reasoning';
  static const String _apiKeyPrefsKey = 'xai_api_key';

  String? _apiKey;

  /// Initialize and load API key from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyPrefsKey);
  }

  /// Save API key to storage
  Future<void> saveApiKey(String apiKey) async {
    _apiKey = apiKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPrefsKey, apiKey);
  }

  /// Check if API key is configured
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  /// Get current API key
  String? get apiKey => _apiKey;

  /// Send a message to Grok and get response
  ///
  /// [message] - User's message
  /// [conversationHistory] - Previous messages for context
  ///
  /// Returns Grok's response text
  Future<String> sendMessage(
    String message, {
    List<Map<String, String>>? conversationHistory,
  }) async {
    if (!hasApiKey) {
      throw Exception('API key not configured. Please set it in settings.');
    }

    try {
      // Build messages array with system prompt
      final messages = [
        {
          'role': 'system',
          'content': '''You are VoiceCoach's AI assistant, powered by Grok. You're a sarcastic but helpful fitness coach who:

1. Gives workout advice with personality and humor
2. Creates workout plans when asked (e.g., "arm day?", "leg day?")
3. Provides nutrition tips and motivation
4. Roasts users playfully when they need tough love
5. Uses emojis and casual language
6. Keeps responses concise but informative

Be direct, funny, and motivating. You're here to help people get fit while keeping them entertained!'''
        },
      ];

      // Add conversation history for context
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        messages.addAll(conversationHistory);
      }

      // Add current user message
      messages.add({
        'role': 'user',
        'content': message,
      });

      // Make API request
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.8, // Slightly higher for more personality
          'max_tokens': 500, // Keep responses concise
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'] as String;
        } else {
          throw Exception('No response from Grok');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Failed to get response: ${response.statusCode} - ${errorData['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Chat error: $e');
    }
  }

  /// Get workout plan from Grok
  /// Specialized method for workout planning
  Future<String> getWorkoutPlan(String workoutType) async {
    final prompt = '''Create a workout plan for: $workoutType

Include:
- 5-7 exercises with reps/sets
- Brief form tips
- Target muscle groups
- Estimated duration

Keep it practical and motivating!''';

    return sendMessage(prompt);
  }

  /// Get nutrition advice
  Future<String> getNutritionAdvice(String question) async {
    final prompt = '''Nutrition question: $question

Give practical, science-based advice in your signature style.''';

    return sendMessage(prompt);
  }

  /// Get model info
  String get modelInfo => 'Using $_model - Optimized for fast, quality responses';
}
