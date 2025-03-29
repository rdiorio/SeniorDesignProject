import 'package:flutter/material.dart';
import 'package:social_sense/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sense/screens/progress_bar.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:social_sense/screens/conversational_lessons.dart';

class ConversationResults extends StatefulWidget {
  final String buddyType;
  final int conversationScore;

  const ConversationResults({
    super.key,
    required this.buddyType,
    required this.conversationScore,
  });

  @override
  _ConversationResultsState createState() => _ConversationResultsState();
}

class _ConversationResultsState extends State<ConversationResults> {
  String? userUid;
  int initialTotalPoints = 0;
  int initialStars = 0;
  int updatedTotalPoints = 0;
  int updatedStars = 0;
  double progress = 0.0;
  int earnedStars = 0;
  bool isLoading = true;
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? hat;
  String? glasses;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _initializeUserAndUpdateScores();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _initializeUserAndUpdateScores() async {
    userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid == null) return;

    try {
      // Step 1: Get initial scores
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic>? scores =
            (userDoc.data() as Map<String, dynamic>)["scores"];
        if (scores != null) {
          initialTotalPoints = scores["totalPoints"] ?? 0;
          initialStars = scores["stars"] ?? 0;
        }
        hat = userDoc['currentHat'];
        glasses = userDoc['currentGlasses'];
      }

      // Step 2: Update scores
      await DatabaseService(uid: userUid!)
          .updateUserScores(userUid!, widget.conversationScore);

      // Step 3: Get updated scores
      DocumentSnapshot updatedDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .get();
      if (updatedDoc.exists && updatedDoc.data() != null) {
        Map<String, dynamic>? updatedScores =
            (updatedDoc.data() as Map<String, dynamic>)["scores"];
        if (updatedScores != null) {
          updatedTotalPoints = updatedScores["totalPoints"] ?? 0;
          updatedStars = updatedScores["stars"] ?? 0;
          earnedStars = updatedStars - initialStars;
          progress = (updatedTotalPoints % 100) / 100.0;

          if (earnedStars > 0) {
            _confettiController.play();
            _confettiController.play();
            await _audioPlayer.play(AssetSource('star_earned.wav'));
          }
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching/updating scores: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    print("Convo_results");
    print(screenWidth);
    print(screenHeight);
    final buddyAsset = "assets/animal_${widget.buddyType}.png";

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/topPurple_background.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          if (isLoading)
            Center(child: CircularProgressIndicator())
          else
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🎉 First line (always centered)
                      Text(
                        earnedStars > 0
                            ? "Wow! You earned $earnedStars ${earnedStars == 1 ? 'star' : 'stars'}!"
                            : "Awesome job!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),

                      // 🎉 Second line (only if no stars were earned)
                      if (earnedStars == 0)
                        Text(
                          "${100 - updatedTotalPoints} ${100 - updatedTotalPoints == 1 ? 'point' : 'points'} until your next star!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      SizedBox(height: 25),

                      // 🐻 Buddy + Progress Bar + Star
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          CircularProgressBar(
                            progress: progress,
                            size: screenWidth * 0.72,
                            strokeWidth: screenWidth * 0.045,
                          ),

                          /// 🐻 Buddy
                          Image.asset(
                            buddyAsset,
                            width: screenWidth * 0.6,
                            height: screenHeight * 0.3,
                            fit: BoxFit.contain,
                          ),

                          /// 🧢 Hat (if any)
                          if (hat != null && hat!.isNotEmpty)
                            Positioned(
                              top: screenHeight * 0.02,
                              child: Image.asset(
                                'assets/$hat.png',
                                width: screenWidth * 0.25,
                                height: screenHeight * 0.05,
                                fit: BoxFit.contain,
                              ),
                            ),

                          /// 🕶️ Glasses (if any)
                          if (glasses != null && glasses!.isNotEmpty)
                            Positioned(
                              top: screenHeight * 0.06,
                              child: Image.asset(
                                'assets/$glasses.png',
                                width: screenWidth *
                                    0.3, // Scale width for more accurate size
                                height: screenHeight * 0.1,
                                fit: BoxFit.contain,
                              ),
                            ),

                          /// ⭐ Star Counter
                          Positioned(
                            top: screenHeight * -0.025,
                            child: Container(
                              width: screenWidth * 0.15,
                              height: screenHeight * 0.06,
                              alignment: Alignment.center,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/star.png',
                                    width: screenWidth * 0.15,
                                    height: screenHeight * 0.06,
                                  ),
                                  Text(
                                    '$updatedStars',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.06,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // ✅ Score
                      Text(
                        "Your Score: ${widget.conversationScore}",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 30),

                      // ✅ Back to Lessons Button
                      buildButton(
                        context,
                        'Back to Lessons',
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 🎉 Confetti Animation
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 30,
            gravity: 0.3,
          ),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, String text,
      {Widget? targetScreen, VoidCallback? onPressed}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
      child: SizedBox(
        width: screenWidth * 0.8,
        height: screenHeight * 0.065,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 242, 231, 249),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                  color: const Color.fromARGB(255, 248, 129, 74),
                  width: screenWidth * 0.015),
            ),
            elevation: 5,
          ),
          onPressed: onPressed ??
              () {
                if (targetScreen != null) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => targetScreen));
                }
              },
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
