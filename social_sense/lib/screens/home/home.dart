import 'package:flutter/material.dart';
import 'package:social_sense/services/auth.dart';
import 'package:social_sense/screens/information.dart';
import 'package:social_sense/screens/lessons.dart';
import 'package:social_sense/screens/profile.dart';
import 'package:social_sense/screens/daily_checkin.dart';
import 'package:social_sense/screens/wrapper.dart';
import 'package:social_sense/screens/conversational_lessons.dart';
import 'package:social_sense/screens/change_buddy.dart';
import 'package:social_sense/screens/breathing_exercises.dart';
import 'package:social_sense/screens/progress_bar.dart';
import 'package:social_sense/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

// ArcText widget for displaying the curved question text
class ArcText extends StatelessWidget {
  final String text; // Accept text as a parameter
  const ArcText({Key? key, required this.text})
      : super(key: key); // Constructor

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return CustomPaint(
      painter: ArcTextPainter(text),
      child: SizedBox(height: screenHeight * 1, width: screenWidth * .9),
    );
  }
}

class ArcTextPainter extends CustomPainter {
  final String text;
  ArcTextPainter(this.text); // Constructor to receive the 'Welcome user' text

  @override
  void paint(Canvas canvas, Size size) {
    const double fontSize = 38;

    // Adjust radius dynamically based on screen width
    final double radius = size.width * 0.55;
    final double verticalOffset = size.height * -0.15; // Adjust dynamically

    final textStyle = const TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: Colors.white,
    );

    double totalAngle = pi * 0.7;
    double startAngle = totalAngle / 0.9;
    double angleStep = totalAngle / (text.length * 1.2); // Use equal steps
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
      if (i < text.length - 1 && text[i + 1] == "l") {
        currentAngle -= angleStep * 0.8; // Reduce spacing before L
      } else if (char == "l") {
        currentAngle -= angleStep * 0.8; // Reduce space for L
      } else if (i < text.length - 1 && text[i + 1] == "m") {
        currentAngle -= angleStep * 1.2; // Increase spacing before M
      } else if (char == "m") {
        currentAngle -= angleStep * 1.2; // Increase space for M
      } else if (i < text.length - 1 && text[i + 1] == "w") {
        currentAngle -= angleStep * 1.2; // Increase spacing before W
      } else if (char == "w") {
        currentAngle -= angleStep * 1.2; // Increase space for W
      } else if (char == "W") {
        currentAngle -= angleStep * 1.2; // Increase space for uppercase W
      } else {
        currentAngle -= angleStep; // Decrease angle by equal spacing
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Home extends StatelessWidget {
  final AuthService _auth = AuthService();
  final String uid;

  Home({required this.uid});

  Future<Map<String, dynamic>?> _getUserData() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
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
              'assets/topRed_background.png',
              fit: BoxFit.cover,
            ),
          ),

          //Fetch user data
          FutureBuilder(
            future: _getUserData(),
            builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
              String userName = "User";
              String buddy = "Bear"; // Default buddy
              double progressScore = 0.0;
              int stars = 0;
              String? hat;
              String? glasses;

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                var userData = snapshot.data;
                if (userData != null && userData.containsKey('First Name')) {
                  userName = userData['First Name'];
                  buddy = userData['buddy'] ?? "Bear";
                  progressScore =
                      ((userData['scores']['totalPoints'] ?? 0) % 100) / 100.0;

                  stars = (userData['scores']['stars'] ?? 0);

                  hat = userData['currentHat'];
                  glasses = userData['currentGlasses'];
                }
              }

              //Update the buddy image & progress bar dynamically
              return Stack(
                children: [
                  //Updated buddy image & progress bar
                  Positioned(
                    top: screenHeight *
                        0.10, // Moves everything slightly down to avoid the app bar overlap
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Circular Progress Bar (Behind the Buddy)
                          CircularProgressBar(
                            progress: progressScore,
                            size: screenWidth * 0.72,
                            strokeWidth: screenWidth * 0.045,
                          ),

                          //Dynamic buddy image
                          BuddyAvatar(
                            buddy: buddy,
                            hat: hat,
                            glasses: glasses,
                            scale: screenWidth / 300,
                          ),

                          // Positioned Star & Score
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

                  //"Welcome User!" Text
                  Positioned(
                    top: screenHeight * 0.21,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      width: double.infinity,
                      height: screenWidth * 0.15,
                      child: Center(child: ArcText(text: "Welcome $userName!")),
                    ),
                  ),
                ],
              );
            },
          ),

          //Logout Button
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
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Wrapper()),
                    (route) => false,
                  );
                },
                child: Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: screenWidth * 0.0375,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          //Settings Button
          Positioned(
            top: screenHeight * 0.06,
            left: screenWidth * 0.05,
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InformationScreen(uid: uid),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.02,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildHomeButton(
                      context, "Emotion Practice", LessonsPage(uid: uid)),
                  buildHomeButton(context, "Conversational Lessons",
                      ConversationalLessons(uid: uid)),
                  buildHomeButton(context, "Breathing Exercise",
                      BreathingExercises(uid: uid)),
                  buildHomeButton(
                      context, "Pick your Buddy", ChangeBuddy(uid: uid)),
                  buildHomeButton(context, "Profile", ProfilePage(uid: uid)),
                  buildHomeButton(
                      context, "Daily Check-In", DailyCheckInScreen(uid: uid)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHomeButton(
      BuildContext context, String text, Widget targetScreen) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.005), // Reduced space between buttons
      child: SizedBox(
        width: screenWidth * 0.9, // Scales width dynamically
        height: screenHeight * 0.070, // Scales height dynamically
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 242, 231, 249),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                  color: const Color.fromARGB(255, 248, 129, 74),
                  width: screenWidth * 0.015),
            ),
            elevation: 5,
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => targetScreen));
          },
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.06, // Scales text size dynamically
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
                child:
                    Image.asset('assets/$glasses.png', width: 80, height: 40),
              ),
          ],
        ),
      ),
    );
  }
}
