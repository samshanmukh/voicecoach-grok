import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/workout_models.dart';
import '../providers/workout_provider.dart';
import '../providers/gamification_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/sports_background.dart';
import 'workout_detail_screen.dart';
import 'achievements_screen.dart';

/// Workouts Tab: Browse and start workout routines
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final stats = workoutProvider.getStats();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Workouts'),
            actions: [
              // Achievements button
              Consumer<GamificationProvider>(
                builder: (context, gamification, child) {
                  return IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.emoji_events),
                        if (gamification.recentlyUnlocked.isNotEmpty)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${gamification.recentlyUnlocked.length}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementsScreen(),
                        ),
                      );
                    },
                    tooltip: 'Achievements',
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  _showWorkoutHistory(context, workoutProvider);
                },
                tooltip: 'Workout history',
              ),
            ],
          ),
          body: SportsBackground(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Header
                  SportsHeroHeader(
                    title: 'WORKOUTS',
                    subtitle: 'Push your limits 💪',
                    icon: Icons.fitness_center,
                    accentColor: const Color(0xFFFF6B35),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.3),
                  const SizedBox(height: 24),

                  // Stats Card
                _buildStatsCard(stats),
                const SizedBox(height: 24),

                // Resume Active Workout
                if (workoutProvider.hasActiveSession) ...[
                  _buildResumeCard(context, workoutProvider),
                  const SizedBox(height: 24),
                ],

                // Section Header
                const Text(
                  'Workout Templates',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Workout Cards
                ...WorkoutTemplates.templates.asMap().entries.map((entry) {
                  final index = entry.key;
                  final routine = entry.value;
                  return _buildWorkoutCard(
                    context,
                    routine,
                    index,
                    workoutProvider,
                  );
                }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    return GlassCard(
      gradientColors: [
        const Color(0xFF4CAF50).withOpacity(0.15),
        const Color(0xFF4CAF50).withOpacity(0.05),
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.fitness_center,
            stats['totalWorkouts'].toString(),
            'Workouts',
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildStatItem(
            Icons.check_circle,
            stats['totalExercises'].toString(),
            'Exercises',
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildStatItem(
            Icons.timer,
            '${stats['totalDuration'].inMinutes}m',
            'Total Time',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2);
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildResumeCard(
    BuildContext context,
    WorkoutProvider workoutProvider,
  ) {
    final session = workoutProvider.activeSession!;

    return GlassCard(
      gradientColors: [
        const Color(0xFF2196F3).withOpacity(0.2),
        const Color(0xFF2196F3).withOpacity(0.05),
      ],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailScreen(
              routine: session.routine,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.play_circle_filled,
              size: 40,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resume Workout',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.routine.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.completedExercises}/${session.totalExercises} exercises • ${(session.progress * 100).toInt()}% complete',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: Color(0xFF2196F3),
          ),
        ],
      ),
    ).animate().shake(duration: 500.ms);
  }

  Widget _buildWorkoutCard(
    BuildContext context,
    WorkoutRoutine routine,
    int index,
    WorkoutProvider workoutProvider,
  ) {
    final difficultyColor = _getDifficultyColor(routine.difficulty);
    final icon = _getWorkoutIcon(routine.name);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () async {
        // Check if there's already an active workout
        if (workoutProvider.hasActiveSession) {
          final shouldSwitch = await _showSwitchWorkoutDialog(context);
          if (shouldSwitch != true) return;

          // Cancel current workout
          await workoutProvider.cancelWorkout();
        }

        // Navigate to workout detail
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailScreen(routine: routine),
            ),
          );
        }
      },
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50).withOpacity(0.3),
                  const Color(0xFF4CAF50).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${routine.exercises.length} exercises • ${routine.totalDuration} min',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
                if (routine.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    routine.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: difficultyColor.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    routine.difficulty,
                    style: TextStyle(
                      fontSize: 11,
                      color: difficultyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Arrow
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.2);
  }

  IconData _getWorkoutIcon(String name) {
    if (name.toLowerCase().contains('arm')) {
      return Icons.fitness_center;
    } else if (name.toLowerCase().contains('leg')) {
      return Icons.directions_run;
    } else if (name.toLowerCase().contains('core')) {
      return Icons.accessibility_new;
    } else if (name.toLowerCase().contains('cardio')) {
      return Icons.favorite;
    }
    return Icons.fitness_center;
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF4CAF50); // Green
      case 'intermediate':
        return const Color(0xFFFF9800); // Orange
      case 'advanced':
        return const Color(0xFFF44336); // Red
      default:
        return Colors.grey;
    }
  }

  Future<bool?> _showSwitchWorkoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Workout?'),
        content: const Text(
          'You have a workout in progress. Do you want to switch to this workout? Your current progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
  }

  void _showWorkoutHistory(BuildContext context, WorkoutProvider provider) {
    final history = provider.getRecentSessions(limit: 20);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Workout History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (history.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No workouts completed yet.\nStart your first workout!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final session = history[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.2),
                        child: const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      title: Text(session.routine.name),
                      subtitle: Text(
                        '${session.completedExercises} exercises • ${session.duration.inMinutes} min',
                      ),
                      trailing: Text(
                        _formatDate(session.startTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
