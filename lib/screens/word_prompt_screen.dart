import 'package:flutter/material.dart';
import 'dart:async';
import '../models/study.dart';
import '../services/audio_service.dart';
import '../services/firebase_service.dart';
import '../services/device_info_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/record_button.dart';
import '../widgets/timer_widget.dart';
import 'thank_you_screen.dart';

class WordPromptScreen extends StatefulWidget {
  final Study study;

  const WordPromptScreen({
    super.key,
    required this.study,
  });

  @override
  State<WordPromptScreen> createState() => _WordPromptScreenState();
}

class _WordPromptScreenState extends State<WordPromptScreen> {
  int _currentWordIndex = 0;
  bool _isRecording = false;
  bool _isUploading = false;
  int _remainingTime = 20;
  StreamSubscription<int>? _timerSubscription;

  String get currentWord => widget.study.wordList[_currentWordIndex];
  String? get currentImageUrl => widget.study.imageUrls[currentWord];
  bool get isLastWord => _currentWordIndex >= widget.study.wordList.length - 1;
  int get totalWords => widget.study.wordList.length;
  int get currentWordNumber => _currentWordIndex + 1;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await AudioService.instance.hasPermission();
    if (!hasPermission) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission'),
        content: const Text(
          'This app needs microphone access to record your voice. Please grant permission in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.study.title}'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '$currentWordNumber / $totalWords',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isUploading
          ? const LoadingWidget(message: 'Uploading recording...')
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Progress bar
                  LinearProgressIndicator(
                    value: currentWordNumber / totalWords,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Instruction
                  Text(
                    'Say the word you see below:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Word Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      currentWord.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Image Display
                  if (currentImageUrl != null)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          currentImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No image available',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Timer
                  if (_isRecording)
                    TimerWidget(remainingSeconds: _remainingTime),
                  
                  const SizedBox(height: 24),
                  
                  // Record Button
                  RecordButton(
                    isRecording: _isRecording,
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Instructions
                  Text(
                    _isRecording 
                        ? 'Recording... Tap to stop or wait for auto-stop'
                        : 'Tap the microphone to start recording',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Future<void> _startRecording() async {
    try {
      setState(() {
        _isRecording = true;
        _remainingTime = 20;
      });

      // Start recording with timer
      await AudioService.instance.startRecording(
        word: currentWord,
        maxDurationSeconds: 20,
        onTimer: (remaining) {
          setState(() {
            _remainingTime = remaining;
          });
        },
        onComplete: () {
          _stopRecording();
        },
      );

      // Subscribe to timer updates
      _timerSubscription = AudioService.instance.timerStream?.listen((remaining) {
        setState(() {
          _remainingTime = remaining;
        });
      });

    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start recording: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      setState(() {
        _isRecording = false;
        _isUploading = true;
      });

      _timerSubscription?.cancel();

      // Stop recording and get result
      final recordingResult = await AudioService.instance.stopRecording();
      
      // Get device info
      final deviceInfo = await DeviceInfoService.instance.getDeviceInfo();
      
      // Upload and save recording
      await FirebaseService.instance.uploadAndSaveRecording(
        audioFile: recordingResult.file,
        studyId: widget.study.id,
        word: currentWord,
        timestamp: DateTime.now(),
        duration: recordingResult.duration,
        deviceInfo: deviceInfo,
      );

      setState(() {
        _isUploading = false;
      });

      // Move to next word or finish
      if (isLastWord) {
        _navigateToThankYou();
      } else {
        setState(() {
          _currentWordIndex++;
        });
        
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recording saved! ${totalWords - currentWordNumber} words remaining.'),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 2),
          ),
        );
      }

    } catch (e) {
      setState(() {
        _isRecording = false;
        _isUploading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save recording: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _startRecording,
          ),
        ),
      );
    }
  }

  void _navigateToThankYou() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ThankYouScreen(study: widget.study),
      ),
    );
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    super.dispose();
  }
} 