import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AudioService {
  static final AudioService _instance = AudioService._internal();
  static AudioService get instance => _instance;
  AudioService._internal();

  final Record _record = Record();
  final AudioPlayer _player = AudioPlayer();
  
  Timer? _recordingTimer;
  StreamController<int>? _timerController;
  bool _isRecording = false;
  String? _currentRecordingPath;

  bool get isRecording => _isRecording;
  Stream<int>? get timerStream => _timerController?.stream;

  Future<bool> hasPermission() async {
    try {
      return await _record.hasPermission();
    } catch (e) {
      return false;
    }
  }

  Future<void> playChime() async {
    try {
      // Play a simple chime sound - you can replace this with an actual sound file
      // For now, we'll use a system beep sound or placeholder
      // await _player.play(AssetSource('sounds/chime.mp3'));
      
      // Alternative: Use a generated tone or system sound
      // For MVP, we'll just add a small delay to simulate the chime
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      // Silently fail if chime can't be played
    }
  }

  Future<String> startRecording({
    required String word,
    int maxDurationSeconds = 20,
    Function(int)? onTimer,
    Function()? onComplete,
  }) async {
    try {
      if (_isRecording) {
        throw Exception('Already recording');
      }

      // Check permission
      if (!await hasPermission()) {
        throw Exception('Microphone permission not granted');
      }

      // Create recording file path
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = path.join(tempDir.path, 'recording_${word}_$timestamp.wav');

      // Play chime before recording
      await playChime();

      // Start recording
      await _record.start(
        path: _currentRecordingPath!,
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        samplingRate: 44100,
      );

      _isRecording = true;

      // Start timer
      _timerController = StreamController<int>.broadcast();
      int remainingSeconds = maxDurationSeconds;
      
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        remainingSeconds--;
        _timerController?.add(remainingSeconds);
        onTimer?.call(remainingSeconds);

        if (remainingSeconds <= 0) {
          stopRecording().then((_) => onComplete?.call());
        }
      });

      return _currentRecordingPath!;
    } catch (e) {
      _isRecording = false;
      throw Exception('Failed to start recording: $e');
    }
  }

  Future<RecordingResult> stopRecording() async {
    try {
      if (!_isRecording) {
        throw Exception('Not currently recording');
      }

      // Stop timer
      _recordingTimer?.cancel();
      _recordingTimer = null;
      _timerController?.close();
      _timerController = null;

      // Stop recording
      final path = await _record.stop();
      _isRecording = false;

      if (path == null || _currentRecordingPath == null) {
        throw Exception('Recording path is null');
      }

      // Get file info
      final file = File(_currentRecordingPath!);
      if (!await file.exists()) {
        throw Exception('Recording file does not exist');
      }

      final fileSizeBytes = await file.length();
      final duration = await _getAudioDuration(file);

      return RecordingResult(
        file: file,
        path: _currentRecordingPath!,
        duration: duration,
        fileSizeBytes: fileSizeBytes,
      );
    } catch (e) {
      _isRecording = false;
      throw Exception('Failed to stop recording: $e');
    } finally {
      _currentRecordingPath = null;
    }
  }

  Future<double> _getAudioDuration(File audioFile) async {
    try {
      // For a more accurate duration, you might want to use a dedicated audio analysis package
      // For now, we'll estimate based on file size and encoding
      final fileSizeBytes = await audioFile.length();
      
      // Rough estimation for WAV files (44.1kHz, 16-bit, mono)
      // This is a placeholder - in production you'd want to use proper audio analysis
      const bytesPerSecond = 44100 * 2; // 44.1kHz * 16-bit / 8 bits per byte
      final estimatedDuration = fileSizeBytes / bytesPerSecond;
      
      return estimatedDuration.clamp(0.1, 20.0); // Clamp between 0.1 and 20 seconds
    } catch (e) {
      return 1.0; // Default fallback duration
    }
  }

  Future<void> playRecording(String filePath) async {
    try {
      await _player.play(DeviceFileSource(filePath));
    } catch (e) {
      throw Exception('Failed to play recording: $e');
    }
  }

  Future<void> dispose() async {
    _recordingTimer?.cancel();
    _timerController?.close();
    await _record.dispose();
    await _player.dispose();
  }
}

class RecordingResult {
  final File file;
  final String path;
  final double duration;
  final int fileSizeBytes;

  RecordingResult({
    required this.file,
    required this.path,
    required this.duration,
    required this.fileSizeBytes,
  });
} 