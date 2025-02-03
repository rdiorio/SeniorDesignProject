// import 'package:flutter/material.dart';
// import 'package:social_sense/services/auth.dart';
// import 'package:social_sense/screens/information.dart';
// import 'package:social_sense/screens/daily_checkin.dart';

// class Home extends StatelessWidget {
//   final AuthService _auth = AuthService();
//   final String uid;

//   Home({required this.uid});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.brown[50],
//       appBar: AppBar(
//         title: Text('Social Sense'),
//         backgroundColor: Colors.brown[400],
//         elevation: 0.0,
//         actions: <Widget>[
//           TextButton.icon(
//             icon: Icon(Icons.person, color: Colors.white),
//             label: Text(
//               'logout',
//               style: TextStyle(color: Colors.white),
//             ),
//             onPressed: () async {
//               await _auth.signOut();
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               child: Text('Update Information'),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => InformationScreen(uid: uid),
//                   ),
//                 );
//               },
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               child: Text('Daily Check-In'),
//               onPressed: () {
//                 print("Navigating to Daily Check-In with uid: $uid");
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => DailyCheckInScreen(uid: uid),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:social_sense/services/auth.dart';
import 'package:social_sense/screens/information.dart';
import 'package:social_sense/screens/daily_checkin.dart';
import 'package:social_sense/screens/face_capture.dart';
import 'package:social_sense/screens/conversation.dart'; // Import the Conversation Screen

class Home extends StatelessWidget {
  final AuthService _auth = AuthService();
  final String uid;

  Home({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text('Social Sense'),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person, color: Colors.white),
            label: Text(
              'logout',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Update Information'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InformationScreen(uid: uid),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Daily Check-In'),
              onPressed: () {
                print("Navigating to Daily Check-In with uid: $uid");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DailyCheckInScreen(uid: uid),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Capture Face Emotion'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FaceCaptureScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Greeting Conversation'),
              onPressed: () {
                _navigateToConversation(context, "greeting"); // Pass 'greeting' as the topic
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('School Conversation'),
              onPressed: () {
                _navigateToConversation(context, "school"); // Pass 'school' as the topic
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to navigate to the conversation screen
  void _navigateToConversation(BuildContext context, String conversationTopic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationScreen(conversationTopic: conversationTopic),
      ),
    );
  }
}
