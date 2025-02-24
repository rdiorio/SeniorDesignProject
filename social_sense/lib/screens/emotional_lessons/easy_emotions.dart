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

  // Function to create a styled button
Widget _buildEmotionButton(String emotion) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: ElevatedButton(
      onPressed: () => _checkAnswer(emotion),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[200], // Light purple
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners
          side: BorderSide(color: Colors.black, width: 3), // Thick border
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Button padding
      ),
      child: Text(
        emotion,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold, // Bold text
          color: Colors.black, // Black font color
        ),
      ),
    ),
  );
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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/topPurple_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rounded Color Block
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: currentData['color'],
                      borderRadius: BorderRadius.circular(20), // Rounded edges
                      border: Border.all(color: Colors.black, width: 4), // Thick border
                    ),
                  ),
                  SizedBox(width: 20), // Space between elements
                  // Rounded Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20), // Rounded edges
                      border: Border.all(color: Colors.black, width: 4), // Thick border
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20), // Match container radius
                      child: Image.asset(
                        currentData['image'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                currentData['emoji'],
                style: TextStyle(fontSize: 80), // Emoji centered below
              ),
              SizedBox(height: 20),
              Text(
                'What emotion is this?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Buttons using the custom function
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['happy', 'sad', 'angry'].map((emotion) {
                  return _buildEmotionButton(emotion);
                }).toList(),
              ),
              SizedBox(height: 20),
                if (feedbackMessage.isNotEmpty)
                  Text(
                    feedbackMessage,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold, // Bold text
                      color: Colors.black, // Black font color
                    ),
                    textAlign: TextAlign.center,
                  ),

              SizedBox(height: 20),
              if (showFaceCapture) // Styled "Capture Your Face" button
                ElevatedButton(
                  onPressed: _startFaceCapture,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[200], // Light purple
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                      side: BorderSide(color: Colors.black, width: 3), // Thick border
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    isRetrying ? 'Try Again' : 'Capture Your Face',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold, // Bold text
                      color: Colors.black, // Black font color
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