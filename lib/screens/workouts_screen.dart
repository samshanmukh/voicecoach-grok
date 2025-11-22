import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/glass_card.dart';

/// Workouts Tab: Scrollable list of routines
/// Tap to start timer, log reps, sets
/// Progress ring fills up
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final List<WorkoutRoutine> _routines = [
    WorkoutRoutine(
      name: 'Arm Day',
      exercises: ['Bicep Curls', 'Tricep Dips', 'Hammer Curls'],
      duration: 45,
      difficulty: 'Intermediate',
      icon: Icons.fitness_center,
    ),
    WorkoutRoutine(
      name: 'Leg Day',
      exercises: ['Squats', 'Lunges', 'Leg Press'],
      duration: 60,
      difficulty: 'Advanced',
      icon: Icons.directions_run,
    ),
    WorkoutRoutine(
      name: 'Core Blast',
      exercises: ['Planks', 'Crunches', 'Russian Twists'],
      duration: 30,
      difficulty: 'Beginner',
      icon: Icons.accessibility_new,
    ),
    WorkoutRoutine(
      name: 'Cardio',
      exercises: ['Running', 'Burpees', 'Jump Rope'],
      duration: 40,
      difficulty: 'Intermediate',
      icon: Icons.favorite,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: Phase 3 - Add custom workout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Custom workouts coming in Phase 3!'),
                ),
              );
            },
            tooltip: 'Add workout',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _routines.length,
        itemBuilder: (context, index) {
          return _buildWorkoutCard(_routines[index], index);
        },
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutRoutine routine, int index) {
    final difficultyColor = _getDifficultyColor(routine.difficulty);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () {
        // TODO: Phase 3 - Open workout detail and start timer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Starting ${routine.name}... (Phase 3 feature)'),
          ),
        );
      },
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              routine.icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
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
                  '${routine.exercises.length} exercises • ${routine.duration} min',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
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
}

class WorkoutRoutine {
  final String name;
  final List<String> exercises;
  final int duration;
  final String difficulty;
  final IconData icon;

  WorkoutRoutine({
    required this.name,
    required this.exercises,
    required this.duration,
    required this.difficulty,
    required this.icon,
  });
}
