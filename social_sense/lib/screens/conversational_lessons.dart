import 'package:flutter/material.dart';
import 'package:social_sense/screens/conversation.dart';
import 'package:social_sense/screens/home/home.dart';
import 'package:social_sense/screens/ArcTextPainter.dart' as arc;
import 'package:social_sense/screens/custom_Button.dart'; // ✅ Import CustomButton

class ConversationalLessons extends StatelessWidget {
  final String uid;
  final double gridHeight;

  ConversationalLessons({required this.uid, this.gridHeight = 800});

  final double textRadius = 230;
  final double textVerticalOffset = 90;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/topPurple_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🐻 Bear Image Positioned at the Top
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/animal_Bear.png',
                width: 400,
                height: 500,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // "Back to Home" Button
          Positioned(
            top: 90,
            right: 10,
            child: Container(
              width: 150,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9720),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.zero,
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Home(uid: uid)),
                  );
                },
                child: Text(
                  "Back to Home",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // ✅ Welcome Arched Text
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              height: 120,
              child: CustomPaint(
                painter: arc.ArcTextPainter(
                  text: "Let's Learn Together!",
                  radius: textRadius,
                  verticalOffset: textVerticalOffset,
                ),
              ),
            ),
          ),

          // ✅ Foreground Content
          Column(
            children: [
              SizedBox(height: 0),

              // ✅ Grid Layout for Buttons (2 per row)
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 100),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.50,
                      width: double.infinity,
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1,
                        ),
                        itemCount: lessonButtons.length,
                        itemBuilder: (context, index) {
                          return CustomButton(
                            text: lessonButtons[index]["title"]!,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConversationScreen(
                                    conversationTopic: lessonButtons[index]
                                        ["topic"]!,
                                  ),
                                ),
                              );
                            },
                            width: 150,
                            height: 150,
                            borderRadius: 30.0,
                            backgroundColor: const Color.fromARGB(255, 221, 202,
                                235), // ✅ Different colors per button
                            borderColor: const Color.fromARGB(
                                255, 239, 228, 85), // ✅ Different border colors
                            borderWidth: 10.0,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ✅ Bottom Bar with Star Image
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50, right: 80),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Next Star Container
                  Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 244, 232, 13),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        "Next Star",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w100,
                          fontFamily: "Modak",
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 15),

                  // Star Image Positioned to the Right
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Image.asset(
                      'assets/star.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// **Lesson Button Data**
  final List<Map<String, String>> lessonButtons = [
    {"title": "Greeting Conversation", "topic": "greeting"},
    {"title": "Practice Asking for Help!", "topic": "askHelp"},
    {"title": "Practice Setting Boundaries!", "topic": "boundaries"},
    {"title": "Practice Being a Good Sport!", "topic": "game"},
  ];
}
