import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coaching_response.dart';

class XAIService {
  final String apiKey;
  static const String _baseUrl = 'https://api.x.ai/v1';

  XAIService({required this.apiKey});

  /// Analyzes voice characteristics to provide coaching feedback
  /// This sends audio metadata and context to Grok for analysis
  Future<CoachingResponse> analyzeVoice({
    required String audioPath,
    required Map<String, dynamic> audioMetadata,
    String? workoutContext,
  }) async {
    try {
      // Create a detailed prompt for Grok to analyze the voice
      final prompt = _buildAnalysisPrompt(audioMetadata, workoutContext);

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'messages': [
            {
              'role': 'system',
              'content': '''You are VoiceCoach, a brutally honest AI personal trainer powered by Grok.
You analyze voice patterns to detect posture issues, fatigue levels, and injury risks during workouts.
Be direct, savage when needed, but always prioritize safety. Return your analysis in JSON format with:
{
  "feedback": "your savage coaching message",
  "posture": {"status": "good/needs_improvement/poor", "issues": [], "score": 0-100},
  "fatigue": {"level": "low/moderate/high/extreme", "indicators": [], "score": 0-100},
  "injury_risk": {"level": "low/moderate/high/critical", "warnings": [], "score": 0-100}
}'''
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'model': 'grok-beta',
          'stream': false,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        // Parse the JSON response from Grok
        final analysisJson = _extractJsonFromResponse(content);

        return CoachingResponse.fromJson(analysisJson);
      } else {
        throw Exception('Failed to analyze voice: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in voice analysis: $e');
      return CoachingResponse(
        feedback: 'Error analyzing your voice. Check your connection and API key.',
        timestamp: DateTime.now(),
      );
    }
  }

  String _buildAnalysisPrompt(Map<String, dynamic> metadata, String? context) {
    final buffer = StringBuffer();
    buffer.writeln('Analyze this workout voice sample:');
    buffer.writeln('');
    buffer.writeln('Audio Characteristics:');
    buffer.writeln('- Duration: ${metadata['duration']}ms');
    buffer.writeln('- Average amplitude: ${metadata['averageAmplitude']}');
    buffer.writeln('- Peak amplitude: ${metadata['peakAmplitude']}');
    buffer.writeln('- Breathing pattern: ${metadata['breathingPattern']}');

    if (context != null && context.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Workout Context: $context');
    }

    buffer.writeln('');
    buffer.writeln('Provide savage but safety-focused coaching feedback in JSON format.');

    return buffer.toString();
  }

  Map<String, dynamic> _extractJsonFromResponse(String content) {
    try {
      // Try to parse the entire content as JSON first
      return jsonDecode(content);
    } catch (e) {
      // If that fails, try to extract JSON from markdown code blocks
      final jsonMatch = RegExp(r'```(?:json)?\s*(\{[\s\S]*?\})\s*```').firstMatch(content);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(1)!);
      }

      // Try to find any JSON object in the content
      final jsonObjectMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonObjectMatch != null) {
        return jsonDecode(jsonObjectMatch.group(0)!);
      }

      // Fallback: create a basic response with the raw content
      return {
        'feedback': content,
        'posture': {'status': 'unknown', 'issues': [], 'score': 50},
        'fatigue': {'level': 'unknown', 'indicators': [], 'score': 50},
        'injury_risk': {'level': 'unknown', 'warnings': [], 'score': 50},
      };
    }
  }

  /// Stream real-time analysis for continuous coaching
  Stream<CoachingResponse> streamAnalysis({
    required Stream<Map<String, dynamic>> audioStream,
    String? workoutContext,
  }) async* {
    await for (final metadata in audioStream) {
      yield await analyzeVoice(
        audioPath: metadata['path'] ?? '',
        audioMetadata: metadata,
        workoutContext: workoutContext,
      );
    }
  }
}
