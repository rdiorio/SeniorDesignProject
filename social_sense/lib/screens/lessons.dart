import 'package:flutter/material.dart';
import 'package:social_sense/screens/easy_emotions.dart'; // Import the EasyEmotionsPage

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
          ListTile(
            title: Text('Easy Emotions'),
            subtitle: Text('Learn basic emotions with examples.'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EasyEmotionsPage(), // Navigate to EasyEmotionsPage
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
