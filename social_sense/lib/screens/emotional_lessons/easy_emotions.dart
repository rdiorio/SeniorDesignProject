import 'package:flutter/material.dart';
import 'package:social_sense/screens/face_capture.dart'; // Import FaceCaptureScreen
import 'package:social_sense/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EasyEmotionsPage extends StatefulWidget {
  @override
  _EasyEmotionsPageState createState() => _EasyEmotionsPageState();
}

class _EasyEmotionsPageState extends State<EasyEmotionsPage> {
  int currentStep = 0; // Tracks which emotion we're showing
  int lessonPoints = 0; // Tracks points earned in this lesson

  final List<Map<String, dynamic>> emotions = [
    {
      'emoji': '😊',
      'emotion': 'happy',
      'color': Colors.yellow,
      'image': 'lib/screens/assets/happy.png'
    },
    {
      'emoji': '😢',
      'emotion': 'sad',
      'color': Colors.blue,
      'image': 'lib/screens/assets/sad.png'
    },
    {
      'emoji': '😡',
      'emotion': 'angry',
      'color': Colors.red,
      'image': 'lib/screens/assets/angry.png'
    },
  ];

  String feedbackMessage = ''; // Feedback for the user
  bool showFaceCapture = false; // Whether to show the FaceCaptureScreen
  bool isRetrying = false; // Tracks whether the user is retrying their face

  void _checkAnswer(String selectedEmotion) {
    final correctEmotion = emotions[currentStep]['emotion'];
    if (selectedEmotion == correctEmotion) {
      setState(() {
        feedbackMessage =
            'Correct! Now practice making the ${correctEmotion} face!';
        showFaceCapture = true; // Show the face capture step
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
        feedbackMessage =
            'Could not detect emotion. Please try capturing your face again.';
      });
    }
  }

    void _checkEmotionFromFace(String detectedEmotion) async {
      final correctEmotion = emotions[currentStep]['emotion'];
      if (detectedEmotion == correctEmotion) {
          setState(() {
              feedbackMessage =
                  'Great job! You successfully made the ${correctEmotion} face!';
              lessonPoints += isRetrying ? 5 : 10; // Award 10 points if correct on first try, 5 otherwise
              isRetrying = false;
          });

          String? userUid = FirebaseAuth.instance.currentUser?.uid;
          if (userUid == null) {
              print("Error: No user signed in.");
              return;
          }

          // Update total score in the database
          Map<String, dynamic>? scores =
              await DatabaseService(uid: userUid).getUserScores();
          int newScore = (scores?['easy'] ?? 0) + (isRetrying ? 5 : 10);
          await DatabaseService(uid: userUid).updateUserScore('easy', newScore);

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


  Widget _buildEmotionButton(String emotion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () => _checkAnswer(emotion),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black, width: 3),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Text(
          emotion,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentData = emotions[currentStep];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/topPurple_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      'Points: $lessonPoints',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 150, // Match emoji size
                            height: 150, // Match emoji size
                            decoration: BoxDecoration(
                              color: currentData['color'],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black, width: 4),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            width: 150, // Match emoji size
                            height: 150, // Match emoji size
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black, width: 4),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                currentData['image'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(currentData['emoji'], style: const TextStyle(fontSize: 130)),
                      const SizedBox(height: 20),
                      const Text('What emotion is this?',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ['happy', 'sad', 'angry']
                            .map((emotion) => _buildEmotionButton(emotion))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      if (feedbackMessage.isNotEmpty)
                        Text(feedbackMessage,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      if (showFaceCapture)
                        ElevatedButton(
                          onPressed: _startFaceCapture,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.black, width: 3),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            isRetrying ? 'Try Again' : 'Capture Your Face',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
