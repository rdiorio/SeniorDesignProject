import 'dart:math';
import 'package:flutter/material.dart';

class DailyCheckInScreen extends StatefulWidget {
  final String uid;
  const DailyCheckInScreen({super.key, required this.uid});

  @override
  _DailyCheckInScreenState createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  final List<Map<String, String>> emotions = [
    {'label': 'Happy', 'emoji': '😊'},
    {'label': 'Sad', 'emoji': '😢'},
    {'label': 'Angry', 'emoji': '😡'},
    {'label': 'Relaxed', 'emoji': '😌'},
  ];
  double _rotationAngle = 0.0;
  String? selectedEmotion;

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _rotationAngle += details.delta.dx / 100;
    });
  }

void _onGoPressed() {
  // Adjust rotation angle to ensure it is within 0 to 2*pi
  final adjustedAngle = (_rotationAngle % (2 * pi) + 2 * pi) % (2 * pi);

  // Calculate the index of the emotion aligned with the arrow
  final index = (adjustedAngle / (pi / 2)).round() % emotions.length;

  setState(() {
    selectedEmotion = emotions[index]['label'];
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Check-In'),
        backgroundColor: Colors.brown[400],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Spinning Wheel
                  Transform.rotate(
                    angle: _rotationAngle,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orangeAccent,
                      ),
                      child: CustomPaint(
                        painter: WheelPainter(emotions),
                      ),
                    ),
                  ),
                  // Arrow Indicator
                  Positioned(
                    top: 0,
                    child: Icon(
                      Icons.arrow_drop_down,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _onGoPressed,
            child: Text('Go!'),
          ),
          if (selectedEmotion != null)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                'You feel: $selectedEmotion',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<Map<String, String>> emotions;
  WheelPainter(this.emotions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final sweepAngle = 2 * pi / emotions.length;

    for (int i = 0; i < emotions.length; i++) {
      // Draw wheel segment
      paint.color = Colors.primaries[i % Colors.primaries.length].shade200;
      final startAngle = i * sweepAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw emoji at the edge of the wheel
      final emojiAngle = startAngle + sweepAngle / 2;
      final emojiOffset = Offset(
        center.dx + radius * 0.85 * cos(emojiAngle), // 0.85 for near edge
        center.dy + radius * 0.85 * sin(emojiAngle),
      );
      textPainter.text = TextSpan(
        text: emotions[i]['emoji'],
        style: TextStyle(
          fontSize: 24,
          color: Colors.black,
        ),
      );
      textPainter.layout();
      final emojiPaintOffset =
          emojiOffset - Offset(textPainter.width / 2, textPainter.height / 2);
      textPainter.paint(canvas, emojiPaintOffset);

      // Draw emotion label centered within the segment
      final textOffset = Offset(
        center.dx + radius * 0.5 * cos(emojiAngle), // 0.5 for inside the quarter
        center.dy + radius * 0.5 * sin(emojiAngle),
      );
      textPainter.text = TextSpan(
        text: emotions[i]['label'],
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
      textPainter.layout();
      final textPaintOffset =
          textOffset - Offset(textPainter.width / 2, textPainter.height / 2);
      textPainter.paint(canvas, textPaintOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
