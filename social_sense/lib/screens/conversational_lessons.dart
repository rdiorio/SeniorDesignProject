import 'package:flutter/material.dart';
import 'package:social_sense/screens/conversation.dart';
import 'package:social_sense/screens/home/home.dart';
import 'package:social_sense/screens/ArcTextPainter.dart' as arc;
import 'package:social_sense/screens/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class ConversationalLessons extends StatefulWidget {
  final String uid;

  ConversationalLessons({required this.uid});

  @override
  _ConversationalLessonsState createState() => _ConversationalLessonsState();
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
                      (userData['scores']['totalPoints'] % 10) / 10.0;
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
                ],
              );
            },
          ),

          // "Back to Home" Button
          Positioned(
            top: screenHeight * 0.06,
            right: screenWidth * 0.05,
            child: SizedBox(
              width: screenWidth * 0.20,
              height: screenHeight * 0.035,
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
                child: Image.asset('assets/$glasses.png', width: 80, height: 40),
              ),
          ],
        ),
      ),
    );
  }
}