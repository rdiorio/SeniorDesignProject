import 'package:flutter/material.dart';
import 'package:social_sense/screens/face_capture.dart';

class MediumEmotionsPage extends StatefulWidget {
  @override
  _MediumEmotionsPageState createState() => _MediumEmotionsPageState();
}

class _MediumEmotionsPageState extends State<MediumEmotionsPage> {
  int currentStep = 0;
  final List<Map<String, dynamic>> emotions = [
    {
      'emotion': 'happy',
      'color': Colors.yellow,
      'image': 'lib/screens/assets/happy.png'
    },
    {
      'emotion': 'sad',
      'color': Colors.blue,
      'image': 'lib/screens/assets/sad.png'
    },
    {
      'emotion': 'angry',
      'color': Colors.red,
      'image': 'lib/screens/assets/angry.png'
    },
  ];
  String feedbackMessage = '';
  bool showFaceCapture = false;
  bool isRetrying = false;

  void _checkAnswer(String selectedEmotion) {
    final correctEmotion = emotions[currentStep]['emotion'];
    if (selectedEmotion == correctEmotion) {
      setState(() {
        feedbackMessage =
            'Correct! Now practice making the ${correctEmotion} face!';
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

  void _checkEmotionFromFace(String detectedEmotion) {
    final correctEmotion = emotions[currentStep]['emotion'];
    if (detectedEmotion == correctEmotion) {
      setState(() {
        feedbackMessage =
            'Great job! You successfully made the ${correctEmotion} face!';
        isRetrying = false;
        if (currentStep < emotions.length - 1) {
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              currentStep++;
              feedbackMessage = '';
              showFaceCapture = false;
            });
          });
        } else {
          feedbackMessage = 'Lesson complete! Well done!';
        }
      });
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
        title: Text('Medium Emotions Lesson'),
        backgroundColor: Colors.brown[400],
      ),
      body: Container(
        color: currentData['color'],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                currentData['image'],
                width: 100,
              ),
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
                    color: feedbackMessage.startsWith('Correct') ||
                            feedbackMessage.startsWith('Great job')
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
      ),
    );
  }
}
