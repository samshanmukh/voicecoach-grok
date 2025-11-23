import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../models/voice_analysis_models.dart';

/// Service for recording voice audio
class VoiceRecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;

  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;

  /// Initialize the recording service
  Future<void> initialize() async {
    // Check permissions
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }
  }

  /// Start recording audio
  Future<void> startRecording() async {
    if (_isRecording) {
      throw Exception('Already recording');
    }

    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${tempDir.path}/voice_$timestamp.m4a';

      // Check permission
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        throw Exception('Microphone permission not granted');
      }

      // Start recording
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
    } catch (e) {
      _isRecording = false;
      _currentRecordingPath = null;
      rethrow;
    }
  }

  /// Stop recording and return the recording metadata
  Future<VoiceRecording?> stopRecording() async {
    if (!_isRecording) {
      return null;
    }

    try {
      final path = await _recorder.stop();
      _isRecording = false;

      if (path == null || _currentRecordingPath == null) {
        return null;
      }

      // Get file info
      final file = File(path);
      if (!await file.exists()) {
        return null;
      }

      final fileSize = await file.length();
      print('Recording saved: $path (${fileSize} bytes)');

      final recording = VoiceRecording(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: path,
        duration: const Duration(seconds: 5), // Approximate
        timestamp: DateTime.now(),
        sampleRate: 44100,
        format: 'm4a',
      );

      return recording;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Cancel current recording
  Future<void> cancelRecording() async {
    if (_isRecording) {
      await _recorder.stop();
      _isRecording = false;

      // Delete the file
      if (_currentRecordingPath != null) {
        try {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error deleting recording: $e');
        }
      }

      _currentRecordingPath = null;
    }
  }

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  /// Dispose resources
  Future<void> dispose() async {
    if (_isRecording) {
      await cancelRecording();
    }
    await _recorder.dispose();
  }
}
