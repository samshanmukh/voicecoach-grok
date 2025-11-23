import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/workout.dart';
import 'dart:math' as math;

class TrackWorkoutScreen extends StatelessWidget {
  const TrackWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workouts = Workout.getDummyWorkouts();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          'Track Workout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // History button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8FF00),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, color: Colors.black, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.local_fire_department,
                        label: 'Calories',
                        value: '300 kcal',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.timer,
                        label: 'Duration',
                        value: '30 mins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Live Tracking card with wave animation
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      // Animated wave
                      Positioned.fill(
                        child: CustomPaint(
                          painter: WavePainter(),
                        ),
                      ),
                      // Label
                      const Positioned(
                        bottom: 16,
                        left: 16,
                        child: Text(
                          'Live Tracking',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2000.ms, color: const Color(0xFFC8FF00).withOpacity(0.1)),
                const SizedBox(height: 24),

                // Start New Workout button
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8FF00),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.black, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Start New Workout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Recent workouts section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent workouts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Workout history list
                ...workouts.map((workout) => _buildWorkoutCard(context, workout)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFC8FF00), size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Avatar stack
          SizedBox(
            width: 60,
            height: 40,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: _buildAvatar(),
                ),
                Positioned(
                  left: 15,
                  child: _buildAvatar(),
                ),
                Positioned(
                  left: 30,
                  child: _buildAvatar(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Workout info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_run, color: Color(0xFFC8FF00), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      workout.type,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'JUNE 1, 2024 - 7:00 AM',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),

          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer, color: Color(0xFFC8FF00), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    workout.formattedDuration,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Color(0xFFC8FF00), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    workout.formattedCalories,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey[700],
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2A2A2A), width: 2),
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 16),
    );
  }
}

// Custom painter for animated wave
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC8FF00).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 + math.sin((x / waveLength) * 2 * math.pi) * waveHeight;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
