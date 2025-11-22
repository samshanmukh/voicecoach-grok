import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/glass_card.dart';
import '../services/tts_service.dart';

/// Voice Vitality Tab: After workout, record five-second voice clip
/// "How'd that feel?" Grok guesses if you're tired, dehydrated, or pumped
/// Responds funny like "Sam, you're croaking-drink water or I'll roast you harder next set"
class VoiceVitalityScreen extends StatefulWidget {
  const VoiceVitalityScreen({super.key});

  @override
  State<VoiceVitalityScreen> createState() => _VoiceVitalityScreenState();
}

class _VoiceVitalityScreenState extends State<VoiceVitalityScreen> {
  final TTSService _tts = TTSService();
  bool _isRecording = false;
  bool _isAnalyzing = false;
  VitalityResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _tts.initialize();
  }

  void _startRecording() {
    setState(() => _isRecording = true);

    // TODO: Phase 5 - Record 5 seconds of audio
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isRecording = false;
        _isAnalyzing = true;
      });

      // Simulate Grok analysis
      _simulateAnalysis();
    });
  }

  void _simulateAnalysis() {
    // Simulate API delay
    Future.delayed(const Duration(seconds: 2), () {
      final result = VitalityResult(
        status: 'Pumped',
        confidence: 85,
        feedback: "Yo, you sound FIRED UP! That's what I'm talking about! "
            "Let's keep that energy rolling. Your voice is strong - "
            "no croaking here. Water game is on point. Beast mode activated! 💪",
        recommendations: [
          'Keep hydration levels up',
          'Great energy - maintain this intensity',
          'Perfect recovery indicators',
        ],
        timestamp: DateTime.now(),
      );

      setState(() {
        _lastResult = result;
        _isAnalyzing = false;
      });

      // Read the feedback aloud
      _tts.speak(result.feedback);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Vitality'),
        actions: [
          if (_lastResult != null)
            IconButton(
              icon: Icon(
                _tts.isSpeaking ? Icons.volume_up : Icons.volume_off,
              ),
              onPressed: () {
                if (_tts.isSpeaking) {
                  _tts.stop();
                } else if (_lastResult != null) {
                  _tts.speak(_lastResult!.feedback);
                }
              },
              tooltip: 'Toggle voice',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Recording button
            GlassCard(
              gradientColors: [
                const Color(0xFFFF9800).withOpacity(0.15),
                const Color(0xFFFF9800).withOpacity(0.05),
              ],
              child: Column(
                children: [
                  if (!_isRecording && !_isAnalyzing) ...[
                    const Icon(
                      Icons.graphic_eq,
                      size: 80,
                      color: Color(0xFFFF9800),
                    ).animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 2000.ms),
                    const SizedBox(height: 16),
                    const Text(
                      'How\'d that workout feel?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to record a 5-second voice clip',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _startRecording,
                      icon: const Icon(Icons.mic),
                      label: const Text('Start Recording'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],

                  if (_isRecording) ...[
                    const Icon(
                      Icons.mic,
                      size: 80,
                      color: Colors.red,
                    ).animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 500.ms)
                        .scale(duration: 500.ms, begin: const Offset(0.9, 0.9)),
                    const SizedBox(height: 16),
                    const Text(
                      'Recording...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Speak naturally about how you feel',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],

                  if (_isAnalyzing) ...[
                    const SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Analyzing...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Grok is checking your vitals',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Results
            if (_lastResult != null) ...[
              const SizedBox(height: 24),
              _buildResultCard(_lastResult!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(VitalityResult result) {
    final statusColor = _getStatusColor(result.status);

    return GlassCard(
      gradientColors: [
        statusColor.withOpacity(0.15),
        statusColor.withOpacity(0.05),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(result.status),
                  color: statusColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.status,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${result.confidence}% confidence',
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

          // Feedback
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.record_voice_over,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.feedback,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

          // Recommendations
          if (result.recommendations.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Recommendations:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...result.recommendations.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (300 + entry.key * 100).ms);
            }),
          ],

          // Timestamp
          const SizedBox(height: 16),
          Text(
            'Analyzed at ${_formatTime(result.timestamp)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pumped':
      case 'energized':
        return const Color(0xFF4CAF50); // Green
      case 'tired':
      case 'fatigued':
        return const Color(0xFFFF9800); // Orange
      case 'dehydrated':
      case 'exhausted':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF2196F3); // Blue
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pumped':
      case 'energized':
        return Icons.bolt;
      case 'tired':
      case 'fatigued':
        return Icons.battery_alert;
      case 'dehydrated':
      case 'exhausted':
        return Icons.water_drop;
      default:
        return Icons.favorite;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

class VitalityResult {
  final String status; // e.g., "Pumped", "Tired", "Dehydrated"
  final int confidence; // 0-100
  final String feedback; // Grok's sarcastic response
  final List<String> recommendations;
  final DateTime timestamp;

  VitalityResult({
    required this.status,
    required this.confidence,
    required this.feedback,
    required this.recommendations,
    required this.timestamp,
  });
}
