import 'package:flutter/material.dart';
import '../models/coaching_response.dart';

class CoachingFeedbackCard extends StatelessWidget {
  final CoachingResponse response;

  const CoachingFeedbackCard({
    super.key,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.record_voice_over, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Grok says:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(response.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                response.feedback,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (response.posture != null ||
                response.fatigue != null ||
                response.injuryRisk != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              if (response.posture != null)
                _buildAnalysisSection(
                  'Posture',
                  Icons.accessibility_new,
                  response.posture!.status,
                  response.posture!.score,
                  response.posture!.issues,
                ),
              if (response.fatigue != null) ...[
                const SizedBox(height: 12),
                _buildAnalysisSection(
                  'Fatigue',
                  Icons.battery_alert,
                  response.fatigue!.level,
                  response.fatigue!.score,
                  response.fatigue!.indicators,
                ),
              ],
              if (response.injuryRisk != null) ...[
                const SizedBox(height: 12),
                _buildAnalysisSection(
                  'Injury Risk',
                  Icons.warning,
                  response.injuryRisk!.level,
                  response.injuryRisk!.score,
                  response.injuryRisk!.warnings,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection(
    String title,
    IconData icon,
    String status,
    int score,
    List<String> details,
  ) {
    final color = _getColorForScore(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: Colors.grey.withOpacity(0.2),
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          'Score: $score/100',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        if (details.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...details.map((detail) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Text(
                        detail,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
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
