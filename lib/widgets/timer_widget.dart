import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int remainingSeconds;

  const TimerWidget({
    super.key,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final progress = remainingSeconds / 20.0; // Assuming max 20 seconds
    
    // Change color based on remaining time
    Color getTimerColor() {
      if (remainingSeconds <= 5) {
        return Colors.red;
      } else if (remainingSeconds <= 10) {
        return Colors.orange;
      } else {
        return const Color(0xFF4CAF50);
      }
    }

    return Column(
      children: [
        // Circular Progress Indicator
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(getTimerColor()),
              ),
            ),
            Text(
              timeText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: getTimerColor(),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Status text
        Text(
          remainingSeconds <= 5 
              ? 'Almost done!' 
              : 'Recording in progress...',
          style: TextStyle(
            fontSize: 14,
            color: getTimerColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
        
        // Linear progress bar for additional visual feedback
        const SizedBox(height: 8),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(getTimerColor()),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
} 