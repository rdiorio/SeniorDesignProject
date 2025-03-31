import 'package:flutter/material.dart';
import 'package:social_sense/screens/conversation.dart';
import 'package:social_sense/screens/home/home.dart';
import 'package:social_sense/screens/ArcTextPainter.dart' as arc;
import 'package:social_sense/screens/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

class ConversationalLessons extends StatefulWidget {
  final String uid;

  ConversationalLessons({required this.uid});

  @override
  _ConversationalLessonsState createState() => _ConversationalLessonsState();
}

// ArcText widget for displaying the curved question text
class ArcText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return CustomPaint(
      painter: ArcTextPainter(),
      child: SizedBox(height: screenHeight * .02, width: screenWidth * .9),
    );
  }
}

class ArcTextPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const String text = "Let's Learn Together!";
    const double fontSize = 38;

    // Adjust radius dynamically based on screen width
    final double radius = size.width * 0.55;
    final double verticalOffset = size.height * -0.15; // Adjust dynamically

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
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

    double totalAngle = pi * 0.7;
    double startAngle = totalAngle / 0.83;
    double angleStep = totalAngle / (text.length - 1); // Use equal steps
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
          canvas,
          Offset(
              -textPainter.width / 2, -textPainter.height / 2)); // Center align
      canvas.restore();

      //currentAngle -= angleStep; // Decrease angle by equal spacing
      // Check if the *next* character is an apostrophe and reduce space
      if (i < text.length - 1 && text[i + 1] == "'") {
        currentAngle -= angleStep * 0.7; // Reduce spacing before apostrophe
      } else if (char == "'") {
        currentAngle -= angleStep * 0.7; // Reduce space for apostrophe
      } else {
        currentAngle -= angleStep; // Decrease angle by equal spacing
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConversationalLessonsState extends State<ConversationalLessons> {
  Future<Map<String, dynamic>?> _getUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();
    return userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/topPurple_background.png',
              fit: BoxFit.cover,
            ),
          ),

          FutureBuilder(
            future: _getUserData(),
            builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
              String buddy = "Bear"; // Default buddy
              double progressScore = 0.0;
              int stars = 0;
              String? hat;
              String? glasses;

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                var userData = snapshot.data;
                if (userData != null) {
                  buddy = userData['buddy'] ?? "Bear";
                  progressScore =
                      (userData['scores']['totalPoints'] % 100) / 100.0;
                  stars = userData['scores']['stars'] ?? 0;
                  hat = userData['currentHat'];
                  glasses = userData['currentGlasses'];
                }
              }

              return Stack(
                children: [
                  // 🐻 Buddy Image with Progress Bar
                  Positioned(
                    top: screenHeight *
                        0.12, // Moves everything slightly down to avoid the app bar overlap
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          /// ✅ Circular Progress Bar (Behind the Buddy)
                          CircularProgressBar(
                            progress: progressScore,
                            size: screenWidth * 0.72,
                            strokeWidth: screenWidth * 0.045,
                          ),

                          /// ✅ Dynamic buddy image
                          BuddyAvatar(
                            buddy: buddy,
                            hat: hat,
                            glasses: glasses,
                            scale: screenWidth / 300,
                          ),

                          /// ⭐ Positioned Star & Score
                          Positioned(
                            top: screenHeight *
                                -0.025, // Slightly lower to avoid getting cut off
                            child: Container(
                              // Ensures star doesn't get clipped
                              width:
                                  screenWidth * 0.15, // Matches the star's size
                              height: screenHeight * 0.06,
                              alignment: Alignment.center,
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/star.png',
                                    width: screenWidth *
                                        0.15, // Adjusted star size
                                    height: screenHeight * 0.06,
                                  ),
                                  Text(
                                    '$stars',
                                    style: GoogleFonts.baloo2(
                                      fontSize: screenWidth * 0.06,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // "Home" Button
          Positioned(
            top: screenHeight * 0.06,
            right: screenWidth * 0.05,
            child: SizedBox(
              width: screenWidth * 0.25,
              height: screenHeight * 0.05,
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
                        builder: (context) => Home(uid: widget.uid)),
                  );
                },
                child: Text(
                  "Home",
                  style: GoogleFonts.baloo2(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
// ✅ Arc Text (Curved Question)
          Positioned(
            top: screenHeight * 0.26, // Adjust as needed to bring it into view
            left: 0,
            right: 0,
            child: Center(child: ArcText()),
          ),

          // ✅ Lesson Buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.05, // move buttons up or down
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: lessonButtons.map((button) {
                  return buildLessonButton(
                    context,
                    button["title"]!,
                    button["topic"]!,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ **Function to Create a Lesson Button**
  Widget buildLessonButton(BuildContext context, String text, String topic) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.009), // Adjust space between buttons
      child: SizedBox(
        width: screenWidth * 0.9, // Scale width dynamically
        height: screenHeight * 0.08, // Scale height dynamically
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(
                255, 221, 202, 235), // Light purple background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: const Color.fromARGB(202, 255, 240, 26), // Yellow border
                width: screenWidth * 0.015,
              ),
            ),
            elevation: 5,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ConversationScreen(conversationTopic: topic),
              ),
            );
          },
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.baloo2(
              fontSize: screenWidth * 0.06, // Scale text size dynamically
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ **Lesson Button Data**
  final List<Map<String, String>> lessonButtons = [
    {"title": "Practice Greeting!", "topic": "greeting"},
    {"title": "Practice Asking for Help!", "topic": "askHelp"},
    {"title": "Practice Setting Boundaries!", "topic": "boundaries"},
    {"title": "Practice Being a Good Sport!", "topic": "game"},
  ];
}

class BuddyAvatar extends StatelessWidget {
  final String buddy;
  final String? hat;
  final String? glasses;
  final double scale;

  const BuddyAvatar({
    super.key,
    required this.buddy,
    this.hat,
    this.glasses,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/animal_$buddy.png', width: 200, height: 200),
            if (hat != null && hat!.isNotEmpty)
              Positioned(
                top: 10,
                child: Image.asset('assets/$hat.png', width: 100, height: 40),
              ),
            if (glasses != null && glasses!.isNotEmpty)
              Positioned(
                top: 50,
                child:
                    Image.asset('assets/$glasses.png', width: 80, height: 40),
              ),
          ],
        ),
      ),
    );
  }
}
