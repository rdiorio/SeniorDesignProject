import 'dart:math';
import 'package:flutter/material.dart';

class ArcTextPainter extends CustomPainter {
  final String text;
  final double radius;
  final double verticalOffset;
  final String fontFamily; // ✅ New parameter to allow custom fonts

  ArcTextPainter({
    required this.text,
    this.radius = 200,
    this.verticalOffset = 130,
    this.fontFamily = "Modak", // ✅ Default to Modak font
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double fontSize = 42;

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w100,
      fontFamily: fontFamily, // ✅ Use the custom font
      color: Colors.white,
    );

    double totalTextWidth = 1;
    List<double> charWidths = [];

    for (int i = 0; i < text.length; i++) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(text: text[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      charWidths.add(textPainter.width);
      totalTextWidth += textPainter.width;
    }

    double totalAngle = pi * 0.6;
    double startAngle = totalAngle / 0.75;
    double currentAngle = startAngle;

    for (int i = 0; i < text.length; i++) {
      String char = text[i];

      TextPainter textPainter = TextPainter(
        text: TextSpan(text: char, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      double x = size.width / 2 + radius * cos(currentAngle);
      double y =
          (size.height / 2 + radius * sin(currentAngle)) + verticalOffset;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(currentAngle - pi / 2);
      textPainter.paint(
          canvas, Offset(-textPainter.width / 9, -textPainter.height / 2));
      canvas.restore();

      double charAngle = (charWidths[i] / totalTextWidth) * totalAngle;
      currentAngle -= charAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
