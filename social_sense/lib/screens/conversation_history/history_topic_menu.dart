import 'package:flutter/material.dart';
import 'package:social_sense/screens/home/home.dart';
import 'package:social_sense/screens/conversation_history/history_convo_menu.dart';
import 'package:social_sense/screens/profile.dart';

class ConversationHistory extends StatefulWidget {
  final String uid;

  ConversationHistory({required this.uid});

  @override
  _ConversationHistoryState createState() => _ConversationHistoryState();
}

class _ConversationHistoryState extends State<ConversationHistory> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image using SizedBox.expand
          SizedBox.expand(
            child: Image.asset(
              'assets/bottomOrange_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                buildButton(context, 'Greeting History',
                    HistoryConvoMenu(uid: widget.uid, topic: "greeting")),
                SizedBox(height: 20),
                buildButton(context, 'Asking for Help History',
                    HistoryConvoMenu(uid: widget.uid, topic: "askHelp")),
                SizedBox(height: 20),
                buildButton(context, 'Being a Good Sport History',
                    HistoryConvoMenu(uid: widget.uid, topic: "game")),
                SizedBox(height: 20),
                buildButton(context, 'Setting Boundaries History',
                    HistoryConvoMenu(uid: widget.uid, topic: "boundaries")),
              ],
            ),
          ),

          // Home button
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

          // Back button
          Positioned(
            top: screenHeight * 0.06,
            left: screenWidth * 0.05,
            child: SizedBox(
              width: screenWidth * 0.25,
              height: screenHeight * 0.05,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 239, 133, 57),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(uid: widget.uid)),
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
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, String text, Widget targetScreen) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
      child: SizedBox(
        width: screenWidth * 0.9,
        height: screenHeight * 0.075,
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
