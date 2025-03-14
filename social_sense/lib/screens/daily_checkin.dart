import 'package:flutter/material.dart';
import 'package:social_sense/screens/breathing_exercises.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:social_sense/screens/home/home.dart';

// Utility function for consistent scaling across different screen sizes
double scaleWidth(BuildContext context, double size) {
  double screenWidth = MediaQuery.of(context).size.width;
  return (size / 400.0) * screenWidth; // 400 is base reference width
}

// ArcText widget for displaying the curved question text
class ArcText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArcTextPainter(),
      child: SizedBox(height: 50, width: 350),
    );
  }
}

// Custom painter to draw the arc text
class ArcTextPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const String text = "How are you feeling today?";
    const double fontSize = 32;
    const double radius = 180;
    const double verticalOffset = -200;

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: Colors.black,
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

    double totalAngle = pi * 0.7;
    double startAngle = totalAngle / 0.83;
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

// Main Daily Check-in Screen
class DailyCheckInScreen extends StatelessWidget {
  final String uid;
  const DailyCheckInScreen({super.key, required this.uid});

  void _handleEmotionSelection(BuildContext context, String emotion) async {
    FirebaseFirestore.instance.collection('users').doc(uid).update({
      'lastCheckIn': Timestamp.now(),
    });

    if (emotion == "Sad" || emotion == "Angry" || emotion == "Frustrated") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BreathingExercises(uid: uid)),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ✅ Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/topYellow_background.png',
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // ✅ Home Button (Top Right)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: scaleWidth(context, 16),
                        right: scaleWidth(context, 16),
                      ),
                      child: SizedBox(
                        width: scaleWidth(context, 100),
                        height: scaleWidth(context, 35),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9720),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Home(uid: uid)),
                            );
                          },
                          child: Text(
                            "Home",
                            style: TextStyle(
                              fontSize: scaleWidth(context, 16),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ✅ Sloth Image
                  Image.asset(
                    'assets/animal_Sloth.png',
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.contain,
                  ),

                  // ✅ Arc Text (Curved Question)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: ArcText(),
                  ),

                  const SizedBox(height: 10),

                  // ✅ Feelings Grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 25,
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      shrinkWrap: true,
                      childAspectRatio: 1.4,
                      children: [
                        _buildEmotionButton(
                            context, "Happy", const Color(0xFFFFEE6A)),
                        _buildEmotionButton(
                            context, "Sad", const Color(0xFF99BEEE)),
                        _buildEmotionButton(
                            context, "Angry", const Color(0xFFB45E5E)),
                        _buildEmotionButton(
                            context, "Calm", const Color(0xFFFFFFFF)),
                        _buildEmotionButton(
                            context, "Excited", const Color(0xFF75CE54)),
                        _buildEmotionButton(
                            context, "Frustrated", const Color(0xFFB192CC)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionButton(
      BuildContext context, String emotion, Color bgColor) {
    return SizedBox(
      height: 80, // Adjust height as needed
      width: 180, // Adjust width as needed
      child: ElevatedButton(
        onPressed: () => _handleEmotionSelection(context, emotion),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(
              vertical: 15, horizontal: 10), // Ensures text doesn't overflow
          minimumSize: const Size(
              150, 60), // Ensures button is not constrained to square
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                20.0), // 🔥 Increase for more rounded buttons
            side: const BorderSide(
                color: Color.fromARGB(255, 137, 130, 130), width: 9.5),
          ),
        ),
        child: Text(emotion, textAlign: TextAlign.center),
      ),
    );
  }
}