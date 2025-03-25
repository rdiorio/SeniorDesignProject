import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sense/screens/home/home.dart';
import 'package:social_sense/screens/conversation_history/history_topic_menu.dart';
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
      scores.clear();
      scores.addAll(fetchedConversations.map((c) => c["score"] ?? 0));
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/bottomPurple_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // "Home" Button
          Positioned(
            top: screenHeight * 0.06,
            left: screenWidth * 0.05,
            child: SizedBox(
              width: screenWidth * 0.25,
              height: screenHeight * 0.05,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF88158),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Home(uid: widget.uid)),
                  );
                },
                child: Text(
                  "Home",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // "Back" (to History Topic Menu) Button
          Positioned(
            top: screenHeight * 0.06,
            right: screenWidth * 0.05,
            child: SizedBox(
              width: screenWidth * 0.25,
              height: screenHeight * 0.05,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9720),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ConversationHistory(uid: widget.uid)),
                  );
                },
                child: Text(
                  "Back",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.1), // Top spacing

                // Show loading indicator while fetching data
                if (isLoading)
                  Expanded(child: Center(child: CircularProgressIndicator()))
                else if (conversations.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        "No conversations found",
                        style: TextStyle(fontSize: screenHeight * 0.025),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> conversation =
                            conversations[index];

                        String formattedDate = "Unknown Date";
                        if (conversation["timestamp"] != null &&
                            conversation["timestamp"] is Timestamp) {
                          DateTime dateTime =
                              (conversation["timestamp"] as Timestamp).toDate();
                          formattedDate = DateFormat('MM/dd').format(dateTime);
                        }

                        int currentScore = conversation["score"] ?? 0;
                        int? previousScore = index < conversations.length - 1
                            ? conversations[index + 1]["score"] ?? 0
                            : null;

                        IconData? arrowIcon;
                        Color arrowColor = Colors.transparent;

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
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.01),
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
                                      conversationId: conversation["id"],
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(screenHeight * 0.015),
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.grey.shade300),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          formattedDate,
                                          style: TextStyle(
                                            fontSize: screenHeight * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Expanded(
                                          child: Text(
                                            "View Conversation",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: screenHeight * 0.018),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.01),

                                        // Show arrow if there's a previous conversation
                                        if (arrowIcon != null)
                                          Icon(
                                            arrowIcon,
                                            color: arrowColor,
                                            size: screenHeight * 0.022,
                                          ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Score: $currentScore",
                                        style: TextStyle(
                                          fontSize: screenHeight * 0.02,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.02),

                                      // Pie Chart Button with Asset
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PieChartScreen(
                                                userId: widget.uid,
                                                topic: widget.topic,
                                                conversationId:
                                                    conversation["id"],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Image.asset(
                                          'assets/pieChart.png',
                                          width: screenHeight * 0.04,
                                          height: screenHeight * 0.04,
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

                SizedBox(height: screenHeight * 0.04),

                // View Progression Button
                buildButton(context, 'View Progression',
                    ProgressionScreen(scores: scores)),

                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, String text, Widget targetScreen) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.005), // Reduced space between buttons
      child: SizedBox(
        width: screenWidth * 0.9, // Scales width dynamically
        height: screenHeight * 0.075, // Scales height dynamically
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
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => targetScreen));
          },
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.06, // Scales text size dynamically
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}