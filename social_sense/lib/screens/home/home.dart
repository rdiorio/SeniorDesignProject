// import 'package:flutter/material.dart';
// import 'package:social_sense/services/auth.dart';
// import 'package:social_sense/screens/information.dart';
// import 'package:social_sense/screens/daily_checkin.dart';
// import 'package:social_sense/screens/face_capture.dart';

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
//             SizedBox(height: 20),
//             ElevatedButton(
//               child: Text('Capture Face Emotion'),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => FaceCaptureScreen(),
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
import 'package:social_sense/screens/lessons.dart'; // Import the LessonsPage

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
              child: Text('Lessons'), // New "Lessons" button
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
          ],
        ),
      ),
    );
  }
}
