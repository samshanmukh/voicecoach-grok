import 'package:flutter/material.dart';
import '../providers/workout_provider.dart';

class StatsDisplay extends StatelessWidget {
  final WorkoutProvider provider;

  const StatsDisplay({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final history = provider.sessionHistory;

    if (history.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Waiting for voice analysis...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Calculate averages
    final postureScores = history
        .where((r) => r.posture != null)
        .map((r) => r.posture!.score)
        .toList();
    final fatigueScores = history
        .where((r) => r.fatigue != null)
        .map((r) => r.fatigue!.score)
        .toList();
    final injuryScores = history
        .where((r) => r.injuryRisk != null)
        .map((r) => r.injuryRisk!.score)
        .toList();

    final avgPosture = postureScores.isNotEmpty
        ? postureScores.reduce((a, b) => a + b) / postureScores.length
        : 0.0;
    final avgFatigue = fatigueScores.isNotEmpty
        ? fatigueScores.reduce((a, b) => a + b) / fatigueScores.length
        : 0.0;
    final avgInjuryRisk = injuryScores.isNotEmpty
        ? injuryScores.reduce((a, b) => a + b) / injuryScores.length
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, size: 24),
                SizedBox(width: 8),
                Text(
                  'Session Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (postureScores.isNotEmpty)
              _buildStatRow(
                'Average Posture',
                avgPosture,
                Icons.accessibility_new,
              ),
            if (fatigueScores.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildStatRow(
                'Average Fatigue',
                avgFatigue,
                Icons.battery_alert,
              ),
            ],
            if (injuryScores.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildStatRow(
                'Average Injury Risk',
                avgInjuryRisk,
                Icons.warning,
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Total Analyses: ${history.length}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, double score, IconData icon) {
    final color = _getColorForScore(score.round());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            Text(
              '${score.round()}/100',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
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
      ],
    );
  }

  Color _getColorForScore(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
