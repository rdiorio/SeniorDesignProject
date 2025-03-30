import 'package:flutter/material.dart';
import 'package:social_sense/screens/lessons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_sense/services/database.dart';
import 'package:social_sense/screens/progress_bar.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

class ResultsPage extends StatefulWidget {
  final List<int> attempts;
  final int points;
  final String uid;
  final String difficulty;

  const ResultsPage({
    Key? key,
    required this.attempts,
    required this.points,
    required this.uid,
    required this.difficulty,
  }) : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  int initialTotalPoints = 0;
  int initialStars = 0;
  int updatedTotalPoints = 0;
  int updatedStars = 0;
  int earnedStars = 0;
  double progress = 0.0;
  String buddy = "Bear";
  String? hat;
  String? glasses;
  bool isLoading = true;
  int maxScore = 0;
  final List<String> emotions = ["Happy 😄", " Sad 🥺", "Angry 😠"];

  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _loadAndUpdateScores();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadAndUpdateScores() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data() as Map<String, dynamic>;
        var scores = data['scores'] ?? {};

        setState(() {
          initialTotalPoints = scores['totalPoints'] ?? 0;
          initialStars = scores['stars'] ?? 0;
          buddy = data['buddy'] ?? "Bear";
          maxScore = scores[widget.difficulty] ?? 0;
          hat = userDoc['currentHat'];
          glasses = userDoc['currentGlasses'];
        });
        if (maxScore < widget.points) {
          await DatabaseService(uid: widget.uid)
              .updateUserScore(widget.difficulty, widget.points);
        }
      }

      await DatabaseService(uid: widget.uid)
          .updateUserScores(widget.uid, widget.points);

      DocumentSnapshot updatedDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      if (updatedDoc.exists && updatedDoc.data() != null) {
        var updatedScores =
            (updatedDoc.data() as Map<String, dynamic>)['scores'];
        updatedTotalPoints = updatedScores['totalPoints'] ?? 0;
        updatedStars = updatedScores['stars'] ?? 0;
        earnedStars = updatedStars - initialStars;
        progress = (updatedTotalPoints % 100) / 100.0;
        maxScore = updatedScores[widget.difficulty] ?? 0;

        if (earnedStars > 0) {
          _confettiController.play();
          await _audioPlayer.play(AssetSource('star_earned.wav'));
        }
      }

      setState(() => isLoading = false);
    } catch (e) {
      print("Error updating scores: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final buddyAsset = "assets/animal_$buddy.png";

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/topPurple_background.png',
              fit: BoxFit.cover,
            ),
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            earnedStars > 0
                                ? "Wow! You earned $earnedStars ${earnedStars == 1 ? 'star' : 'stars'}!"
                                : "Awesome job!",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          if (earnedStars == 0)
                            Text(
                              "${100 - ((initialTotalPoints + widget.points) % 100)} more ${(100 - (initialTotalPoints + widget.points)) % 100 == 1 ? 'point' : 'points' } to your next star!",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          const SizedBox(height: 25),
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              CircularProgressBar(
                                progress: progress,
                                size: screenWidth * 0.70,
                                strokeWidth: screenWidth * 0.045,
                              ),

                              /// 🐻 Buddy
                              Image.asset(
                                buddyAsset,
                                width: screenWidth * 0.6,
                                height: screenHeight * 0.3,
                                fit: BoxFit.contain,
                              ),

                              //Hat (if any)
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
                                  top: screenHeight * 0.075,
                                  child: Image.asset(
                                    'assets/$glasses.png',
                                    width: screenWidth * 0.25, // Scale width for more accurate size
                                    height: screenHeight * 0.1,
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
                          const SizedBox(height: 20),
                          ...List.generate(widget.attempts.length, (index) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: screenWidth * 0.7, // Shrink horizontally (adjust as needed)
                                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.003),
                                        padding: EdgeInsets.all(screenWidth * 0.03),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 220, 198, 255),
                                          borderRadius: BorderRadius.circular(screenWidth * 0.05),
                                          border: Border.all(
                                            color: Colors.deepOrangeAccent,
                                            width: screenWidth * 0.008,
                                          ),
                                        ),
                                        child: Text(
                                          '${emotions[index]}: Took ${widget.attempts[index]} ${widget.attempts[index] == 1 ? 'try' : 'tries'}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.045,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),


                          const SizedBox(height: 20),
                          Container(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF6C3),
                            borderRadius: BorderRadius.circular(screenWidth * 0.05),
                            border: Border.all(color: Colors.yellowAccent, width: screenWidth * 0.008),
                          ),
                          child: Text(
                            'You earned ${widget.points} \nMax Score: $maxScore',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                          const SizedBox(height: 20),
                          SizedBox(
                              width: screenWidth * 0.65,
                              height: screenHeight * 0.07,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => LessonsPage(uid: widget.uid)),
                                  (route) => false,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 247, 129, 51),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                                    side: BorderSide(color: Colors.yellow, width: screenWidth * 0.008),
                                  ),
                                ),
                                child: Text(
                                  'Back to Lessons',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
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
}



