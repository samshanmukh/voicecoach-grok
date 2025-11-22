import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  Timer? _analysisTimer;
  String? _currentRecordingPath;

  bool get isRecording => _isRecording;

  /// Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Start continuous voice recording with periodic analysis
  Future<void> startRecording({
    required Function(Map<String, dynamic>) onAudioSegment,
    Duration segmentDuration = const Duration(seconds: 5),
  }) async {
    if (_isRecording) return;

    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission denied');
    }

    _isRecording = true;

    // Start recording segments periodically
    _analysisTimer = Timer.periodic(segmentDuration, (timer) async {
      if (_isRecording) {
        await _recordSegment(onAudioSegment);
      }
    });

    // Record the first segment immediately
    await _recordSegment(onAudioSegment);
  }

  Future<void> _recordSegment(Function(Map<String, dynamic>) onAudioSegment) async {
    try {
      // Get temporary directory for audio files
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${tempDir.path}/voice_segment_$timestamp.m4a';

      // Start recording
      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        // Record for a short duration (e.g., 3 seconds for analysis)
        await Future.delayed(const Duration(seconds: 3));

        // Stop and get the file
        final recordedPath = await _recorder.stop();

        if (recordedPath != null) {
          final file = File(recordedPath);
          final metadata = await _analyzeAudioFile(file);

          onAudioSegment({
            'path': recordedPath,
            ...metadata,
          });
        }
      }
    } catch (e) {
      print('Error recording segment: $e');
    }
  }

  /// Analyze audio file to extract basic characteristics
  Future<Map<String, dynamic>> _analyzeAudioFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final duration = await _getAudioDuration(file);

      // Basic amplitude analysis (simplified)
      final amplitudes = _extractAmplitudes(bytes);
      final avgAmplitude = amplitudes.isNotEmpty
          ? amplitudes.reduce((a, b) => a + b) / amplitudes.length
          : 0.0;
      final peakAmplitude = amplitudes.isNotEmpty
          ? amplitudes.reduce((a, b) => a > b ? a : b)
          : 0.0;

      // Detect breathing pattern (simplified heuristic)
      final breathingPattern = _detectBreathingPattern(amplitudes);

      return {
        'duration': duration,
        'fileSize': bytes.length,
        'averageAmplitude': avgAmplitude,
        'peakAmplitude': peakAmplitude,
        'breathingPattern': breathingPattern,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error analyzing audio: $e');
      return {
        'duration': 0,
        'fileSize': 0,
        'averageAmplitude': 0.0,
        'peakAmplitude': 0.0,
        'breathingPattern': 'unknown',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  List<double> _extractAmplitudes(List<int> bytes) {
    // Simplified amplitude extraction
    // In a real app, you'd use proper audio analysis libraries
    final amplitudes = <double>[];
    for (int i = 0; i < bytes.length - 1; i += 2) {
      final sample = (bytes[i] | (bytes[i + 1] << 8)).toSigned(16);
      amplitudes.add(sample.abs() / 32768.0); // Normalize to 0-1
    }
    return amplitudes;
  }

  String _detectBreathingPattern(List<double> amplitudes) {
    if (amplitudes.isEmpty) return 'unknown';

    // Simple heuristic: check amplitude variance
    final avg = amplitudes.reduce((a, b) => a + b) / amplitudes.length;
    final variance = amplitudes
        .map((a) => (a - avg) * (a - avg))
        .reduce((a, b) => a + b) / amplitudes.length;

    if (variance > 0.3) return 'irregular';
    if (variance > 0.15) return 'moderate';
    return 'steady';
  }

  Future<int> _getAudioDuration(File file) async {
    // This is a placeholder - in a real app, use a proper audio library
    // to get accurate duration
    final stats = await file.stat();
    // Rough estimate: 3 seconds of recording
    return 3000;
  }

  /// Stop recording
  Future<void> stopRecording() async {
    if (!_isRecording) return;

    _analysisTimer?.cancel();
    _analysisTimer = null;

    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }

    _isRecording = false;
    _currentRecordingPath = null;
  }

  /// Clean up resources
  void dispose() {
    stopRecording();
    _recorder.dispose();
  }
}
