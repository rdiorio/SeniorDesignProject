// import 'package:flutter/material.dart';
// import 'package:social_sense/screens/conversation.dart';
// import 'package:social_sense/screens/home/home.dart'; // Import Home screen

// class ConversationalLessons extends StatelessWidget {
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
//                 MaterialPageRoute(builder: (context) => Home(uid: 'your_uid')),
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
//                   title: 'Greeting Conversation',
//                   subtitle: 'Practice greeting conversations interactively.',
//                   page: ConversationScreen(conversationTopic: "greeting"),
//                 ),
//                 _buildLessonTile(
//                   context,
//                   title: 'Practice asking for help!',
//                   subtitle: 'Practice greeting conversations interactively.',
//                   page: ConversationScreen(conversationTopic: "askHelp"),
//                 ),
//                 _buildLessonTile(
//                   context,
//                   title: 'Practice setting boundaries!',
//                   subtitle: 'Practice greeting conversations interactively.',
//                   page: ConversationScreen(conversationTopic: "boundaries"),
//                 ),
//                 _buildLessonTile(
//                   context,
//                   title: 'Practice being a good sport!',
//                   subtitle: 'Practice greeting conversations interactively.',
//                   page: ConversationScreen(conversationTopic: "game"),
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
import 'package:social_sense/screens/conversation.dart';
import 'package:social_sense/screens/home/home.dart'; // Import Home screen

class ConversationalLessons extends StatelessWidget {
  final String uid; // Ensure uid is passed to LessonsPage

  ConversationalLessons({required this.uid});

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
                  title: 'Greeting Conversation',
                  subtitle: 'Practice greeting conversations interactively.',
                  page: ConversationScreen(conversationTopic: "greeting"),
                ),
                _buildLessonTile(
                  context,
                  title: 'Practice asking for help!',
                  subtitle: 'Practice greeting conversations interactively.',
                  page: ConversationScreen(conversationTopic: "askHelp"),
                ),
                _buildLessonTile(
                  context,
                  title: 'Practice setting boundaries!',
                  subtitle: 'Practice greeting conversations interactively.',
                  page: ConversationScreen(conversationTopic: "boundaries"),
                ),
                _buildLessonTile(
                  context,
                  title: 'Practice being a good sport!',
                  subtitle: 'Practice greeting conversations interactively.',
                  page: ConversationScreen(conversationTopic: "game"),
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
