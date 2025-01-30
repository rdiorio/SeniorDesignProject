import 'package:flutter/material.dart';
import 'package:social_sense/screens/face_capture.dart'; // Import FaceCaptureScreen
import 'package:social_sense/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                  builder: (context) => EasyEmotionsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class EasyEmotionsPage extends StatefulWidget {
  @override
  _EasyEmotionsPageState createState() => _EasyEmotionsPageState();
}

class _EasyEmotionsPageState extends State<EasyEmotionsPage> {
  int currentStep = 0; // Tracks which emotion we're showing
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

  // void _checkEmotionFromFace(String detectedEmotion) {
  //   final correctEmotion = emotions[currentStep]['emotion'];
  //   if (detectedEmotion == correctEmotion) {
  //     setState(() {
  //       feedbackMessage =
  //           'Great job! You successfully made the ${correctEmotion} face!';
  //       isRetrying = false;
  //       if (currentStep < emotions.length - 1) {
  //         Future.delayed(const Duration(seconds: 2), () {
  //           setState(() {
  //             currentStep++;
  //             feedbackMessage = ''; // Reset feedback for the next step
  //             showFaceCapture = false; // Reset face capture for the next step
  //           });
  //         });
  //       } else {
  //         setState(() {
  //           feedbackMessage = 'Lesson complete! Well done!';
  //         });
  //       }
  //     });
  //   } else {
  //     setState(() {
  //       feedbackMessage =
  //           'Hmm, that doesn’t look like ${correctEmotion}. Try again!';
  //       isRetrying = true; // Allow user to retry
  //     });
  //   }
  // }

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
          (scores?['easy'] ?? 0) + 10; // Award 10 points per correct answer

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

  @override
  Widget build(BuildContext context) {
    final currentData = emotions[currentStep];

    return Scaffold(
      appBar: AppBar(
        title: Text('Easy Emotions Lesson'),
        backgroundColor: Colors.brown[400],
      ),
      body: Container(
        color: currentData['color'], // Set background color
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentData['emoji'],
                    style: TextStyle(fontSize: 80), // Display the emoji
                  ),
                  SizedBox(width: 20), // Space between emoji and image
                  Image.asset(
                    currentData['image'],
                    width: 100, // Display the corresponding image
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'What emotion is this?',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              // Multiple-choice buttons
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
                    color: feedbackMessage.startsWith('Correct') ||
                            feedbackMessage.startsWith('Great job')
                        ? Colors.green
                        : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 20),
              if (showFaceCapture) // Show face capture button only after correct answer
                ElevatedButton(
                  onPressed: _startFaceCapture,
                  child: Text(isRetrying ? 'Try Again' : 'Capture Your Face'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
