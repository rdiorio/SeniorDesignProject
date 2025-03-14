import 'package:flutter/material.dart';
import 'package:social_sense/screens/breathing_exercises.dart';
import 'package:social_sense/services/auth.dart';
import 'package:social_sense/screens/information.dart';
import 'package:social_sense/screens/lessons.dart';
import 'package:social_sense/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sense/screens/speechtotext.dart';
import 'package:social_sense/screens/daily_checkin.dart';
import 'package:social_sense/screens/wrapper.dart';
import 'package:social_sense/screens/voice_selection.dart';
import 'package:social_sense/screens/conversational_lessons.dart';
import 'package:social_sense/screens/custom_Button.dart';
import 'package:social_sense/screens/ArcTextPainter.dart' as arc;
import 'package:social_sense/screens/change_buddy.dart';
import 'package:social_sense/screens/progress_bar.dart';
import 'dart:math';

// Utility function for consistent scaling across different screen sizes
double scaleWidth(BuildContext context, double size) {
  double screenWidth = MediaQuery.of(context).size.width;
  return (size / 400.0) * screenWidth; // 400 is base reference width
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

          // 🐻 Bear Image with Circular Progress Bar
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
                    strokeWidth: 18,
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
            future: _getUserData(), // Fetch user data asynchronously
            builder: (context, snapshot) {
              String userName = "User"; // Default username

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child:
                        CircularProgressIndicator()); // Show loading indicator
              } else if (snapshot.hasError) {
                userName = "Error"; // If an error occurs, display "Error"
              } else if (snapshot.hasData) {
                var userData = snapshot.data as Map<String, dynamic>?;
                if (userData != null && userData.containsKey('First Name')) {
                  userName =
                      userData['First Name']; // Extract user's first name
                }
              }

              return Positioned(
                // Positioning the text relative to the progress bar
                top: screenHeight *
                        0.1 + // Moves text below the top of the screen
                    (screenWidth * 0.65) /
                        2 + // Moves text to align with the bottom of the circular progress bar
                    scaleWidth(context, 20), // Additional fine-tuned spacing

                left: 0, // Center horizontally
                right: 0, // Center horizontally

                child: SizedBox(
                  width: double.infinity, // Makes text span the full width
                  height: scaleWidth(
                      context, 120), // Sets a height for the arched text

                  child: CustomPaint(
                    painter: arc.ArcTextPainter(
                      text: "Welcome $userName!", // The welcome message text

                      radius:
                          (screenWidth * 0.65) / 2 + scaleWidth(context, 20),
                      // Defines how far text is from the center (controls curve size)

                      verticalOffset: scaleWidth(context, -60),
                      // Moves the text up or down along the arc

                      fontSize: scaleWidth(context, 32),
                      // Adjusts the size of the text dynamically

                      arcSpan: pi - pi / 2 + .3,
                      // Defines how much of the arc the text spans (90° in this case)

                      startAngle: pi - pi / 2,
                      // Sets where the text starts (bottom-center of the arc)

                      isClockwise: true,
                      // Defines if text should flow left-to-right along the arc
                    ),
                  ),
                ),
              );
            },
          ),

          // Transparent AppBar with Logout Button
          Positioned(
            top: screenHeight * 0.06, // Matches Home button's vertical position
            right: screenWidth * 0.05, // Aligns with Home button on the right
            child: SizedBox(
              width: scaleWidth(context, 100),
              height: scaleWidth(context, 35),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFF9720), // Same as Home button
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
                    fontSize: scaleWidth(context, 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // ✅ Buttons Positioned at the Bottom (One Per Row)
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
                  double buttonHeight = screenHeight * 0.10; // Adjusted height

                  return SizedBox(
                    height: screenHeight * 0.57,
                    width: constraints.maxWidth,
                    child: GridView.builder(
                      physics:
                          NeverScrollableScrollPhysics(), // Disable scrolling
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1, // ✅ 1 button per row
                        mainAxisSpacing:
                            screenHeight * 0.005, // Space between buttons
                        childAspectRatio: 4.9, // ✅ Adjusts button shape
                      ),
                      itemCount: homeButtons(context).length,
                      itemBuilder: (context, index) {
                        return CustomButton(
                          text: homeButtons(context)[index]["title"]!,
                          onPressed: homeButtons(context)[index]["onPressed"]!,
                          height: buttonHeight, // ✅ Maintains proper height
                          backgroundColor:
                              const Color.fromARGB(255, 255, 206, 206),
                          borderColor: const Color.fromARGB(255, 246, 165, 84),
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

  /// **Button Data for the Grid (Now Stacked)**
  List<Map<String, dynamic>> homeButtons(BuildContext context) => [
        {
          "title": "Emotion",
          "onPressed": () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => LessonsPage(uid: uid)))
        },
        {
          "title": "Profile",
          "onPressed": () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => ProfilePage(uid: uid)))
        },
        {
          "title": "Conversational Lessons",
          "onPressed": () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ConversationalLessons(uid: uid)))
        },
        {
          "title": "Pick your Buddy",
          "onPressed": () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => ChangeBuddy(uid: uid)))
        },
        {
          "title": "Daily Check-In",
          "onPressed": () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DailyCheckInScreen(uid: uid)))
        },
        {
          "title": "Breathing Exercise",
          "onPressed": () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BreathingExercises(uid: uid)))
        },
      ];
}