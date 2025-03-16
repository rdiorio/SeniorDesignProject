import 'package:flutter/material.dart';
import 'package:social_sense/screens/conversation.dart';
import 'package:social_sense/screens/home/home.dart';
import 'package:social_sense/screens/ArcTextPainter.dart' as arc;
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
                    progress: 0.7, // Replace with actual progress value
                    size: screenWidth * 0.65,
                    strokeWidth: screenWidth * 0.045,
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
                screenWidth * 0.05,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              height: screenWidth * 0.15,
              child: CustomPaint(
                painter: arc.ArcTextPainter(
                  text: "Let's Learn Together!",
                  radius: (screenWidth * 0.65) / 2 + screenWidth * 0.05,
                  verticalOffset: screenWidth * -0.1,
                  fontSize: screenWidth * 0.08,
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
                    MaterialPageRoute(builder: (context) => Home(uid: uid)),
                  );
                },
                child: Text(
                  "Home",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // ✅ Updated Button Layout (Full Width, Rounded Rectangles)
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
        height: screenHeight * 0.085, // Scale height dynamically
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
            style: TextStyle(
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
    {"title": "Greeting Conversation", "topic": "greeting"},
    {"title": "Practice Asking for Help!", "topic": "askHelp"},
    {"title": "Practice Setting Boundaries!", "topic": "boundaries"},
    {"title": "Practice Being a Good Sport!", "topic": "game"},
  ];
}