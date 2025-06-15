import 'package:flutter/material.dart';

class RecordButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onPressed;

  const RecordButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
  });

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(RecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isRecording && !oldWidget.isRecording) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isRecording ? _scaleAnimation.value : 1.0,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isRecording ? Colors.red : const Color(0xFF4CAF50),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isRecording ? Colors.red : const Color(0xFF4CAF50))
                        .withOpacity(0.3),
                    spreadRadius: widget.isRecording ? _pulseAnimation.value * 10 : 5,
                    blurRadius: widget.isRecording ? _pulseAnimation.value * 15 : 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                widget.isRecording ? Icons.stop : Icons.mic,
                size: widget.isRecording ? 40 : 48,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
} 