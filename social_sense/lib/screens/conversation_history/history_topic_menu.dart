import 'package:flutter/material.dart';
import 'package:social_sense/screens/conversation_history/history_convo_menu.dart';

class ConversationHistory extends StatefulWidget {
  final String uid; // UID parameter

  ConversationHistory({required this.uid});

  @override
  _ConversationHistoryState createState() => _ConversationHistoryState();
}

class _ConversationHistoryState extends State<ConversationHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Conversation History')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            // Button 1
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HistoryConvoMenu(uid: widget.uid, topic: "greeting")),
                );
              }, // Placeholder action
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text("Greeting History", style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),

            // Button 2
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HistoryConvoMenu(uid: widget.uid, topic: "askHelp")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text("Asking for Help History",
                  style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),

            // Button 3
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HistoryConvoMenu(uid: widget.uid, topic: "game")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text("Being a Good Sport History",
                  style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),

            // Button 4
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HistoryConvoMenu(
                          uid: widget.uid, topic: "boundaries")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text("Setting Boundaries History",
                  style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
