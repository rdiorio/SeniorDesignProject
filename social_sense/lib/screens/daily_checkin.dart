import 'package:flutter/material.dart';
import 'package:social_sense/screens/breathing_exercises.dart';
import 'package:social_sense/screens/home/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DailyCheckInScreen extends StatelessWidget {
  final String uid;
  const DailyCheckInScreen({super.key, required this.uid});

  // void _handleEmotionSelection(BuildContext context, String emotion) {
  //   if (emotion == "Sad" || emotion == "Angry") {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => BreathingExercises()),
  //     );
  //   } else {
  //     // Handle other cases if needed
  //   }
  // }

  void _handleEmotionSelection(BuildContext context, String emotion) async {
  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'lastCheckIn': FieldValue.serverTimestamp(), // Save current timestamp
  });

  if (emotion == "Sad" || emotion == "Angry") {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BreathingExercises()),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home(uid: uid)), // Go to home after check-in
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Check-In'),
        backgroundColor: Colors.brown[400],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleEmotionSelection(context, "Happy"),
              child: Text('Happy'),
            ),
            ElevatedButton(
              onPressed: () => _handleEmotionSelection(context, "Sad"),
              child: Text('Sad'),
            ),
            ElevatedButton(
              onPressed: () => _handleEmotionSelection(context, "Angry"),
              child: Text('Angry'),
            ),
            ElevatedButton(
              onPressed: () => _handleEmotionSelection(context, "Calm"),
              child: Text('Calm'),
            ),
          ],
        ),
      ),
    );
  }
}
