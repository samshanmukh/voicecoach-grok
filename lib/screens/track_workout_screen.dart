import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/workout.dart';
import 'dart:math' as math;
import 'dart:async';

class TrackWorkoutScreen extends StatefulWidget {
  const TrackWorkoutScreen({super.key});

  @override
  State<TrackWorkoutScreen> createState() => _TrackWorkoutScreenState();
}

class _TrackWorkoutScreenState extends State<TrackWorkoutScreen> {
  bool _isTracking = false;
  int _elapsedSeconds = 0;
  int _calories = 0;
  Timer? _timer;
  List<Workout> _workoutHistory = [];

  @override
  void initState() {
    super.initState();
    _workoutHistory = Workout.getDummyWorkouts();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTracking() {
    setState(() {
      if (_isTracking) {
        // Stop tracking
        _stopWorkout();
      } else {
        // Start tracking
        _startWorkout();
      }
    });
  }

  void _startWorkout() {
    _isTracking = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        // Rough estimate: 5 calories per minute
        _calories = (_elapsedSeconds / 60 * 5).round();
      });
    });
  }

  void _stopWorkout() {
    _timer?.cancel();
    _isTracking = false;

    // Save workout to history if duration > 0
    if (_elapsedSeconds > 0) {
      _showSaveWorkoutDialog();
    }
  }

  void _showSaveWorkoutDialog() {
    String workoutType = 'Cardio';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Save Workout', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Duration: ${_formatDuration(_elapsedSeconds)}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Calories: $_calories kcal',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: workoutType,
              dropdownColor: const Color(0xFF2A2A2A),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Workout Type',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFC8FF00)),
                ),
              ),
              items: ['Cardio', 'Strength', 'Yoga', 'Running', 'Cycling', 'Swimming']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => workoutType = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _elapsedSeconds = 0;
                _calories = 0;
              });
              Navigator.pop(context);
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8FF00),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _workoutHistory.insert(
                  0,
                  Workout(
                    type: workoutType,
                    duration: _elapsedSeconds,
                    calories: _calories,
                  ),
                );
                _elapsedSeconds = 0;
                _calories = 0;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Workout saved!'),
                  backgroundColor: Color(0xFFC8FF00),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Workout History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _workoutHistory.isEmpty
                  ? const Center(
                      child: Text(
                        'No workouts yet.\nStart tracking to build your history!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _workoutHistory.length,
                      itemBuilder: (context, index) {
                        return _buildWorkoutCard(context, _workoutHistory[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Track Workout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_workoutHistory.isNotEmpty)
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.history, color: Color(0xFFC8FF00)),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${_workoutHistory.length}',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: _showHistory,
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
                // Tracking status indicator
                if (_isTracking)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .fadeOut(duration: 800.ms)
                            .then()
                            .fadeIn(duration: 800.ms),
                        const SizedBox(width: 12),
                        const Text(
                          'Workout in Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_isTracking) const SizedBox(height: 24),

                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.local_fire_department,
                        label: 'Calories',
                        value: '$_calories kcal',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.timer,
                        label: 'Duration',
                        value: _formatDuration(_elapsedSeconds),
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

                // Start/Stop Workout button
                GestureDetector(
                  onTap: _toggleTracking,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _isTracking ? Colors.red : const Color(0xFFC8FF00),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isTracking ? Icons.stop : Icons.play_arrow,
                          color: Colors.black,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isTracking ? 'Stop Workout' : 'Start New Workout',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Recent workouts section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent workouts (${_workoutHistory.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Workout history list
                if (_workoutHistory.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No workouts yet.\nStart your first workout!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ),
                  )
                else
                  ..._workoutHistory.take(3).toList().asMap().entries.map(
                        (entry) => _buildWorkoutCard(context, entry.value, entry.key),
                      ),
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

  Widget _buildWorkoutCard(BuildContext context, Workout workout, int index) {
    return Dismissible(
      key: Key('${workout.type}_${workout.duration}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        child: const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _workoutHistory.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
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
