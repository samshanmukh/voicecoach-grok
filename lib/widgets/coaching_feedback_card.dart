import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/coaching_response.dart';
import 'glass_card.dart';
import 'circular_score_indicator.dart';

class CoachingFeedbackCard extends StatelessWidget {
  final CoachingResponse response;

  const CoachingFeedbackCard({
    super.key,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    final hasAnalysis = response.posture != null ||
        response.fatigue != null ||
        response.injuryRisk != null;

    return GlassCard(
      gradientColors: [
        Colors.deepPurple.withOpacity(0.15),
        Colors.purple.withOpacity(0.1),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and timestamp
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.3),
                      Colors.purple.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.record_voice_over, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Grok says:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatTime(response.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade300,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Feedback text with gradient background
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.withOpacity(0.2),
                  Colors.purple.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.deepPurple.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              response.feedback,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                letterSpacing: 0.2,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),

          // Circular score indicators
          if (hasAnalysis) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (response.posture != null)
                  Expanded(
                    child: CircularScoreIndicator(
                      score: response.posture!.score,
                      label: 'Posture',
                      icon: Icons.accessibility_new,
                    ).animate().fadeIn(delay: 100.ms).scale(),
                  ),
                if (response.fatigue != null)
                  Expanded(
                    child: CircularScoreIndicator(
                      score: response.fatigue!.score,
                      label: 'Fatigue',
                      icon: Icons.battery_alert,
                    ).animate().fadeIn(delay: 200.ms).scale(),
                  ),
                if (response.injuryRisk != null)
                  Expanded(
                    child: CircularScoreIndicator(
                      score: response.injuryRisk!.score,
                      label: 'Injury Risk',
                      icon: Icons.warning,
                    ).animate().fadeIn(delay: 300.ms).scale(),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Detailed analysis sections
            if (response.posture != null && response.posture!.issues.isNotEmpty)
              _buildDetailSection(
                'Posture Issues',
                Icons.accessibility_new,
                response.posture!.issues,
                _getColorForScore(response.posture!.score),
              ),
            if (response.fatigue != null && response.fatigue!.indicators.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailSection(
                'Fatigue Indicators',
                Icons.battery_alert,
                response.fatigue!.indicators,
                _getColorForScore(response.fatigue!.score),
              ),
            ],
            if (response.injuryRisk != null && response.injuryRisk!.warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailSection(
                'Injury Warnings',
                Icons.warning,
                response.injuryRisk!.warnings,
                _getColorForScore(response.injuryRisk!.score),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    IconData icon,
    List<String> details,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...details.map((detail) => Padding(
                padding: const EdgeInsets.only(left: 26, top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_right,
                      size: 16,
                      color: color.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        detail,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Color _getColorForScore(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }
}
