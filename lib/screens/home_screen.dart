import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/workout_provider.dart';
import '../widgets/coaching_feedback_card.dart';
import '../widgets/stats_display.dart';
import '../widgets/glass_card.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<WorkoutProvider>(
          builder: (context, provider, child) {
            if (!provider.hasApiKey) {
              return _buildApiKeyPrompt(context);
            }

            return Column(
              children: [
                _buildHeader(context, provider),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildStatusCard(provider),
                        const SizedBox(height: 16),
                        if (provider.latestResponse != null)
                          CoachingFeedbackCard(
                            response: provider.latestResponse!,
                          ).animate().fadeIn().slideY(
                                begin: 0.2,
                                duration: 300.ms,
                              ),
                        const SizedBox(height: 16),
                        if (provider.isActive) StatsDisplay(provider: provider),
                        const SizedBox(height: 80), // Space for FAB
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Consumer<WorkoutProvider>(
        builder: (context, provider, child) {
          if (!provider.hasApiKey) return const SizedBox();

          return FloatingActionButton.extended(
            onPressed: () => _toggleWorkout(context, provider),
            backgroundColor: provider.isActive ? Colors.red : Colors.green,
            icon: Icon(provider.isActive ? Icons.stop : Icons.play_arrow),
            label: Text(provider.isActive ? 'Stop Workout' : 'Start Workout'),
          ).animate(
            onPlay: (controller) => controller.repeat(),
          ).shimmer(
            duration: 2000.ms,
            color: Colors.white.withOpacity(0.3),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(BuildContext context, WorkoutProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VoiceCoach',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'by Grok',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.key,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to VoiceCoach!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'To get started, you need to configure your xAI API key.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Go to Settings'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(WorkoutProvider provider) {
    final isActive = provider.isActive;
    final session = provider.currentSession;

    return GlassCard(
      gradientColors: [
        isActive
            ? Colors.green.withOpacity(0.15)
            : Colors.grey.withOpacity(0.1),
        isActive
            ? Colors.teal.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
      ],
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isActive ? Colors.green : Colors.grey,
                  size: 20,
                ),
              ).animate(
                onPlay: (controller) => isActive ? controller.repeat() : null,
              ).shimmer(
                duration: 1500.ms,
                color: Colors.green.withOpacity(0.5),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isActive ? 'Workout Active' : 'Ready to Start',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isActive ? 'Listening to your voice...' : 'Tap below to begin',
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
          if (session != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Duration',
                    _formatDuration(session.duration),
                    Icons.timer,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  _buildStatItem(
                    'Analyses',
                    '${session.responses.length}',
                    Icons.analytics,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleWorkout(BuildContext context, WorkoutProvider provider) async {
    if (provider.isActive) {
      await provider.stopWorkout();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout stopped')),
        );
      }
    } else {
      try {
        await provider.startWorkout();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Workout started - speak naturally during your exercise'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
