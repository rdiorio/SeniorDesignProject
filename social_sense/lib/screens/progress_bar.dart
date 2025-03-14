import 'dart:math';
import 'package:flutter/material.dart';

class CircularProgressBar extends StatelessWidget {
  final double progress; // Value between 0.0 (empty) and 1.0 (full)
  final double strokeWidth;
  final Color emptyColor;
  final Color progressColor;
  final double size;

  const CircularProgressBar({
    required this.progress,
    this.strokeWidth = 15,
    this.emptyColor = Colors.transparent, // No color when empty
    this.progressColor = const Color.fromARGB(255, 255, 255, 255),
    this.size = 200,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularProgressPainter(
          progress: progress,
          strokeWidth: strokeWidth,
          emptyColor: emptyColor,
          progressColor: progress > 0
              ? progressColor
              : Colors.transparent, // Only show if progress > 0
        ),
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

    canvas.drawArc(rect, -pi / 2, 2 * pi, false, backgroundPaint); // Empty arc
    if (progress > 0) {
      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false,
          progressPaint); // Progress arc
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}