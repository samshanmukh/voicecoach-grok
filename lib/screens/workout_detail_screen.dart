import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/workout_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/gamification_provider.dart';
import '../models/workout_models.dart';
import '../widgets/glass_card.dart';
import '../widgets/achievement_celebration.dart';

/// Workout Detail Screen: Active workout with timer and tracking
class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutRoutine routine;

  const WorkoutDetailScreen({
    super.key,
    required this.routine,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        // Auto-start workout if not active
        if (!workoutProvider.hasActiveSession) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            workoutProvider.startWorkout(routine);
          });
        }

        final exercise = workoutProvider.currentExercise;
        final isResting = workoutProvider.isResting;
        final remainingSeconds = workoutProvider.remainingSeconds;
        final progress = workoutProvider.sessionProgress;

        return WillPopScope(
          onWillPop: () async {
            final shouldExit = await _showExitDialog(context, workoutProvider);
            return shouldExit ?? false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(routine.name),
              actions: [
                // Overall progress
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      '${workoutProvider.completedExercises}/${workoutProvider.totalExercises}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: exercise == null
                ? _buildLoadingState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Overall Progress Bar
                        _buildProgressBar(progress),
                        const SizedBox(height: 24),

                        // Timer Circle
                        _buildTimerCircle(
                          context,
                          exercise,
                          isResting,
                          remainingSeconds,
                          workoutProvider,
                        ),
                        const SizedBox(height: 32),

                        // Exercise Info Card
                        _buildExerciseCard(exercise),
                        const SizedBox(height: 24),

                        // Control Buttons
                        _buildControlButtons(
                          context,
                          workoutProvider,
                          exercise,
                          isResting,
                        ),
                        const SizedBox(height: 24),

                        // Exercise List
                        _buildExerciseList(
                          context,
                          routine,
                          workoutProvider,
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildProgressBar(double progress) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Workout Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2);
  }

  Widget _buildTimerCircle(
    BuildContext context,
    Exercise exercise,
    bool isResting,
    int remainingSeconds,
    WorkoutProvider workoutProvider,
  ) {
    final isTimerRunning = workoutProvider.isTimerRunning;
    final maxSeconds = isResting ? exercise.restSeconds : exercise.reps;
    final percent = maxSeconds > 0 ? remainingSeconds / maxSeconds : 0.0;

    return GlassCard(
      gradientColors: [
        (isResting ? const Color(0xFFFF9800) : const Color(0xFF4CAF50))
            .withOpacity(0.15),
        (isResting ? const Color(0xFFFF9800) : const Color(0xFF4CAF50))
            .withOpacity(0.05),
      ],
      child: Column(
        children: [
          Text(
            isResting ? 'REST' : 'EXERCISE',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isResting
                  ? const Color(0xFFFF9800)
                  : const Color(0xFF4CAF50),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          CircularPercentIndicator(
            radius: 120,
            lineWidth: 16,
            percent: percent,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  remainingSeconds.toString(),
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate(
                  onPlay: (controller) => controller.repeat(),
                ).scale(
                  duration: 1000.ms,
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                ),
                const Text(
                  'seconds',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            progressColor:
                isResting ? const Color(0xFFFF9800) : const Color(0xFF4CAF50),
            backgroundColor: Colors.white.withOpacity(0.1),
            circularStrokeCap: CircularStrokeCap.round,
            animation: false,
          ),
          const SizedBox(height: 24),
          if (!isTimerRunning && !isResting)
            ElevatedButton.icon(
              onPressed: () => workoutProvider.startExerciseTimer(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Timer'),
            ),
          if (isTimerRunning)
            OutlinedButton.icon(
              onPressed: () => workoutProvider.pauseTimer(),
              icon: const Icon(Icons.pause),
              label: const Text('Pause'),
            ),
        ],
      ),
    ).animate().scale(duration: 400.ms);
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Color(0xFF4CAF50),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercise.completedSets}/${exercise.sets} sets',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Set Progress
          Row(
            children: List.generate(exercise.sets, (index) {
              final isCompleted = index < exercise.completedSets;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF4CAF50)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Exercise Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.repeat,
                '${exercise.reps} reps',
                'Per Set',
              ),
              _buildStatItem(
                Icons.timer,
                '${exercise.restSeconds}s',
                'Rest',
              ),
            ],
          ),

          if (exercise.notes != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF2196F3),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exercise.notes!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade300,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2);
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
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

  Widget _buildControlButtons(
    BuildContext context,
    WorkoutProvider workoutProvider,
    Exercise exercise,
    bool isResting,
  ) {
    final isLastExercise =
        workoutProvider.currentExerciseIndex >= workoutProvider.totalExercises - 1;
    final isFirstExercise = workoutProvider.currentExerciseIndex == 0;

    return Column(
      children: [
        // Complete Set / Finish Workout
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isResting
                ? null
                : () async {
                    await workoutProvider.completeSet();

                    // Check if workout is complete
                    if (exercise.completedSets >= exercise.sets &&
                        isLastExercise) {
                      if (context.mounted) {
                        _showCompletionDialog(context, workoutProvider);
                      }
                    }
                  },
            icon: const Icon(Icons.check_circle, size: 28),
            label: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                exercise.completedSets >= exercise.sets - 1 && isLastExercise
                    ? 'Complete Workout'
                    : 'Complete Set',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
          ),
        ).animate().scale(duration: 200.ms),

        const SizedBox(height: 12),

        // Navigation buttons
        Row(
          children: [
            // Previous
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isFirstExercise
                    ? null
                    : () => workoutProvider.previousExercise(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade300,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Skip
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => workoutProvider.skipExercise(),
                icon: const Icon(Icons.skip_next),
                label: const Text('Skip'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade300,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExerciseList(
    BuildContext context,
    WorkoutRoutine routine,
    WorkoutProvider workoutProvider,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Exercises',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...routine.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            final isCurrent = index == workoutProvider.currentExerciseIndex;
            final isCompleted = exercise.isCompleted;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrent
                    ? const Color(0xFF4CAF50).withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCurrent
                      ? const Color(0xFF4CAF50)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle
                        : (isCurrent ? Icons.play_circle : Icons.circle_outlined),
                    color: isCompleted
                        ? const Color(0xFF4CAF50)
                        : (isCurrent ? const Color(0xFF4CAF50) : Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: TextStyle(
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        Text(
                          '${exercise.sets} sets × ${exercise.reps} reps',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<bool?> _showExitDialog(
    BuildContext context,
    WorkoutProvider workoutProvider,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Workout?'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await workoutProvider.cancelWorkout();
              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(
    BuildContext context,
    WorkoutProvider workoutProvider,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.celebration, color: Color(0xFF4CAF50), size: 32),
            const SizedBox(width: 12),
            const Text('Workout Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Amazing job! You completed the workout!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Duration: ${workoutProvider.activeSession?.duration.inMinutes ?? 0} min',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              final session = workoutProvider.activeSession!;
              final shareText = '''
🏋️ Workout Complete! 💪

Workout: ${session.routine.name}
Duration: ${session.duration.inMinutes} minutes
Exercises: ${session.completedExercises}/${session.totalExercises}

Powered by VoiceCoach by Grok 🚀
#VoiceCoach #FitnessGoals #WorkoutComplete
''';
              Share.share(shareText);
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Get providers
              final leaderboardProvider = context.read<LeaderboardProvider>();
              final gamificationProvider = context.read<GamificationProvider>();
              final completedExercises =
                  workoutProvider.activeSession?.completedExercises ?? 0;

              // Record to leaderboard
              await leaderboardProvider.recordWorkout(
                exercisesCompleted: completedExercises,
              );

              // Check for achievements
              final stats = workoutProvider.getStats();
              final userProfile = leaderboardProvider.userProfile;
              final newAchievements = await gamificationProvider.checkAchievements(
                totalWorkouts: stats['totalWorkouts'] as int,
                totalExercises: stats['totalExercises'] as int,
                currentStreak: userProfile?.streak ?? 0,
                leaderboardRank: leaderboardProvider.userRank,
              );

              // Complete workout
              await workoutProvider.completeWorkout();

              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to workouts screen

                // Show achievement celebration if any unlocked
                if (newAchievements.isNotEmpty) {
                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AchievementCelebration(
                      achievements: newAchievements,
                      onDismiss: () {
                        gamificationProvider.clearRecentlyUnlocked();
                        Navigator.pop(context);
                      },
                    ),
                  );
                }

                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newAchievements.isNotEmpty
                            ? 'Workout complete! ${newAchievements.length} achievement(s) unlocked!'
                            : 'Workout recorded to leaderboard!',
                      ),
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  );
                }
              }
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}
