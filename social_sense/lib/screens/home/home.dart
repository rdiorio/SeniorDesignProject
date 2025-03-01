import 'package:flutter/material.dart';
import 'package:social_sense/services/auth.dart';
import 'package:social_sense/services/database.dart';
import 'package:social_sense/screens/information.dart';
import 'package:social_sense/screens/lessons.dart';
import 'package:social_sense/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sense/screens/speechtotext.dart'; // Import SpeechToTextScreen
import 'package:social_sense/screens/daily_checkin.dart';
import 'package:social_sense/screens/wrapper.dart';
import 'package:social_sense/screens/voice_selection.dart';

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
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/topRed_background.png'), // Path to your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground content
          Column(
            children: [
              // Transparent AppBar on top of the background image
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                leading: IconButton(
                  icon: Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InformationScreen(uid: uid),
                      ),
                    );
                  },
                ),
                actions: <Widget>[
                  TextButton.icon(
                    icon: Icon(Icons.person, color: Colors.white),
                    label: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    // onPressed: () async {
                    //   await _auth.signOut();
                    // },
                    onPressed: () async {
                      await _auth.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Wrapper()), // Ensures app resets to Wrapper
                        (route) =>
                            false, // Removes all previous screens from the stack
                      );
                    },
                  ),
                ],
              ),
              // Welcome text below the app bar
              FutureBuilder(
                future: _getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    var userData = snapshot.data as Map<String, dynamic>?;
                    print('User Data: $userData'); // Debug print
                    if (userData != null &&
                        userData.containsKey('First Name')) {
                      return Text(
                        'Welcome ${userData['First Name']}!',
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      );
                    } else {
                      return Text(
                        'Welcome!',
                        style: TextStyle(
                          fontSize: 200.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }
                  } else {
                    return Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }
                },
              ),
              // Foreground content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Lessons",
                        style: TextStyle(
                          fontSize: 60.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.yellow, // Change button color to yellow
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(0.0), // Rounded corners
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40.0,
                              vertical: 20.0), // Increase button size
                          minimumSize: Size(200.0, 60.0), // Set button size
                        ),
                        child: Text(
                          'Emotion',
                          style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ), // New "Lessons" button
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LessonsPage(), // Navigate to LessonsPage
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        child: Text('Profile'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(uid: uid),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        child: Text('Speech'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SpeechToTextScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        child: Text('Daily Check-In'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DailyCheckInScreen(uid: uid),
                            ),
                          );
                        },
                      ),
                      ElevatedButton(
                        child: Text('Pick your voice'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VoiceSelectionScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Image at the bottom left
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              'assets/animal_Lion.png', // Path to your image
              height: 200.0, // Adjust the height as needed
            ),
          ),
        ],
      ),
    );
  }
}
