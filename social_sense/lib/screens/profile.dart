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

          // Home Button
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
                  Navigator.push(
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

          // Fetch User Data
          FutureBuilder(
            future: _getUserData(),
            builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('No user data found.'));
              }
              var userData = snapshot.data!;

              // Extract user details
              String userName =
                  "${userData['First Name']} ${userData['Last Name']}";
              String buddy = userData['buddy'] ?? "Bear"; // Default buddy
              int stars = userData['scores']['stars'] ?? 0;
              int totalPoints = userData['scores']['totalPoints'] ?? 0;
              double progress = (totalPoints % 10) / 10.0;
              String? hat = userData['currentHat'];
              String? glasses = userData['currentGlasses'];

              return Stack(
                children: [
                  // Profile Content
                  Positioned(
                    top: screenHeight * 0.17,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressBar(
                            progress: progress, // ✅ Dynamic progress value
                            size: screenWidth * 0.65,
                            strokeWidth: 18,
                          ),
                           BuddyAvatar(
                            buddy: buddy,
                            hat: hat,
                            glasses: glasses,
                            scale: screenWidth / 300,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Profile Info Section
                  Positioned(
                    top: screenHeight * 0.5,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Stars & Total Points Row
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
                                      '$stars',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  'Stars',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 40),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 11),
                                  child: Text(
                                    '$totalPoints',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Text(
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

                        // Message for next star
                        const SizedBox(height: 10),
                        Text(
                          'Earn ${10 - (totalPoints % 10)} more points to get another star!\nYou can do it!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 15),
                        buildButton(
                            context, 'View Rewards', RewardsScreen(uid: uid)),
                        buildButton(context, 'View Conversation History',
                            ConversationHistory(uid: uid)),
                      ],
                    ),
                  ),
                ],
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