import 'package:flutter/material.dart';
import 'package:social_sense/screens/emotional_lessons/easy_emotions.dart';
import 'package:social_sense/screens/emotional_lessons/medium_emotions.dart';
import 'package:social_sense/screens/emotional_lessons/hard_emotions.dart';

class LessonsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lessons'),
        backgroundColor: Colors.brown[400],
      ),
      body: ListView(
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
    );
  }

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
