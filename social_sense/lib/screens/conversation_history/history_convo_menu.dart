import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:social_sense/services/database.dart';
import 'package:social_sense/screens/conversation_history/conversation_log.dart';
import 'package:social_sense/screens/conversation_history/pieChart.dart';
import 'package:social_sense/screens/conversation_history/progression.dart';

class HistoryConvoMenu extends StatefulWidget {
  final String uid;
  final String topic;

  HistoryConvoMenu({required this.uid, required this.topic});

  @override
  _HistoryConvoMenuState createState() => _HistoryConvoMenuState();
}

class _HistoryConvoMenuState extends State<HistoryConvoMenu> {
  List<Map<String, dynamic>> conversations = [];
  bool isLoading = true;
  List<int> scores = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  // Fetch actual data from Firestore
  void _loadConversations() async {
    DatabaseService dbService = DatabaseService(uid: widget.uid);
    List<Map<String, dynamic>> fetchedConversations =
        await dbService.getConversations(widget.topic);

    setState(() {
      conversations = fetchedConversations;
      scores.clear(); // Ensure the list is reset before adding new values
      scores.addAll(fetchedConversations.map((c) => c["score"] ?? 0));
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.topic} Conversation History")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Show loading indicator while fetching data
            if (isLoading)
              Expanded(child: Center(child: CircularProgressIndicator()))
            else if (conversations.isEmpty)
              Expanded(
                child: Center(
                  child: Text("No conversations found",
                      style: TextStyle(fontSize: 18)),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> conversation = conversations[index];

                    // Format timestamp for display
                    String formattedDate = "Unknown Date";
                    if (conversation["timestamp"] != null &&
                        conversation["timestamp"] is Timestamp) {
                      DateTime dateTime =
                          (conversation["timestamp"] as Timestamp).toDate();
                      formattedDate = DateFormat('MM/dd')
                          .format(dateTime); // Format as "MM/dd"
                    }

                    // Get current score
                    int currentScore = conversation["score"] ?? 0;

                    // Get previous conversation's score (if exists)
                    int? previousScore = index < conversations.length - 1
                        ? conversations[index + 1]["score"] ?? 0
                        : null; // No previous score for last conversation

                    // Determine the arrow direction
                    IconData? arrowIcon;
                    Color arrowColor = Colors.transparent; // Default no color

                    if (previousScore != null) {
                      if (currentScore > previousScore) {
                        arrowIcon = Icons.arrow_upward;
                        arrowColor = Colors.green;
                      } else if (currentScore < previousScore) {
                        arrowIcon = Icons.arrow_downward;
                        arrowColor = Colors.red;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConversationLog(
                                  userId: widget.uid,
                                  topic: widget.topic,
                                  conversationId: conversation[
                                      "id"], // Pass Firestore document ID
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(15),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Date & View Text
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "View Conversation",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    SizedBox(width: 5),

                                    // Show arrow only if there's a previous conversation
                                    if (arrowIcon != null)
                                      Icon(
                                        arrowIcon,
                                        color: arrowColor,
                                        size: 18,
                                      ),
                                  ],
                                ),
                              ),

                              // Score & Pie Chart Button
                              Row(
                                children: [
                                  Text(
                                    "Score: $currentScore",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  SizedBox(width: 10),

                                  // Pie Chart Button with Asset
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PieChartScreen(
                                            userId: widget.uid,
                                            topic: widget.topic,
                                            conversationId: conversation[
                                                "id"], // Pass Firestore document ID
                                          ),
                                        ),
                                      );
                                    },
                                    child: Image.asset(
                                      'assets/pieChart.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            SizedBox(height: 20),

            // View Progression Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgressionScreen(scores: scores),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                "View Progression",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
