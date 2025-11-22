class CoachingResponse {
  final String feedback;
  final PostureAnalysis? posture;
  final FatigueAnalysis? fatigue;
  final InjuryRiskAnalysis? injuryRisk;
  final DateTime timestamp;

  CoachingResponse({
    required this.feedback,
    this.posture,
    this.fatigue,
    this.injuryRisk,
    required this.timestamp,
  });

  factory CoachingResponse.fromJson(Map<String, dynamic> json) {
    return CoachingResponse(
      feedback: json['feedback'] ?? '',
      posture: json['posture'] != null
          ? PostureAnalysis.fromJson(json['posture'])
          : null,
      fatigue: json['fatigue'] != null
          ? FatigueAnalysis.fromJson(json['fatigue'])
          : null,
      injuryRisk: json['injury_risk'] != null
          ? InjuryRiskAnalysis.fromJson(json['injury_risk'])
          : null,
      timestamp: DateTime.now(),
    );
  }
}

class PostureAnalysis {
  final String status; // 'good', 'needs_improvement', 'poor'
  final List<String> issues;
  final int score; // 0-100

  PostureAnalysis({
    required this.status,
    required this.issues,
    required this.score,
  });

  factory PostureAnalysis.fromJson(Map<String, dynamic> json) {
    return PostureAnalysis(
      status: json['status'] ?? 'unknown',
      issues: List<String>.from(json['issues'] ?? []),
      score: json['score'] ?? 0,
    );
  }
}

class FatigueAnalysis {
  final String level; // 'low', 'moderate', 'high', 'extreme'
  final List<String> indicators;
  final int score; // 0-100

  FatigueAnalysis({
    required this.level,
    required this.indicators,
    required this.score,
  });

  factory FatigueAnalysis.fromJson(Map<String, dynamic> json) {
    return FatigueAnalysis(
      level: json['level'] ?? 'unknown',
      indicators: List<String>.from(json['indicators'] ?? []),
      score: json['score'] ?? 0,
    );
  }
}

class InjuryRiskAnalysis {
  final String level; // 'low', 'moderate', 'high', 'critical'
  final List<String> warnings;
  final int score; // 0-100

  InjuryRiskAnalysis({
    required this.level,
    required this.warnings,
    required this.score,
  });

  factory InjuryRiskAnalysis.fromJson(Map<String, dynamic> json) {
    return InjuryRiskAnalysis(
      level: json['level'] ?? 'unknown',
      warnings: List<String>.from(json['warnings'] ?? []),
      score: json['score'] ?? 0,
    );
  }
}

class WorkoutSession {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final List<CoachingResponse> responses;

  WorkoutSession({
    required this.id,
    required this.startTime,
    this.endTime,
    List<CoachingResponse>? responses,
  }) : responses = responses ?? [];

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
}
