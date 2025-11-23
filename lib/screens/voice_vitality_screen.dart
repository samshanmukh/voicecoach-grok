import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/voice_analysis_models.dart';
import '../services/voice_recording_service.dart';
import '../services/voice_analysis_service.dart';
import '../services/tts_service.dart';
import '../widgets/glass_card.dart';

/// Voice Vitality Tab: Post-workout voice analysis with Grok
class VoiceVitalityScreen extends StatefulWidget {
  const VoiceVitalityScreen({super.key});

  @override
  State<VoiceVitalityScreen> createState() => _VoiceVitalityScreenState();
}

class _VoiceVitalityScreenState extends State<VoiceVitalityScreen> {
  final VoiceRecordingService _recordingService = VoiceRecordingService();
  final VoiceAnalysisService _analysisService = VoiceAnalysisService();
  final TTSService _tts = TTSService();
  late stt.SpeechToText _speech;

  bool _isRecording = false;
  bool _isAnalyzing = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  VoiceAnalysisResult? _lastResult;
  String? _error;
  bool _isTTSEnabled = true;
  String _transcribedText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initialize();
  }

  Future<void> _initialize() async {
    await _tts.initialize();
    await _analysisService.initialize();

    try {
      await _recordingService.initialize();
      await _speech.initialize();
    } catch (e) {
      setState(() {
        _error = 'Microphone permission required';
      });
      print('Recording service init error: $e');
    }
  }

  Future<void> _startRecording() async {
    if (!_analysisService.hasApiKey) {
      _showApiKeyDialog();
      return;
    }

    try {
      setState(() {
        _error = null;
        _recordingSeconds = 0;
        _transcribedText = '';
      });

      await _recordingService.startRecording();

      // Start speech-to-text
      _speech.listen(
        onResult: (result) {
          setState(() {
            _transcribedText = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 5),
      );

      setState(() => _isRecording = true);

      // Start countdown timer
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingSeconds++;
        });

        // Auto-stop after 5 seconds
        if (_recordingSeconds >= 5) {
          _stopRecording();
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to start recording: $e';
        _isRecording = false;
      });
      print('Recording error: $e');
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    // Stop speech recognition
    await _speech.stop();

    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
    });

    try {
      final recording = await _recordingService.stopRecording();

      if (recording == null) {
        throw Exception('Failed to save recording');
      }

      // Analyze the transcribed text with Grok
      if (_transcribedText.isEmpty) {
        _transcribedText = 'User was silent or speech not detected';
      }

      await _analyzeVoice(_transcribedText);
    } catch (e) {
      setState(() {
        _error = 'Analysis failed: $e';
        _isAnalyzing = false;
      });
      print('Stop recording error: $e');
    }
  }

  Future<void> _analyzeVoice(String transcription) async {
    try {
      final result = await _analysisService.analyzeVoice(
        userDescription: 'User said: "$transcription" after their workout',
        workoutContext: 'Just completed a workout session. Analyze their voice vitality and energy level based on what they said.',
      );

      setState(() {
        _lastResult = result;
        _isAnalyzing = false;
        _error = null;
      });

      // Read feedback aloud if TTS is enabled
      if (_isTTSEnabled && mounted) {
        await _tts.speak(result.feedback);
      }
    } catch (e) {
      setState(() {
        _error = 'Analysis failed: $e';
        _isAnalyzing = false;
      });
      print('Analysis error: $e');
    }
  }

  Future<void> _showFeelingDialog() async {
    final feelings = [
      'Pumped and energized!',
      'Pretty good, normal',
      'A bit tired',
      'Very exhausted',
      'Thirsty/dehydrated',
    ];

    final selected = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('How do you feel?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select how you\'re feeling after your workout:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ...feelings.map((feeling) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, feeling),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(feeling),
                ),
              );
            }),
          ],
        ),
      ),
    );

    if (selected != null && mounted) {
      await _analyzeFeeling(selected);
    } else {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _analyzeFeeling(String feeling) async {
    try {
      final result = await _analysisService.analyzeVoice(
        userDescription: feeling,
        workoutContext: 'Just completed a workout session',
      );

      setState(() {
        _lastResult = result;
        _isAnalyzing = false;
        _error = null;
      });

      // Read feedback aloud if TTS is enabled
      if (_isTTSEnabled && mounted) {
        await _tts.speak(result.feedback);
      }
    } catch (e) {
      setState(() {
        _error = 'Analysis failed: $e';
        _isAnalyzing = false;
      });
      print('Analysis error: $e');
    }
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('xAI API Key Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your xAI API key to analyze with Grok:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'xai-...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            Text(
              'Get your key at: https://console.x.ai',
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
              final key = controller.text.trim();
              if (key.isNotEmpty) {
                await _analysisService.saveApiKey(key);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('API key saved!'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Vitality'),
        actions: [
          // TTS toggle
          IconButton(
            icon: Icon(
              _isTTSEnabled ? Icons.volume_up : Icons.volume_off,
            ),
            onPressed: () {
              setState(() => _isTTSEnabled = !_isTTSEnabled);
              if (!_isTTSEnabled) {
                _tts.stop();
              }
            },
            tooltip: _isTTSEnabled ? 'Disable voice' : 'Enable voice',
          ),
          // Re-read button
          if (_lastResult != null)
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: () {
                if (_isTTSEnabled) {
                  _tts.speak(_lastResult!.feedback);
                }
              },
              tooltip: 'Replay feedback',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Recording UI
            _buildRecordingCard(),

            // Error display
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],

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

  Widget _buildRecordingCard() {
    return GlassCard(
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
              'Record a 5-second voice clip\nGrok will analyze your vitality',
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
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: _recordingSeconds / 5,
                    strokeWidth: 8,
                    color: Colors.red,
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.mic,
                      size: 48,
                      color: Colors.red,
                    ).animate(onPlay: (controller) => controller.repeat())
                        .scale(duration: 500.ms, begin: const Offset(0.9, 0.9)),
                    const SizedBox(height: 8),
                    Text(
                      '$_recordingSeconds/5',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
              'Analyzing with Grok...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Checking your vitality',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(VoiceAnalysisResult result) {
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
    _recordingTimer?.cancel();
    _recordingService.dispose();
    _tts.stop();
    super.dispose();
  }
}
