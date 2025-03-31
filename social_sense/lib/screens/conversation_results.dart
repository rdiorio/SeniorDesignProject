import 'package:flutter/material.dart';
import 'package:social_sense/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sense/screens/progress_bar.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:social_sense/screens/conversational_lessons.dart';
import 'package:google_fonts/google_fonts.dart';

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
      //Get initial scores
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

      // Update scores
      await DatabaseService(uid: userUid!)
          .updateUserScores(userUid!, widget.conversationScore);

      //Get updated scores
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
                      // First line (always centered)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 201, 177, 255)
                              .withOpacity(0.85),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          children: [
                            Text(
                              earnedStars > 0
                                  ? "Wow! You did amazing!"
                                  : "Awesome job!",
                              style: GoogleFonts.baloo2(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.purple[800],
                              ),
                            ),
                            Text(
                              earnedStars > 0
                                  ? "You got $earnedStars ${earnedStars == 1 ? 'star' : 'stars'}!"
                                  : "${100 - updatedTotalPoints} ${100 - updatedTotalPoints == 1 ? 'point' : 'points'} until your next star!",
                              style: GoogleFonts.baloo2(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 25),

                      // Buddy + Progress Bar + Star
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          CircularProgressBar(
                            progress: progress,
                            size: screenWidth * 0.72,
                            strokeWidth: screenWidth * 0.045,
                          ),

                          // Buddy
                          Image.asset(
                            buddyAsset,
                            width: screenWidth * 0.6,
                            height: screenHeight * 0.3,
                            fit: BoxFit.contain,
                          ),

                          // Hat (if any)
                          if (hat != null && hat!.isNotEmpty)
                            Positioned(
                              top: screenHeight * 0.04,
                              child: Image.asset(
                                'assets/$hat.png',
                                width: screenWidth * 0.25,
                                height: screenHeight * 0.05,
                                fit: BoxFit.contain,
                              ),
                            ),

                          //Glasses (if any)
                          if (glasses != null && glasses!.isNotEmpty)
                            Positioned(
                              top: screenHeight * 0.08,
                              child: Image.asset(
                                'assets/$glasses.png',
                                width: screenWidth *
                                    0.27, // Scale width for more accurate size
                                height: screenHeight * 0.07,
                                fit: BoxFit.contain,
                              ),
                            ),

                          //Star Counter
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
                                    style: GoogleFonts.baloo2(
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

                      //  Score
                      Text(
                        "Your Score: ${widget.conversationScore}",
                        style: GoogleFonts.baloo2(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 30),

                      // Back to Lessons Button
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

          // Confetti Animation
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
            style: GoogleFonts.baloo2(
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
