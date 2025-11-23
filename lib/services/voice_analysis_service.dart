import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/voice_analysis_models.dart';

/// Service for analyzing voice recordings with Grok
class VoiceAnalysisService {
  static const String _baseUrl = 'https://api.x.ai/v1/chat/completions';
  static const String _model = 'grok-4-1-fast-non-reasoning';
  static const String _apiKeyKey = 'xai_api_key';

  String? _apiKey;

  /// Initialize the service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyKey);
  }

  /// Check if API key is set
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  /// Save API key
  Future<void> saveApiKey(String apiKey) async {
    _apiKey = apiKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }

  /// Analyze voice recording with Grok
  ///
  /// Note: Grok API currently doesn't support direct audio input.
  /// This method analyzes based on user's text description of how they feel.
  /// In the future, this could be enhanced with transcription services.
  Future<VoiceAnalysisResult> analyzeVoice({
    required String userDescription,
    String? workoutContext,
  }) async {
    if (!hasApiKey) {
      throw Exception('API key not set');
    }

    try {
      // Build the analysis prompt
      final prompt = _buildAnalysisPrompt(userDescription, workoutContext);

      // Call Grok API
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': _getSystemPrompt(),
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.9,
          'max_tokens': 300,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(
          'Failed to analyze voice: ${response.statusCode} - ${error['error'] ?? error}',
        );
      }

      final data = jsonDecode(response.body);
      final grokResponse = data['choices'][0]['message']['content'] as String;

      // Parse Grok's response into structured result
      return VoiceAnalysisResult.fromGrokResponse(grokResponse);
    } catch (e) {
      print('Voice analysis error: $e');
      rethrow;
    }
  }

  /// Analyze voice with mock data (for testing without recording)
  Future<VoiceAnalysisResult> analyzeMock({
    required String feeling,
  }) async {
    if (!hasApiKey) {
      throw Exception('API key not set');
    }

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    return analyzeVoice(
      userDescription: 'I feel $feeling after my workout',
      workoutContext: 'Just completed a workout session',
    );
  }

  String _getSystemPrompt() {
    return '''You are Grok, a witty and motivational fitness coach analyzing post-workout voice vitality.

Your job is to assess how the user feels after their workout and provide:
1. A status assessment (Pumped, Tired, Dehydrated, Energized, or Exhausted)
2. Sarcastic but motivational feedback
3. Specific recommendations

Be funny and sarcastic, but ultimately supportive. If they sound tired, call it out with humor. If dehydrated, roast them about croaking. If pumped, celebrate with them!

Keep responses under 100 words. Always include actionable recommendations.''';
  }

  String _buildAnalysisPrompt(String userDescription, String? workoutContext) {
    final context = workoutContext != null ? '\n\nContext: $workoutContext' : '';

    return '''Analyze this post-workout state:

"$userDescription"$context

Based on this, provide:
1. Status (Pumped/Tired/Dehydrated/Energized/Exhausted)
2. Your witty, motivational feedback (be sarcastic but supportive!)
3. 2-3 specific recommendations

Example response format:
"Yo, you sound FIRED UP! That's what I'm talking about! Your energy is through the roof. Beast mode activated! 💪

- Keep hydration levels up
- Maintain this intensity
- Perfect recovery indicators"

Now analyze the user's state and respond in your signature style!''';
  }

  /// Get analysis from voice recording file
  ///
  /// Note: This would require audio transcription service.
  /// For now, it's a placeholder for future enhancement.
  Future<VoiceAnalysisResult> analyzeVoiceFile({
    required String audioFilePath,
    String? workoutContext,
  }) async {
    // TODO: Implement audio transcription (e.g., using Google Speech-to-Text)
    // For now, return a placeholder that prompts for description
    throw UnimplementedError(
      'Audio transcription not yet implemented. '
      'Please use text description instead.',
    );
  }
}
