import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sense/screens/rewards.dart';
import 'package:social_sense/screens/conversation_history/history_topic_menu.dart';
import 'package:social_sense/screens/home/home.dart';
import 'package:social_sense/screens/progress_bar.dart';

// Utility function for consistent scaling across different screen sizes
double scaleWidth(BuildContext context, double size) {
  double screenWidth = MediaQuery.of(context).size.width;
  return (size / 400.0) * screenWidth; // 400 is base reference width
}

class ProfilePage extends StatelessWidget {
  final String uid;
  ProfilePage({required this.uid});

  Future<Map<String, dynamic>?> _getUserData() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double buttonHeight = screenHeight * 0.10;

    return Scaffold(
      body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/bottomRed_background.png',
                fit: BoxFit.cover,
              ),
            ),

            // Profile Title (Dynamically Positioned)
            Positioned(
              top: screenHeight * 0.1,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // 🐻 Bear Image with Circular Progress Bar
            Positioned(
              top: screenHeight * 0.17,
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

            // "Home" Button (Top Right, Adjusted for SafeArea)
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
                    padding: EdgeInsets.zero,
                    elevation: 5,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home(uid: uid)),
                    );
                  },
                  child: Text(
                    "Home",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04, // Scales text size dynamically
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Profile Content
            FutureBuilder(
              future: _getUserData(),
              builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return Center(child: Text('No user data found.'));
                }
                var userData = snapshot.data!;

                return Positioned(
                  top: screenHeight * 0.5, // ✅ Adjust dynamically
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${userData['First Name']} ${userData['Last Name']}',
                        style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: Colors.black),
                      ),

                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/star.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  Text(
                                    '2',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Stars',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 40),
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 11),
                                child: Text(
                                  '25',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                'Total Points',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // New Row for the message until next star
                      SizedBox(height: 10), // Adds some spacing
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Reach 100 points and unlock a star! \n You can do it!', 
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),

                      SizedBox(height: 15),
                      buildButton(context, 'View Rewards', RewardsPage(uid: uid)),
                      buildButton(context, 'View Conversation History', ConversationHistory(uid: uid))
                    ],
                  ),
                );
              },
            ),
          ],
      ),
    );
  }

  Widget buildButton(BuildContext context, String text, Widget targetScreen) {
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