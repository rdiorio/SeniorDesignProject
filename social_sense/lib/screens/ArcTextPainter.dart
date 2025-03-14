import 'dart:math';
import 'package:flutter/material.dart';

class ArcTextPainter extends CustomPainter {
  final String text;
  final double radius;
  final double verticalOffset;
  final double fontSize;
  final String fontFamily;
  final double arcSpan;
  final double startAngle;
  final bool isClockwise;

  ArcTextPainter({
    required this.text,
    required this.radius,
    required this.verticalOffset,
    required this.fontSize,
    this.fontFamily = "Modak",
    this.arcSpan = pi, // 180-degree arc at the bottom
    this.startAngle = pi / 2, // Start at the exact bottom center
    this.isClockwise = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w100,
      fontFamily: fontFamily,
      color: Colors.white,
    );

    String reversedText = text.split('').reversed.join(); // ✅ Fix text order

    double totalTextWidth = 10;
    List<double> charWidths = [];

    for (int i = 0; i < reversedText.length; i++) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(text: reversedText[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      charWidths.add(textPainter.width);
      totalTextWidth += textPainter.width;
    }

    double currentAngle =
        startAngle - arcSpan / 2 - .15; //adjust where the text is along the arc

    for (int i = 0; i < reversedText.length; i++) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(text: reversedText[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      double x = size.width / 2 + radius * cos(currentAngle);
      double y = size.height / 2 + radius * sin(currentAngle) + verticalOffset;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(currentAngle - pi / 2); // ✅ Keeps letters upright
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();

      double charAngle = (charWidths[i] / totalTextWidth) * arcSpan * 1.3;
      currentAngle += charAngle * (isClockwise ? 1 : -1);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}