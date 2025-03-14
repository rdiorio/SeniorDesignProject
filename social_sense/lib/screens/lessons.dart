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
      body: Stack (
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/topPurple_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
       
      Column(
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

          
          // This is where the bear stuff can be added ---!!
          // I am not sure how to do the fancy bar stuff either
            Center(
              child: Image.asset(
                'assets/animal_Bear.png',
                width: 200,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),

          // This is the button list

          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                // SizedBox(height: 10),
                _buildLessonTile(
                  context,
                  title: 'Easy Emotions',
                  subtitle: 'Learn basic emotions with examples.',
                  page: EasyEmotionsPage(),
                ),
                SizedBox(height: 20),
                _buildLessonTile(
                  context,
                  title: 'Medium Emotions',
                  subtitle: 'Emotions with color and picture representations.',
                  page: MediumEmotionsPage(),
                ),
                SizedBox(height: 20),
                _buildLessonTile(
                  context,
                  title: 'Hard Emotions',
                  subtitle: 'Identify emotions from only pictures.',
                  page: HardEmotionsPage(),
                ),
              ],
            ),
          ),
          ],)
 
        ],
      ),
    );
  }

// --->!!!!This is the function with subtitles!!!!
// Define `_buildLessonButton` Inside LessonsPage


Widget _buildLessonTile(BuildContext context,
     {required String title, required String subtitle, required Widget page}) {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 10.0), // Add consistent vertical padding
       child: ElevatedButton(
         style: ElevatedButton.styleFrom(
           padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(15.0), // Rounded corners
           ),
           side: BorderSide(color: const Color.fromARGB(255, 19, 128, 97), width: 5.0), // Border color and width
         ),
         onPressed: () {
           Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => page),
           );
         },
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             Text(
               title,
               style: TextStyle(
                 fontSize: 18.0,
                 fontWeight: FontWeight.bold,
               ),
             ),
             SizedBox(height: 5),
             Text(
               subtitle,
               style: TextStyle(
                 fontSize: 14.0,
               ),
             ),
           ],
         ),
       ),
     );
   }
 }