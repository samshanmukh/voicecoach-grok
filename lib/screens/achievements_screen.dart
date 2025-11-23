import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/gamification_provider.dart';
import '../models/gamification_models.dart';
import '../widgets/glass_card.dart';

/// Achievements/Badges screen
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationProvider>(
      builder: (context, gamification, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Achievements'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(context),
                tooltip: 'Info',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall progress
                _buildProgressCard(gamification),
                const SizedBox(height: 24),

                // Categories
                _buildCategorySection(
                  'Workout Milestones',
                  AchievementType.workout,
                  gamification,
                  Icons.fitness_center,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 24),

                _buildCategorySection(
                  'Streak Achievements',
                  AchievementType.streak,
                  gamification,
                  Icons.local_fire_department,
                  const Color(0xFFFF9800),
                ),
                const SizedBox(height: 24),

                _buildCategorySection(
                  'Exercise Mastery',
                  AchievementType.exercise,
                  gamification,
                  Icons.sports_gymnastics,
                  const Color(0xFF2196F3),
                ),
                const SizedBox(height: 24),

                _buildCategorySection(
                  'Leaderboard Rankings',
                  AchievementType.leaderboard,
                  gamification,
                  Icons.emoji_events,
                  const Color(0xFFF44336),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressCard(GamificationProvider gamification) {
    return GlassCard(
      gradientColors: [
        const Color(0xFF4CAF50).withOpacity(0.15),
        const Color(0xFF4CAF50).withOpacity(0.05),
      ],
      child: Column(
        children: [
          Row(
            children: [
              CircularPercentIndicator(
                radius: 50,
                lineWidth: 10,
                percent: gamification.completionPercent,
                center: Text(
                  '${(gamification.completionPercent * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                progressColor: const Color(0xFF4CAF50),
                backgroundColor: Colors.white.withOpacity(0.1),
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${gamification.totalUnlocked} / ${gamification.totalAchievements} Unlocked',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: gamification.completionPercent,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2);
  }

  Widget _buildCategorySection(
    String title,
    AchievementType type,
    GamificationProvider gamification,
    IconData icon,
    Color color,
  ) {
    final achievements = gamification.getAchievementsByType(type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...achievements.asMap().entries.map((entry) {
          return _buildAchievementCard(
            entry.value,
            color,
            entry.key,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAchievementCard(
    Achievement achievement,
    Color color,
    int index,
  ) {
    final isUnlocked = achievement.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        margin: EdgeInsets.zero,
        gradientColors: isUnlocked
            ? [
                color.withOpacity(0.2),
                color.withOpacity(0.05),
              ]
            : null,
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? color.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconData(achievement.iconName),
                size: 40,
                color: isUnlocked ? color : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  if (!isUnlocked) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: achievement.progressPercent,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${achievement.progress}/${achievement.requiredValue}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Checkmark or lock
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? color.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUnlocked ? Icons.check : Icons.lock_outline,
                color: isUnlocked ? color : Colors.grey,
                size: 24,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.2),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'trending_up':
        return Icons.trending_up;
      case 'star':
        return Icons.star;
      case 'military_tech':
        return Icons.military_tech;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'diamond':
        return Icons.diamond;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'sports_gymnastics':
        return Icons.sports_gymnastics;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'leaderboard':
        return Icons.leaderboard;
      default:
        return Icons.emoji_events;
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Achievements'),
        content: const Text(
          'Complete workouts, maintain streaks, and climb the leaderboard to unlock badges!\n\n'
          'Achievements track your progress and celebrate your milestones.\n\n'
          'Keep crushing those workouts to unlock them all!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
