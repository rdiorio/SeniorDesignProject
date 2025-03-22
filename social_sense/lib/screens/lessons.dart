import 'package:flutter/material.dart';
import 'package:social_sense/screens/emotional_lessons/easy_emotions.dart';
import 'package:social_sense/screens/emotional_lessons/medium_emotions.dart';
import 'package:social_sense/screens/emotional_lessons/hard_emotions.dart';
import 'package:social_sense/screens/home/home.dart';
import 'package:social_sense/screens/progress_bar.dart';
import 'package:social_sense/screens/ArcTextPainter.dart' as arc;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class LessonsPage extends StatefulWidget {
  final String uid;

  LessonsPage({required this.uid});

  @override
  _LessonsPageState createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
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

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                var userData = snapshot.data;
                if (userData != null) {
                  buddy = userData['buddy'] ?? "Bear";
                  progressScore =
                      (userData['scores']['totalPoints'] % 10) / 10.0;
                  stars = userData['scores']['stars'] ?? 0;
                }
              }

              return Stack(
                children: [
                  // 🐻 Buddy Image with Progress Bar
                  Positioned(
                    top: screenHeight *
                        0.15, // Moves everything slightly down to avoid the app bar overlap
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
                            size: screenWidth * 0.65,
                            strokeWidth: screenWidth * 0.045,
                          ),

                          /// ✅ Dynamic buddy image
                          Image.asset(
                            'assets/animal_$buddy.png',
                            width: screenWidth * 0.6,
                            height: screenHeight * 0.3,
                            fit: BoxFit.contain,
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
                                    style: TextStyle(
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
                          text: "Explore Emotions!",
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
                ],
              );
            },
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
                    MaterialPageRoute(
                        builder: (context) => Home(uid: widget.uid)),
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

          // ✅ Emotion Lesson Buttons (Full Width, Matching Design)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.09,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildLessonButton(
                      context,
                      "Easy Emotions",
                      "Learn basic emotions with examples.",
                      EasyEmotionsPage()),
                  buildLessonButton(
                      context,
                      "Medium Emotions",
                      "Emotions with color and picture representations.",
                      MediumEmotionsPage()),
                  buildLessonButton(
                      context,
                      "Hard Emotions",
                      "Identify emotions from only pictures.",
                      HardEmotionsPage()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ **Function to Create a Lesson Button**
  Widget buildLessonButton(
      BuildContext context, String title, String subtitle, Widget targetPage) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.008), // Adjust space between buttons
      child: SizedBox(
        width: screenWidth * 0.9, // Scale width dynamically
        height: screenHeight * 0.1, // Scale height dynamically
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(
                255, 221, 202, 235), // Light purple background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: const Color.fromARGB(200, 248, 232, 83), // Yellow border
                width: screenWidth * 0.015,
              ),
            ),
            elevation: 5,
            padding: EdgeInsets.symmetric(
                vertical:
                    screenHeight * 0.015), // Adjust text padding inside button
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetPage),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.005),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}