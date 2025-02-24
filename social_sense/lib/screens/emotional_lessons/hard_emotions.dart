// import 'package:flutter/material.dart';
// import 'package:social_sense/screens/face_capture.dart'; // Import FaceCaptureScreen
// import 'package:social_sense/services/database.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class HardEmotionsPage extends StatefulWidget {
//   @override
//   _HardEmotionsPageState createState() => _HardEmotionsPageState();
// }

// class _HardEmotionsPageState extends State<HardEmotionsPage> {
//   int currentStep = 0;
//   final List<Map<String, String>> emotions = [
//     {'emotion': 'happy', 'image': 'lib/screens/assets/happy.png'},
//     {'emotion': 'sad', 'image': 'lib/screens/assets/sad.png'},
//     {'emotion': 'angry', 'image': 'lib/screens/assets/angry.png'},
//   ];
//   String feedbackMessage = '';
//   bool showFaceCapture = false;
//   bool isRetrying = false;

//   void _checkAnswer(String selectedEmotion) {
//     final correctEmotion = emotions[currentStep]['emotion'];
//     if (selectedEmotion == correctEmotion) {
//       setState(() {
//         feedbackMessage =
//             'Correct! Now practice making the $correctEmotion face!';
//         showFaceCapture = true;
//       });
//     } else {
//       setState(() {
//         feedbackMessage = 'Oops! That’s not correct. Try again.';
//       });
//     }
//   }

//   Future<void> _startFaceCapture() async {
//     final detectedEmotion = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const FaceCaptureScreen()),
//     );

//     if (detectedEmotion != null) {
//       _checkEmotionFromFace(detectedEmotion.toLowerCase());
//     } else {
//       setState(() {
//         feedbackMessage = 'Could not detect emotion. Please try again.';
//       });
//     }
//   }

//   void _checkEmotionFromFace(String detectedEmotion) async {
//     final correctEmotion = emotions[currentStep]['emotion'];
//     if (detectedEmotion == correctEmotion) {
//       setState(() {
//         feedbackMessage =
//             'Great job! You successfully made the ${correctEmotion} face!';
//         isRetrying = false;
//       });

//       // ✅ Get the current user's UID
//       String? userUid = FirebaseAuth.instance.currentUser?.uid;
//       if (userUid == null) {
//         print("Error: No user signed in.");
//         return;
//       }

//       // ✅ Fetch existing score and increment
//       Map<String, dynamic>? scores =
//           await DatabaseService(uid: userUid).getUserScores();
//       int newScore =
//           (scores?['hard'] ?? 0) + 10; // Award 10 points per correct answer

//       await DatabaseService(uid: userUid).updateUserScore('hard', newScore);

//       if (currentStep < emotions.length - 1) {
//         Future.delayed(const Duration(seconds: 2), () {
//           setState(() {
//             currentStep++;
//             feedbackMessage = '';
//             showFaceCapture = false;
//           });
//         });
//       } else {
//         setState(() {
//           feedbackMessage = 'Lesson complete! Well done!';
//         });
//       }
//     } else {
//       setState(() {
//         feedbackMessage =
//             'Hmm, that doesn’t look like ${correctEmotion}. Try again!';
//         isRetrying = true;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentData = emotions[currentStep];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Hard Emotions Lesson'),
//         backgroundColor: Colors.brown[400],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(currentData['image']!, width: 150),
//             SizedBox(height: 20),
//             Text(
//               'What emotion is this?',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: ['happy', 'sad', 'angry'].map((emotion) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: ElevatedButton(
//                     onPressed: () => _checkAnswer(emotion),
//                     child: Text(emotion),
//                   ),
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 20),
//             if (feedbackMessage.isNotEmpty)
//               Text(
//                 feedbackMessage,
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: feedbackMessage.startsWith('Correct')
//                       ? Colors.green
//                       : Colors.red,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             SizedBox(height: 20),
//             if (showFaceCapture)
//               ElevatedButton(
//                 onPressed: _startFaceCapture,
//                 child: Text(isRetrying ? 'Try Again' : 'Capture Your Face'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:social_sense/screens/face_capture.dart'; // Import FaceCaptureScreen
import 'package:social_sense/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HardEmotionsPage extends StatefulWidget {
  @override
  _HardEmotionsPageState createState() => _HardEmotionsPageState();
}

class _HardEmotionsPageState extends State<HardEmotionsPage> {
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
              lessonPoints += isRetrying ? 7 : 14; // Award 10 points if correct on first try, 5 otherwise
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
          int newScore = (scores?['hard'] ?? 0) + (isRetrying ? 7 : 14);
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
                          Container(
                            width: 170,
                            height: 170,
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
