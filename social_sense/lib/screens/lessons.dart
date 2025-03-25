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
              String buddy = "Bear";
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
                  progressScore = (userData['scores']['totalPoints'] % 10) / 10.0;
                  stars = userData['scores']['stars'] ?? 0;
                  hat = userData['currentHat'];
                  glasses = userData['currentGlasses'];
                }
              }

              return Stack(
                children: [
                  Positioned(
                    top: screenHeight * 0.15,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          CircularProgressBar(
                            progress: progressScore,
                            size: screenWidth * 0.65,
                            strokeWidth: screenWidth * 0.045,
                          ),
                          BuddyAvatar(
                            buddy: buddy,
                            hat: hat,
                            glasses: glasses,
                            scale: screenWidth / 300,
                          ),
                          Positioned(
                            top: screenHeight * -0.025,
                            child: Container(
                              width: screenWidth * 0.15,
                              height: screenHeight * 0.06,
                              alignment: Alignment.center,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/star.png',
                                    width: screenWidth * 0.15,
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

                  Positioned(
                    top: screenHeight * 0.15 + (screenWidth * 0.65) / 2 + screenWidth * 0.05,
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
                          isClockwise: true,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

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
                    MaterialPageRoute(builder: (context) => Home(uid: widget.uid)),
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

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.075,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subheading for Easy Lessons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Text(
                      "Learn basic emotions with examples.",
                      style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  buildLessonButton(context, "Easy Emotions", EasyEmotionsPage()),

                  // Subheading for Medium Lessons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Text(
                      "Emotions with color and picture representations.",
                      style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  buildLessonButton(context, "Medium Emotions", MediumEmotionsPage()),

                  // Subheading for Hard Lessons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Text(
                      "Identify emotions from only pictures.",
                      style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  buildLessonButton(context, "Hard Emotions", HardEmotionsPage()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLessonButton(BuildContext context, String title, Widget targetPage) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.009),
      child: SizedBox(
        width: screenWidth * 0.9,
        height: screenHeight * 0.075,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 221, 202, 235),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: const Color.fromARGB(200, 248, 232, 83),
                width: screenWidth * 0.015,
              ),
            ),
            elevation: 5,
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetPage),
            );
          },
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
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
