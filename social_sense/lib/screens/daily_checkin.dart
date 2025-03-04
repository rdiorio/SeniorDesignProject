// import 'package:flutter/material.dart';
// import 'package:social_sense/screens/breathing_exercises.dart';

// class DailyCheckInScreen extends StatelessWidget {
//   final String uid;
//   const DailyCheckInScreen({super.key, required this.uid});

//   void _handleEmotionSelection(BuildContext context, String emotion) {
//     if (emotion == "Sad" || emotion == "Angry") {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => BreathingExercises()),
//       );
//     } else {
//       // Handle other cases if needed
//       Navigator.of(context).pop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Daily Check-In'),
//         backgroundColor: Colors.brown[400],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'How are you feeling today?',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _handleEmotionSelection(context, "Happy"),
//               child: Text('Happy'),
//             ),
//             ElevatedButton(
//               onPressed: () => _handleEmotionSelection(context, "Sad"),
//               child: Text('Sad'),
//             ),
//             ElevatedButton(
//               onPressed: () => _handleEmotionSelection(context, "Angry"),
//               child: Text('Angry'),
//             ),
//             ElevatedButton(
//               onPressed: () => _handleEmotionSelection(context, "Calm"),
//               child: Text('Calm'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:social_sense/screens/breathing_exercises.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
//import 'package:flutter_arc_text/flutter_arc_text.dart';

class ArcText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArcTextPainter(),
      child: SizedBox(height: 50, width: 350), // Adjust size for box as needed
    );
  }
}

class ArcTextPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const String text = "How are you feeling today?";
    const double fontSize = 28;
    const double radius = 180; // Adjust for curvature
    const double verticalOffset = -200; // Moves the whole arc higher

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900, // Extra bold text
      color: Colors.black,
    );

    // Measure total width of the text
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

    double totalAngle = pi * 0.7; // Curvature
    double startAngle = totalAngle / 0.83; // Centering text

    double currentAngle = startAngle; // Track the angle dynamically

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

      // Update the angle based on the actual character width
      double charAngle = (charWidths[i] / totalTextWidth) * totalAngle;
      currentAngle -= charAngle; // Move leftward along the arc
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
        MaterialPageRoute(builder: (context) => BreathingExercises()),
      );
    } else {
      Navigator.pop(context); // Go back to home after check-in
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Ensures content is below the status bar
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/topYellow_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 1.0), // Moves everything down
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Align items from the top
              children: [
                Image.asset(
                  'assets/animal_Sloth.png',
                  width: double.infinity,
                  height: 350, // Adjust height as needed
                  fit: BoxFit.contain,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ArcText(),
                ),
                const SizedBox(height: 0), // Space between text and buttons
                // Feelings Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2, // Two columns
                    crossAxisSpacing:
                        25, // Feelings button spacing left & right
                    mainAxisSpacing:
                        25, // Feelings button spacing above & under
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    shrinkWrap: true, // Prevents excessive height use
                    childAspectRatio: 1.4, // Makes buttons more square
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
        ),
      ),
    );
  }

  Widget _buildEmotionButton(
      BuildContext context, String emotion, Color bgColor) {
    return SizedBox(
      child: ElevatedButton(
        onPressed: () => _handleEmotionSelection(context, emotion),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: Colors.black,
          padding: EdgeInsets.zero, // Ensures button does not expand
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
            side: const BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
        child: Text(emotion, textAlign: TextAlign.center),
      ),
    );
  }
}
