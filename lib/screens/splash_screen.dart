import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';

/// Splash Screen with Grok robot animation
/// Features:
/// - 3-second fade-in animation
/// - Fun, motivational tone with flexing robot concept
/// - Auto-navigates to HomeScreen after animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  /// Navigate to home screen after 3 seconds
  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.tertiary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Grok robot flexing muscles animation
              _buildGrokRobotAnimation(),
              const SizedBox(height: 32),
              // App title with fade-in
              Text(
                'VoiceCoach',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              )
                  .animate()
                  .fadeIn(duration: 1500.ms, delay: 300.ms)
                  .slideY(begin: 0.3, end: 0, duration: 1500.ms, delay: 300.ms),
              const SizedBox(height: 8),
              // Powered by Grok with fade-in
              Text(
                'powered by Grok',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w300,
                    ),
              )
                  .animate()
                  .fadeIn(duration: 1500.ms, delay: 600.ms)
                  .slideY(begin: 0.3, end: 0, duration: 1500.ms, delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  /// Build animated Grok robot flexing muscles
  Widget _buildGrokRobotAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing circle background
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.2, 1.2),
              duration: 1500.ms,
            )
            .fadeIn(duration: 800.ms),

        // Robot icon with flexing animation
        const Icon(
          Icons.smart_toy_outlined,
          size: 120,
          color: Colors.white,
        )
            .animate()
            .fadeIn(duration: 1000.ms)
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.0, 1.0),
              duration: 1200.ms,
              curve: Curves.elasticOut,
            )
            .then()
            .shimmer(
              duration: 1500.ms,
              color: Colors.white.withOpacity(0.5),
            ),

        // Flexing arm muscles (left)
        Positioned(
          left: 20,
          child: const Icon(
            Icons.fitness_center,
            size: 40,
            color: Colors.white,
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 500.ms)
              .rotate(
                begin: 0,
                end: -0.2,
                duration: 600.ms,
                delay: 500.ms,
              )
              .then(delay: 100.ms)
              .shake(
                duration: 400.ms,
                hz: 4,
              ),
        ),

        // Flexing arm muscles (right)
        Positioned(
          right: 20,
          child: const Icon(
            Icons.fitness_center,
            size: 40,
            color: Colors.white,
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 500.ms)
              .rotate(
                begin: 0,
                end: 0.2,
                duration: 600.ms,
                delay: 500.ms,
              )
              .then(delay: 100.ms)
              .shake(
                duration: 400.ms,
                hz: 4,
              ),
        ),
      ],
    );
  }
}
