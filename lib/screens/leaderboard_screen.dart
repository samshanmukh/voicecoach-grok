import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/leaderboard_provider.dart';
import '../models/leaderboard_models.dart';
import '../widgets/glass_card.dart';

/// Leaderboard Tab: Global rankings by streak length with Firebase
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh every minute
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      context.read<LeaderboardProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _showUsernameDialog(BuildContext context) {
    final provider = context.read<LeaderboardProvider>();
    final controller = TextEditingController(
      text: provider.userProfile?.username ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter username',
            border: OutlineInputBorder(),
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUsername = controller.text.trim();
              if (newUsername.isNotEmpty) {
                await provider.updateUsername(newUsername);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Username updated!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaderboardProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Leaderboard'),
            actions: [
              // Edit username
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showUsernameDialog(context),
                tooltip: 'Change username',
              ),
              // Refresh
              IconButton(
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                onPressed: provider.isLoading
                    ? null
                    : () => provider.refresh(),
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: provider.isLoading && provider.leaderboard.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
                  ? _buildErrorState(provider)
                  : Column(
                      children: [
                        // User rank card
                        _buildUserRankCard(provider),

                        // Top 3 podium
                        if (provider.leaderboard.isNotEmpty)
                          _buildTopThreePodium(provider),

                        // Leaderboard list
                        Expanded(
                          child: _buildLeaderboardList(provider),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildErrorState(LeaderboardProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              provider.error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRankCard(LeaderboardProvider provider) {
    final userProfile = provider.userProfile;
    if (userProfile == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        gradientColors: [
          const Color(0xFF4CAF50).withOpacity(0.15),
          const Color(0xFF4CAF50).withOpacity(0.05),
        ],
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFFF9800)),
                const SizedBox(width: 8),
                const Text(
                  'Your Global Rank',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  Icons.military_tech,
                  '#${provider.userRank}',
                  'Rank',
                  const Color(0xFF4CAF50),
                ),
                _buildStatColumn(
                  Icons.local_fire_department,
                  '${userProfile.streak}',
                  'Streak',
                  const Color(0xFFFF9800),
                ),
                _buildStatColumn(
                  Icons.fitness_center,
                  '${userProfile.totalWorkouts}',
                  'Workouts',
                  const Color(0xFF2196F3),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),
    );
  }

  Widget _buildStatColumn(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
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

  Widget _buildTopThreePodium(LeaderboardProvider provider) {
    final topThree = provider.getTopThree();
    if (topThree.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        child: Column(
          children: [
            const Text(
              'Top 3',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 2nd place
                if (topThree.length > 1)
                  _buildPodiumPosition(topThree[1], 2, 80),
                // 1st place
                if (topThree.isNotEmpty)
                  _buildPodiumPosition(topThree[0], 1, 100),
                // 3rd place
                if (topThree.length > 2)
                  _buildPodiumPosition(topThree[2], 3, 60),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).scale(),
    );
  }

  Widget _buildPodiumPosition(
    LeaderboardEntry entry,
    int position,
    double height,
  ) {
    final userId = context.read<LeaderboardProvider>().userProfile?.userId;
    final isCurrentUser = entry.userId == userId;

    Color getMedalColor() {
      switch (position) {
        case 1:
          return const Color(0xFFFFD700); // Gold
        case 2:
          return const Color(0xFFC0C0C0); // Silver
        case 3:
          return const Color(0xFFCD7F32); // Bronze
        default:
          return Colors.grey;
      }
    }

    return Column(
      children: [
        // Medal icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: getMedalColor().withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.emoji_events,
            color: getMedalColor(),
            size: position == 1 ? 40 : 32,
          ),
        ),
        const SizedBox(height: 8),
        // Username
        Container(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Text(
            entry.username,
            style: TextStyle(
              fontSize: position == 1 ? 14 : 12,
              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
              color: isCurrentUser ? const Color(0xFF4CAF50) : null,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        // Streak
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department,
              color: Color(0xFFFF9800),
              size: 16,
            ),
            const SizedBox(width: 2),
            Text(
              '${entry.streak}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Podium
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                getMedalColor().withOpacity(0.3),
                getMedalColor().withOpacity(0.1),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(
              color: getMedalColor().withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$position',
              style: TextStyle(
                fontSize: position == 1 ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: getMedalColor(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList(LeaderboardProvider provider) {
    final entries = provider.leaderboard;

    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No entries yet.\nComplete a workout to get on the leaderboard!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade400),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return _buildLeaderboardItem(entries[index], index);
      },
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, int index) {
    final userId = context.read<LeaderboardProvider>().userProfile?.userId;
    final isCurrentUser = entry.userId == userId;
    final isTopThree = entry.rank <= 3;

    Color getRankColor() {
      switch (entry.rank) {
        case 1:
          return const Color(0xFFFFD700); // Gold
        case 2:
          return const Color(0xFFC0C0C0); // Silver
        case 3:
          return const Color(0xFFCD7F32); // Bronze
        default:
          return Colors.grey.shade600;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isCurrentUser
            ? LinearGradient(
                colors: [
                  const Color(0xFF4CAF50).withOpacity(0.2),
                  const Color(0xFF4CAF50).withOpacity(0.05),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? const Color(0xFF4CAF50).withOpacity(0.5)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: GlassCard(
        margin: EdgeInsets.zero,
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isTopThree
                    ? getRankColor().withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: getRankColor(),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${entry.rank}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: getRankColor(),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Username and stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.username,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isCurrentUser ? FontWeight.bold : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'YOU',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.totalWorkouts} workouts • ${entry.totalExercises} exercises',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),

            // Streak
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Color(0xFFFF9800),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${entry.streak}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.2);
  }
}
