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
import 'package:social_sense/screens/ArcTextPainter.dart' as arc;
import 'dart:math';

class Home extends StatelessWidget {
  final AuthService _auth = AuthService();
  final String uid;

  Home({required this.uid});

  Future<Map<String, dynamic>?> _getUserData() async {
    return null; // Replace with Firestore user fetch logic if needed
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
          Positioned(
            top: screenHeight * 0.1,
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
          FutureBuilder(
            future: _getUserData(),
            builder: (context, snapshot) {
              String userName = "User"; // Default username

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                var userData = snapshot.data as Map<String, dynamic>?;
                if (userData != null && userData.containsKey('First Name')) {
                  userName = userData['First Name'];
                }
              }

              return Positioned(
                top: screenHeight * 0.1 +
                    (screenWidth * 0.65) / 2 +
                    screenWidth * 0.05,
                left: 0,
                right: 0,
                child: SizedBox(
                  width: double.infinity,
                  height: screenWidth * 0.15,
                  child: CustomPaint(
                    painter: arc.ArcTextPainter(
                      text: "Welcome $userName!",
                      radius: (screenWidth * 0.65) / 2 + screenWidth * 0.05,
                      verticalOffset: screenWidth * -0.1,
                      fontSize: screenWidth * 0.08,
                      arcSpan: pi - pi / 2 + .3,
                      startAngle: pi - pi / 2,
                      isClockwise: true,
                    ),
                  ),
                ),
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
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
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
                  buildHomeButton(context, "Emotion", LessonsPage(uid: uid)),
                  buildHomeButton(context, "Profile", ProfilePage(uid: uid)),
                  buildHomeButton(context, "Conversational Lessons",
                      ConversationalLessons(uid: uid)),
                  buildHomeButton(
                      context, "Pick your Buddy", ChangeBuddy(uid: uid)),
                  buildHomeButton(
                      context, "Daily Check-In", DailyCheckInScreen(uid: uid)),
                  buildHomeButton(context, "Breathing Exercise",
                      BreathingExercises(uid: uid)),
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
        height: screenHeight * 0.075, // Scales height dynamically
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