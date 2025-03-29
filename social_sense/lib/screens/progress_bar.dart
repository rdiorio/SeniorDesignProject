import 'dart:math';
import 'package:flutter/material.dart';

class CircularProgressBar extends StatefulWidget {
  final double progress; // Value between 0.0 (empty) and 1.0 (full)
  final double strokeWidth;
  final Color emptyColor;
  final Color progressColor;
  final double size;

  const CircularProgressBar({
    required this.progress,
    this.strokeWidth = 15,
    this.emptyColor = Colors.grey, // Background color when empty
    this.progressColor = Colors.white,
    this.size = 200,
    Key? key,
  }) : super(key: key);

  @override
  _CircularProgressBarState createState() => _CircularProgressBarState();
}

class _CircularProgressBarState extends State<CircularProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Smooth 1-second animation
    );

    _progressAnimation =
        Tween<double>(begin: 0.0, end: widget.progress).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // Smooth easing effect
    ));

    _animationController.forward(); // Start the animation
  }

  @override
  void didUpdateWidget(CircularProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));

      _animationController.forward(from: 0.0); // Restart animation from 0
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _CircularProgressPainter(
              progress: _progressAnimation.value,
              strokeWidth: widget.strokeWidth,
              emptyColor: widget.emptyColor,
              progressColor: widget.progressColor,
            ),
          );
        },
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color emptyColor;
  final Color progressColor;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.emptyColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = emptyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = (size.width - strokeWidth) / 2;
    Rect rect = Rect.fromCircle(center: center, radius: radius);

    // Draw empty background arc
    canvas.drawArc(rect, -pi / 2, 2 * pi, false, backgroundPaint);

    // Draw animated progress arc
    if (progress > 0) {
      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
