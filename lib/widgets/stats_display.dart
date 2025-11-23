import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/workout_provider.dart';
import 'glass_card.dart';
import 'circular_score_indicator.dart';

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
      return GlassCard(
        child: Column(
          children: [
            Icon(
              Icons.analytics,
              size: 48,
              color: Colors.grey.shade400,
            ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms),
            const SizedBox(height: 12),
            Text(
              'Waiting for voice analysis...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ],
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

    return GlassCard(
      gradientColors: [
        Colors.blue.withOpacity(0.15),
        Colors.cyan.withOpacity(0.1),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.3),
                      Colors.cyan.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.analytics, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Session Statistics',
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
                  '${history.length} analyses',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade300,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Circular indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (postureScores.isNotEmpty)
                Expanded(
                  child: CircularScoreIndicator(
                    score: avgPosture.round(),
                    label: 'Avg Posture',
                    icon: Icons.accessibility_new,
                    size: 90,
                  ).animate().fadeIn(delay: 100.ms).scale(),
                ),
              if (fatigueScores.isNotEmpty)
                Expanded(
                  child: CircularScoreIndicator(
                    score: avgFatigue.round(),
                    label: 'Avg Fatigue',
                    icon: Icons.battery_alert,
                    size: 90,
                  ).animate().fadeIn(delay: 200.ms).scale(),
                ),
              if (injuryScores.isNotEmpty)
                Expanded(
                  child: CircularScoreIndicator(
                    score: avgInjuryRisk.round(),
                    label: 'Avg Risk',
                    icon: Icons.warning,
                    size: 90,
                  ).animate().fadeIn(delay: 300.ms).scale(),
                ),
            ],
          ),
        ],
      ),
    );
  }

}
