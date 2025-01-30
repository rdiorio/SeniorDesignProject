import 'package:flutter/material.dart';
import 'package:social_sense/screens/face_capture.dart'; // Import FaceCaptureScreen
import 'package:social_sense/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HardEmotionsPage extends StatefulWidget {
  @override
  _HardEmotionsPageState createState() => _HardEmotionsPageState();
}

class _HardEmotionsPageState extends State<HardEmotionsPage> {
  int currentStep = 0;
  final List<Map<String, String>> emotions = [
    {'emotion': 'happy', 'image': 'lib/screens/assets/happy.png'},
    {'emotion': 'sad', 'image': 'lib/screens/assets/sad.png'},
    {'emotion': 'angry', 'image': 'lib/screens/assets/angry.png'},
  ];
  String feedbackMessage = '';
  bool showFaceCapture = false;
  bool isRetrying = false;

  void _checkAnswer(String selectedEmotion) {
    final correctEmotion = emotions[currentStep]['emotion'];
    if (selectedEmotion == correctEmotion) {
      setState(() {
        feedbackMessage =
            'Correct! Now practice making the $correctEmotion face!';
        showFaceCapture = true;
      });
    } else {
      setState(() {
        feedbackMessage = 'Oops! That’s not correct. Try again.';
      });
    }
  }

  Future<void> _startFaceCapture() async {
    final detectedEmotion = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FaceCaptureScreen()),
    );

    if (detectedEmotion != null) {
      _checkEmotionFromFace(detectedEmotion.toLowerCase());
    } else {
      setState(() {
        feedbackMessage = 'Could not detect emotion. Please try again.';
      });
    }
  }

  void _checkEmotionFromFace(String detectedEmotion) async {
    final correctEmotion = emotions[currentStep]['emotion'];
    if (detectedEmotion == correctEmotion) {
      setState(() {
        feedbackMessage =
            'Great job! You successfully made the ${correctEmotion} face!';
        isRetrying = false;
      });

      // ✅ Get the current user's UID
      String? userUid = FirebaseAuth.instance.currentUser?.uid;
      if (userUid == null) {
        print("Error: No user signed in.");
        return;
      }

      // ✅ Fetch existing score and increment
      Map<String, dynamic>? scores =
          await DatabaseService(uid: userUid).getUserScores();
      int newScore =
          (scores?['hard'] ?? 0) + 10; // Award 10 points per correct answer

      await DatabaseService(uid: userUid).updateUserScore('hard', newScore);

      if (currentStep < emotions.length - 1) {
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            currentStep++;
            feedbackMessage = '';
            showFaceCapture = false;
          });
        });
      } else {
        setState(() {
          feedbackMessage = 'Lesson complete! Well done!';
        });
      }
    } else {
      setState(() {
        feedbackMessage =
            'Hmm, that doesn’t look like ${correctEmotion}. Try again!';
        isRetrying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentData = emotions[currentStep];

    return Scaffold(
      appBar: AppBar(
        title: Text('Hard Emotions Lesson'),
        backgroundColor: Colors.brown[400],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(currentData['image']!, width: 150),
            SizedBox(height: 20),
            Text(
              'What emotion is this?',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['happy', 'sad', 'angry'].map((emotion) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () => _checkAnswer(emotion),
                    child: Text(emotion),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            if (feedbackMessage.isNotEmpty)
              Text(
                feedbackMessage,
                style: TextStyle(
                  fontSize: 20,
                  color: feedbackMessage.startsWith('Correct')
                      ? Colors.green
                      : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 20),
            if (showFaceCapture)
              ElevatedButton(
                onPressed: _startFaceCapture,
                child: Text(isRetrying ? 'Try Again' : 'Capture Your Face'),
              ),
          ],
        ),
      ),
    );
  }
}
