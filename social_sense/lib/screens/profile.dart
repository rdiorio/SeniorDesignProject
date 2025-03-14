import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sense/screens/rewards.dart';
import 'package:social_sense/screens/conversation_history/history_topic_menu.dart';
import 'package:social_sense/screens/home/home.dart';

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

        // Profile Title
        Positioned(
          top: MediaQuery.of(context).padding.top + 50, // Moves below the status bar
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),

          // 🐻 Bear Image (Centered at the Top)
          Positioned(
            top: 90, // Adjust this value if needed
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/animal_Bear.png', // Make sure the path is correct
                width: 300,
                height: 400,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // "Back to Home" Button (Top Right)
          Positioned(
            top: 50,
            right: 10,
            child: Container(
              width: 150,
              height: 50,
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
                  "Back to Home",
                  style: TextStyle(
                    fontSize: 16,
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

              return Center(
                child: Container(
                  margin: EdgeInsets.only(top: 200), 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'First Name: ${userData['First Name']}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Last Name: ${userData['Last Name']}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

                      SizedBox(height: 30),

                      // View Rewards Button
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
                        height: 50, // Adjust height if needed
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9720), // Match your theme
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Smooth edges
                            ),
                            padding: EdgeInsets.zero,
                            elevation: 5,
                          ),
                          child: Text(
                            'View Rewards',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RewardsPage(uid: uid)),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 15), // Space between buttons

                      // View Conversation History Button
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9720),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.zero,
                            elevation: 5,
                          ),
                          child: Text(
                            'View Conversation History',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ConversationHistory(uid: uid)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}