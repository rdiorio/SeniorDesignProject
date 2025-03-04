// import 'package:flutter/material.dart';
// import 'package:social_sense/screens/emotional_lessons/easy_emotions.dart';
// import 'package:social_sense/screens/emotional_lessons/medium_emotions.dart';
// import 'package:social_sense/screens/emotional_lessons/hard_emotions.dart';
// import 'package:social_sense/screens/conversation.dart';
// import 'package:social_sense/screens/home/home.dart'; // Import Home screen

// class LessonsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           SizedBox(height: 40), // Space for better UI alignment
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.brown[400], // Match app theme
//               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             ),
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => Home(uid: uid)),
//               );
//             },
//             child: Text(
//               'Back to Home',
//               style: TextStyle(fontSize: 18, color: Colors.white),
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               children: [
//                 _buildLessonTile(
//                   context,
//                   title: 'Easy Emotions',
//                   subtitle: 'Learn basic emotions with examples.',
//                   page: EasyEmotionsPage(),
//                 ),
//                 _buildLessonTile(
//                   context,
//                   title: 'Medium Emotions',
//                   subtitle: 'Emotions with color and picture representations.',
//                   page: MediumEmotionsPage(),
//                 ),
//                 _buildLessonTile(
//                   context,
//                   title: 'Hard Emotions',
//                   subtitle: 'Identify emotions from only pictures.',
//                   page: HardEmotionsPage(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLessonTile(BuildContext context,
//       {required String title, required String subtitle, required Widget page}) {
//     return ListTile(
//       title: Text(title),
//       subtitle: Text(subtitle),
//       trailing: Icon(Icons.arrow_forward),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => page),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:social_sense/screens/emotional_lessons/easy_emotions.dart';
import 'package:social_sense/screens/emotional_lessons/medium_emotions.dart';
import 'package:social_sense/screens/emotional_lessons/hard_emotions.dart';
import 'package:social_sense/screens/home/home.dart';

class LessonsPage extends StatelessWidget {
  final String uid; // Ensure uid is passed to LessonsPage

  LessonsPage({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[400],
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Home(uid: uid)), // Pass uid back to Home
              );
            },
            child: Text(
              'Back to Home',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildLessonTile(
                  context,
                  title: 'Easy Emotions',
                  subtitle: 'Learn basic emotions with examples.',
                  page: EasyEmotionsPage(),
                ),
                _buildLessonTile(
                  context,
                  title: 'Medium Emotions',
                  subtitle: 'Emotions with color and picture representations.',
                  page: MediumEmotionsPage(),
                ),
                _buildLessonTile(
                  context,
                  title: 'Hard Emotions',
                  subtitle: 'Identify emotions from only pictures.',
                  page: HardEmotionsPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // **Define `_buildLessonTile` Inside LessonsPage**
  Widget _buildLessonTile(BuildContext context,
      {required String title, required String subtitle, required Widget page}) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
