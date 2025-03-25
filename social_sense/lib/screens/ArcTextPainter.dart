import 'dart:math';
import 'package:flutter/material.dart';

class ArcTextPainter extends CustomPainter {
  final String text;
  final double radius;
  final double verticalOffset;
  final double fontSize;
  final String fontFamily; 
  final double startAngle;
  final bool isClockwise;

  ArcTextPainter({
    required this.text,
    required this.radius,
    required this.verticalOffset,
    required this.fontSize,
    this.fontFamily = "Roboto",
    this.startAngle = (pi * 0.7) / 0.83,
    this.isClockwise = true,
  });
   
  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      fontFamily: fontFamily,
      color: Colors.white,
    );

    double totalTextWidth = 0;
    List<double> charWidths = [];

    for (int i = 0; i < text.length; i++) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(text: text[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      charWidths.add(textPainter.width);
      totalTextWidth += textPainter.width;
    }  

    double currentAngle = startAngle;

    for (int i = 0; i < text.length; i++) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(text: text[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      double x = size.width / 2 + radius * cos(currentAngle);
      double y = (size.height / 2 + radius * sin(currentAngle)) + verticalOffset;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(currentAngle - pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 9, -textPainter.height / 2));
      canvas.restore();

      double charAngle = (charWidths[i] / totalTextWidth) * (pi * 0.7);
      currentAngle -= charAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
