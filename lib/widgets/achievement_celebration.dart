import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../models/gamification_models.dart';

/// Celebration widget for unlocked achievements
class AchievementCelebration extends StatefulWidget {
  final List<Achievement> achievements;
  final VoidCallback onDismiss;

  const AchievementCelebration({
    super.key,
    required this.achievements,
    required this.onDismiss,
  });

  @override
  State<AchievementCelebration> createState() => _AchievementCelebrationState();
}

class _AchievementCelebrationState extends State<AchievementCelebration> {
  late ConfettiController _confettiController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < widget.achievements.length - 1) {
      setState(() => _currentIndex++);
      _confettiController.play();
    } else {
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final achievement = widget.achievements[_currentIndex];

    return Stack(
      children: [
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.3,
            colors: const [
              Color(0xFF4CAF50),
              Color(0xFF2196F3),
              Color(0xFFFF9800),
              Color(0xFFF44336),
              Color(0xFF9C27B0),
            ],
          ),
        ),

        // Achievement dialog
        Center(
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4CAF50).withOpacity(0.9),
                    const Color(0xFF2196F3).withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trophy icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconData(achievement.iconName),
                      size: 80,
                      color: Colors.white,
                    ),
                  ).animate()
                      .scale(duration: 500.ms, curve: Curves.elasticOut)
                      .then()
                      .shimmer(duration: 1000.ms),

                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'Achievement Unlocked!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),

                  const SizedBox(height: 8),

                  // Achievement name
                  Text(
                    achievement.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: -0.2),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 24),

                  // Progress indicator
                  if (widget.achievements.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.achievements.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _currentIndex
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Share button
                      IconButton(
                        onPressed: () {
                          final achievement = widget.achievements[_currentIndex];
                          final shareText = '''
🏆 Achievement Unlocked! 🎉

${achievement.name}
${achievement.description}

Powered by VoiceCoach by Grok 💪
#Achievement #FitnessGoals #VoiceCoach
''';
                          Share.share(shareText);
                        },
                        icon: const Icon(Icons.share, color: Colors.white),
                        iconSize: 28,
                        tooltip: 'Share',
                      ).animate().fadeIn(delay: 1000.ms).scale(),

                      const SizedBox(width: 16),

                      // Next/Awesome button
                      ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          _currentIndex < widget.achievements.length - 1
                              ? 'Next'
                              : 'Awesome!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ).animate().fadeIn(delay: 1000.ms).scale(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
}

/// Simple confetti celebration without dialog
class ConfettiCelebration extends StatefulWidget {
  final Duration duration;

  const ConfettiCelebration({
    super.key,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: widget.duration);
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirectionality: BlastDirectionality.explosive,
      particleDrag: 0.05,
      emissionFrequency: 0.05,
      numberOfParticles: 50,
      gravity: 0.3,
      colors: const [
        Color(0xFF4CAF50),
        Color(0xFF2196F3),
        Color(0xFFFF9800),
        Color(0xFFF44336),
        Color(0xFF9C27B0),
      ],
    );
  }
}
