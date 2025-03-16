import 'package:flutter/material.dart';
import 'package:social_sense/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sense/screens/progress_bar.dart'; // Import custom progress bar

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
  bool isLoading = true;
  double progress = 0.0; // ✅ Progress for the progress bar

  @override
  void initState() {
    super.initState();
    _initializeUserAndUpdateScores();
  }

  void _initializeUserAndUpdateScores() async {
    userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid == null) {
      print("Error: No user signed in.");
      return;
    }

    try {
      // ✅ Step 1: Get Initial Scores
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userUid).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic>? scores = (userDoc.data() as Map<String, dynamic>)["scores"];
        if (scores != null) {
          setState(() {
            initialTotalPoints = scores["totalPoints"] ?? 0;
            initialStars = scores["stars"] ?? 0;
          });
        }
      }

      // ✅ Step 2: Update Scores
      DatabaseService dbService = DatabaseService(uid: userUid!);
      await dbService.updateUserScores(userUid!, widget.conversationScore);

      // ✅ Step 3: Fetch Updated Scores
      DocumentSnapshot updatedDoc = await FirebaseFirestore.instance.collection('users').doc(userUid).get();
      if (updatedDoc.exists && updatedDoc.data() != null) {
        Map<String, dynamic>? updatedScores = (updatedDoc.data() as Map<String, dynamic>)["scores"];
        if (updatedScores != null) {
          int newTotalPoints = updatedScores["totalPoints"] ?? 0;
          int newStars = updatedScores["stars"] ?? 0;

          setState(() {
            updatedTotalPoints = newTotalPoints;
            updatedStars = newStars;
            progress = (newTotalPoints % 10) / 10; // ✅ Normalize progress (0.0 - 1.0)
            isLoading = false; // Stop loading
          });
        }
      }
    } catch (e) {
      print("Error fetching/updating scores: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String buddyAsset = "assets/animal_${widget.buddyType}.png";

    return Scaffold(
      appBar: AppBar(
        title: Text("Conversation Results"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // ✅ Show loading spinner
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Great job!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple[400]),
                  ),
                  SizedBox(height: 20),

                  // ✅ Show the buddy
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressBar(
                        progress: progress, // ✅ Show real progress
                        size: 160,
                        strokeWidth: 12,
                      ),
                      Image.asset(buddyAsset, width: 120, height: 120),
                    ],
                  ),

                  SizedBox(height: 20),

                  // ✅ Display the conversation score
                  Text(
                    "Your Score: ${widget.conversationScore}",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 30),

                  // ✅ Show Initial Scores
                  Text(
                    "Previous Total Points: $initialTotalPoints",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    "Previous Stars: $initialStars",
                    style: TextStyle(fontSize: 18),
                  ),

                  SizedBox(height: 20),

                  // ✅ Show Updated Scores
                  Text(
                    "New Total Points: $updatedTotalPoints",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  Text(
                    "New Stars: $updatedStars",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),

                  SizedBox(height: 40),

                  // ✅ Add a button to go back home
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[400],
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Text("Back to Home", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }
}