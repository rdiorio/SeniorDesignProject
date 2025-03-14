import 'package:flutter/material.dart';
import 'package:social_sense/screens/conversation.dart';
import 'package:social_sense/screens/home/home.dart';
import 'package:social_sense/screens/ArcTextPainter.dart' as arc;
import 'package:social_sense/screens/custom_Button.dart';
import 'package:social_sense/screens/progress_bar.dart';
import 'dart:math';

// Utility function for consistent scaling across different screen sizes
double scaleWidth(BuildContext context, double size) {
  double screenWidth = MediaQuery.of(context).size.width;
  return (size / 400.0) * screenWidth; // 400 is base reference width
}

class ConversationalLessons extends StatelessWidget {
  final String uid;

  ConversationalLessons({required this.uid});

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

          // 🐻 Bear Image with Circular Progress Bar
          Positioned(
            top: screenHeight * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressBar(
                    progress: 0.7, // TODO: Replace with actual progress value
                    size: screenWidth * 0.65, // Dynamically adjust size
                    strokeWidth: 18, // Thickness of progress bar
                  ),
                  Image.asset(
                    'assets/animal_Bear.png',
                    width: screenWidth * 0.6,
                    height: screenHeight * 0.3,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),

          // ✅ Arc Text Below Progress Bar
          Positioned(
            top: screenHeight * 0.15 +
                (screenWidth * 0.65) / 2 +
                scaleWidth(context, 20),
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              height: scaleWidth(context, 120),
              child: CustomPaint(
                painter: arc.ArcTextPainter(
                  text: "Let's Learn Together!",
                  radius: (screenWidth * 0.65) / 2 + scaleWidth(context, 30),
                  verticalOffset: scaleWidth(context, -70),
                  fontSize: scaleWidth(context, 32),
                  arcSpan: pi - pi / 2 + .3,
                  startAngle: pi - pi / 2,
                  isClockwise: true,
                ),
              ),
            ),
          ),

          // "Back to Home" Button
          Positioned(
            top: screenHeight * 0.06,
            right: screenWidth * 0.05,
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
                    MaterialPageRoute(builder: (context) => Home(uid: uid)),
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

          // ✅ Updated Grid Layout (1 Button per Row, Full Width)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.02,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double buttonHeight =
                      screenHeight * 0.12; // Adjusted button height

                  return SizedBox(
                    height: screenHeight * 0.5,
                    width: constraints.maxWidth,
                    child: GridView.builder(
                      physics:
                          NeverScrollableScrollPhysics(), // Disable scrolling
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1, // ✅ 1 button per row
                        mainAxisSpacing:
                            screenHeight * 0.010, // ✅ Space between buttons
                        childAspectRatio: 4, // ✅ Adjusts button shape
                      ),
                      itemCount: lessonButtons
                          .length, // Ensures exact number of buttons
                      itemBuilder: (context, index) {
                        return CustomButton(
                          text: lessonButtons[index]["title"]!,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConversationScreen(
                                  conversationTopic: lessonButtons[index]
                                      ["topic"]!,
                                ),
                              ),
                            );
                          },
                          // ✅ Makes button span full width
                          height: buttonHeight, // ✅ Maintains proper height
                          backgroundColor:
                              const Color.fromARGB(255, 221, 202, 235),
                          borderColor: const Color.fromARGB(202, 255, 240, 26),
                          borderWidth: scaleWidth(context, 10),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// **Lesson Button Data (Always the Same)**
  final List<Map<String, String>> lessonButtons = [
    {"title": "Greeting Conversation", "topic": "greeting"},
    {"title": "Practice Asking for Help!", "topic": "askHelp"},
    {"title": "Practice Setting Boundaries!", "topic": "boundaries"},
    {"title": "Practice Being a Good Sport!", "topic": "game"},
  ];
}