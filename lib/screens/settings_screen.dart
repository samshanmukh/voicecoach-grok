import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/chat_provider.dart';
import '../providers/workout_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/gamification_provider.dart';
import '../widgets/glass_card.dart';

/// Settings and preferences screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _ttsEnabled = true;
  double _ttsSpeed = 1.0;
  double _ttsPitch = 1.0;
  bool _notificationsEnabled = true;
  bool _streakReminders = true;
  bool _achievementNotifications = true;
  String _apiKey = '';
  bool _isLoadingSettings = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ttsEnabled = prefs.getBool('tts_enabled') ?? true;
      _ttsSpeed = prefs.getDouble('tts_speed') ?? 1.0;
      _ttsPitch = prefs.getDouble('tts_pitch') ?? 1.0;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _streakReminders = prefs.getBool('streak_reminders') ?? true;
      _achievementNotifications = prefs.getBool('achievement_notifications') ?? true;
      _apiKey = prefs.getString('grok_api_key') ?? '';
      _isLoadingSettings = false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSettings) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('Account', Icons.person),
            _buildAccountSection(),
            const SizedBox(height: 24),

            // Voice & TTS Section
            _buildSectionHeader('Text-to-Speech', Icons.record_voice_over),
            _buildTTSSection(),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader('Notifications', Icons.notifications),
            _buildNotificationsSection(),
            const SizedBox(height: 24),

            // API Configuration
            _buildSectionHeader('API Configuration', Icons.key),
            _buildAPISection(),
            const SizedBox(height: 24),

            // Data & Privacy
            _buildSectionHeader('Data & Privacy', Icons.storage),
            _buildDataSection(),
            const SizedBox(height: 24),

            // About
            _buildSectionHeader('About', Icons.info),
            _buildAboutSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50), size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2);
  }

  Widget _buildAccountSection() {
    return Consumer<LeaderboardProvider>(
      builder: (context, leaderboardProvider, child) {
        final userProfile = leaderboardProvider.userProfile;

        return GlassCard(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF4CAF50).withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                title: Text(
                  userProfile?.username ?? 'Anonymous',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('User ID: ${userProfile?.userId.substring(0, 8) ?? "N/A"}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditUsernameDialog(leaderboardProvider),
                ),
              ),
              const Divider(),
              _buildStatRow('Total Workouts', '${userProfile?.totalWorkouts ?? 0}'),
              _buildStatRow('Current Streak', '${userProfile?.streak ?? 0} days'),
              _buildStatRow('Total Exercises', '${userProfile?.totalExercises ?? 0}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade400),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTTSSection() {
    return GlassCard(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Enable Text-to-Speech'),
            subtitle: const Text('Read Grok responses aloud'),
            value: _ttsEnabled,
            activeColor: const Color(0xFF4CAF50),
            onChanged: (value) {
              setState(() => _ttsEnabled = value);
              _saveSetting('tts_enabled', value);
            },
          ),
          if (_ttsEnabled) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Speech Speed: ${_ttsSpeed.toStringAsFixed(1)}x',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: _ttsSpeed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    activeColor: const Color(0xFF4CAF50),
                    onChanged: (value) {
                      setState(() => _ttsSpeed = value);
                      _saveSetting('tts_speed', value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Speech Pitch: ${_ttsPitch.toStringAsFixed(1)}x',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: _ttsPitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    activeColor: const Color(0xFF4CAF50),
                    onChanged: (value) {
                      setState(() => _ttsPitch = value);
                      _saveSetting('tts_pitch', value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return GlassCard(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: _notificationsEnabled,
            activeColor: const Color(0xFF4CAF50),
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveSetting('notifications_enabled', value);
            },
          ),
          if (_notificationsEnabled) ...[
            const Divider(),
            SwitchListTile(
              title: const Text('Streak Reminders'),
              subtitle: const Text('Daily workout reminders'),
              value: _streakReminders,
              activeColor: const Color(0xFF4CAF50),
              onChanged: (value) {
                setState(() => _streakReminders = value);
                _saveSetting('streak_reminders', value);
              },
            ),
            SwitchListTile(
              title: const Text('Achievement Notifications'),
              subtitle: const Text('Get notified when you unlock badges'),
              value: _achievementNotifications,
              activeColor: const Color(0xFF4CAF50),
              onChanged: (value) {
                setState(() => _achievementNotifications = value);
                _saveSetting('achievement_notifications', value);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAPISection() {
    final hasApiKey = _apiKey.isNotEmpty;

    return GlassCard(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              hasApiKey ? Icons.check_circle : Icons.key,
              color: hasApiKey ? const Color(0xFF4CAF50) : Colors.grey,
            ),
            title: const Text('Grok API Key'),
            subtitle: Text(
              hasApiKey
                  ? 'API key configured (${_apiKey.substring(0, 8)}...)'
                  : 'No API key set',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showEditAPIKeyDialog,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF2196F3).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Color(0xFF2196F3)),
                      SizedBox(width: 8),
                      Text(
                        'How to get your API key:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Visit https://console.x.ai\n'
                    '2. Sign in or create an account\n'
                    '3. Navigate to API Keys section\n'
                    '4. Create a new API key\n'
                    '5. Copy and paste it above',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return GlassCard(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.cloud_download, color: Color(0xFF2196F3)),
            title: const Text('Export Data'),
            subtitle: const Text('Download your workout history'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showExportDialog,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Color(0xFFF44336)),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete workouts, achievements, and settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showClearDataDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return GlassCard(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.fitness_center, color: Color(0xFF4CAF50)),
            title: Text('VoiceCoach by Grok'),
            subtitle: Text('Version 1.0.0'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'AI-powered fitness coach that analyzes your vitality from your voice, '
              'provides real-time workout guidance, and helps you achieve your fitness goals.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.code, color: Color(0xFF2196F3)),
            title: const Text('Powered by'),
            subtitle: const Text('xAI Grok API • Firebase • Flutter'),
          ),
        ],
      ),
    );
  }

  void _showEditUsernameDialog(LeaderboardProvider leaderboardProvider) {
    final controller = TextEditingController(
      text: leaderboardProvider.userProfile?.username ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Username',
            hintText: 'Enter your username',
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
              if (controller.text.trim().isNotEmpty) {
                await leaderboardProvider.updateUsername(controller.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username updated!')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditAPIKeyDialog() {
    final controller = TextEditingController(text: _apiKey);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grok API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'xai-...',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Text(
              'Get your API key from console.x.ai',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newKey = controller.text.trim();
              setState(() => _apiKey = newKey);
              await _saveSetting('grok_api_key', newKey);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API key saved!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'This feature will export your workout history, achievements, and stats to a JSON file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export feature coming soon!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your workouts, achievements, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Clear all data
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared! Restart the app to reset.'),
                    backgroundColor: Color(0xFFF44336),
                  ),
                );

                // Reload settings
                _loadSettings();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
