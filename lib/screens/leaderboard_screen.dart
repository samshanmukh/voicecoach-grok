import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/glass_card.dart';

/// Leaderboard Tab: Global anonymous rank by streak length
/// Pull from Firebase every minute
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _isLoading = false;
  DateTime _lastUpdated = DateTime.now();

  // Mock data - Phase 4 will connect to Firebase
  final List<LeaderboardEntry> _entries = [
    LeaderboardEntry(rank: 1, username: 'FitWarrior99', streak: 127, isCurrentUser: false),
    LeaderboardEntry(rank: 2, username: 'IronGiant', streak: 98, isCurrentUser: false),
    LeaderboardEntry(rank: 3, username: 'You', streak: 45, isCurrentUser: true),
    LeaderboardEntry(rank: 4, username: 'GymRat2024', streak: 42, isCurrentUser: false),
    LeaderboardEntry(rank: 5, username: 'BeastMode', streak: 38, isCurrentUser: false),
    LeaderboardEntry(rank: 6, username: 'FlexMaster', streak: 35, isCurrentUser: false),
    LeaderboardEntry(rank: 7, username: 'SwoleBro', streak: 31, isCurrentUser: false),
    LeaderboardEntry(rank: 8, username: 'CardioQueen', streak: 28, isCurrentUser: false),
    LeaderboardEntry(rank: 9, username: 'LiftLegend', streak: 25, isCurrentUser: false),
    LeaderboardEntry(rank: 10, username: 'PumpChamp', streak: 22, isCurrentUser: false),
  ];

  @override
  void initState() {
    super.initState();
    // TODO: Phase 4 - Set up periodic Firebase refresh every minute
  }

  void _refreshLeaderboard() {
    setState(() => _isLoading = true);

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        _lastUpdated = DateTime.now();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leaderboard will sync with Firebase in Phase 4!'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshLeaderboard,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(16),
            child: GlassCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events, color: Color(0xFFFF9800)),
                      const SizedBox(width: 8),
                      const Text(
                        'Global Streak Rankings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: ${_formatTime(_lastUpdated)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Leaderboard list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                return _buildLeaderboardItem(_entries[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, int index) {
    final isTopThree = entry.rank <= 3;
    final isCurrentUser = entry.isCurrentUser;

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
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
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

            // Username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.username,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isCurrentUser ? FontWeight.bold : FontWeight.w500,
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
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'YOU',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Streak Champion',
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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class LeaderboardEntry {
  final int rank;
  final String username;
  final int streak;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.streak,
    required this.isCurrentUser,
  });
}
