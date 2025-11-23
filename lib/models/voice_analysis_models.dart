import 'dart:convert';

/// Voice analysis result from Grok
class VoiceAnalysisResult {
  final String status; // Pumped, Tired, Dehydrated, Energized, Exhausted
  final int confidence; // 0-100
  final String feedback; // Grok's sarcastic/motivational response
  final List<String> recommendations;
  final DateTime timestamp;
  final Map<String, dynamic>? rawAnalysis; // Full Grok response

  VoiceAnalysisResult({
    required this.status,
    required this.confidence,
    required this.feedback,
    required this.recommendations,
    required this.timestamp,
    this.rawAnalysis,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'confidence': confidence,
      'feedback': feedback,
      'recommendations': recommendations,
      'timestamp': timestamp.toIso8601String(),
      'rawAnalysis': rawAnalysis,
    };
  }

  factory VoiceAnalysisResult.fromJson(Map<String, dynamic> json) {
    return VoiceAnalysisResult(
      status: json['status'] as String,
      confidence: json['confidence'] as int,
      feedback: json['feedback'] as String,
      recommendations: (json['recommendations'] as List)
          .map((e) => e as String)
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      rawAnalysis: json['rawAnalysis'] as Map<String, dynamic>?,
    );
  }

  /// Parse Grok's response text into structured result
  factory VoiceAnalysisResult.fromGrokResponse(String grokResponse) {
    // Extract status from response
    String status = 'Unknown';
    int confidence = 75;

    // Look for status indicators in response
    final lowerResponse = grokResponse.toLowerCase();
    if (lowerResponse.contains('pumped') ||
        lowerResponse.contains('fired up') ||
        lowerResponse.contains('energized')) {
      status = 'Pumped';
      confidence = 85;
    } else if (lowerResponse.contains('tired') ||
        lowerResponse.contains('fatigued') ||
        lowerResponse.contains('exhausted')) {
      status = 'Tired';
      confidence = 80;
    } else if (lowerResponse.contains('dehydrated') ||
        lowerResponse.contains('thirsty') ||
        lowerResponse.contains('drink water') ||
        lowerResponse.contains('croaking')) {
      status = 'Dehydrated';
      confidence = 90;
    }

    // Extract recommendations (look for bullet points or numbered lists)
    final recommendations = <String>[];
    final lines = grokResponse.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('-') ||
          trimmed.startsWith('•') ||
          RegExp(r'^\d+\.').hasMatch(trimmed)) {
        recommendations.add(trimmed.replaceFirst(RegExp(r'^[-•\d+.]\s*'), ''));
      }
    }

    // If no recommendations found, add default ones
    if (recommendations.isEmpty) {
      if (status == 'Dehydrated') {
        recommendations.addAll([
          'Drink 16-20 oz of water immediately',
          'Add electrolytes to next drink',
          'Monitor urine color for hydration'
        ]);
      } else if (status == 'Tired') {
        recommendations.addAll([
          'Consider a 10-15 minute power nap',
          'Reduce volume on next workout',
          'Focus on protein and complex carbs'
        ]);
      } else {
        recommendations.addAll([
          'Maintain current energy levels',
          'Stay hydrated throughout the day',
          'Great work - keep it up!'
        ]);
      }
    }

    return VoiceAnalysisResult(
      status: status,
      confidence: confidence,
      feedback: grokResponse,
      recommendations: recommendations.take(5).toList(),
      timestamp: DateTime.now(),
      rawAnalysis: {'fullResponse': grokResponse},
    );
  }
}

/// Voice recording metadata
class VoiceRecording {
  final String id;
  final String filePath;
  final Duration duration;
  final DateTime timestamp;
  final int? sampleRate;
  final String? format;

  VoiceRecording({
    required this.id,
    required this.filePath,
    required this.duration,
    required this.timestamp,
    this.sampleRate,
    this.format,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'duration': duration.inSeconds,
      'timestamp': timestamp.toIso8601String(),
      'sampleRate': sampleRate,
      'format': format,
    };
  }

  factory VoiceRecording.fromJson(Map<String, dynamic> json) {
    return VoiceRecording(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      duration: Duration(seconds: json['duration'] as int),
      timestamp: DateTime.parse(json['timestamp'] as String),
      sampleRate: json['sampleRate'] as int?,
      format: json['format'] as String?,
    );
  }
}

/// Voice vitality status enum
enum VitalityStatus {
  pumped,
  energized,
  normal,
  tired,
  fatigued,
  dehydrated,
  exhausted,
  unknown;

  String get displayName {
    switch (this) {
      case VitalityStatus.pumped:
        return 'Pumped';
      case VitalityStatus.energized:
        return 'Energized';
      case VitalityStatus.normal:
        return 'Normal';
      case VitalityStatus.tired:
        return 'Tired';
      case VitalityStatus.fatigued:
        return 'Fatigued';
      case VitalityStatus.dehydrated:
        return 'Dehydrated';
      case VitalityStatus.exhausted:
        return 'Exhausted';
      case VitalityStatus.unknown:
        return 'Unknown';
    }
  }

  static VitalityStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pumped':
        return VitalityStatus.pumped;
      case 'energized':
        return VitalityStatus.energized;
      case 'normal':
        return VitalityStatus.normal;
      case 'tired':
        return VitalityStatus.tired;
      case 'fatigued':
        return VitalityStatus.fatigued;
      case 'dehydrated':
        return VitalityStatus.dehydrated;
      case 'exhausted':
        return VitalityStatus.exhausted;
      default:
        return VitalityStatus.unknown;
    }
  }
}
