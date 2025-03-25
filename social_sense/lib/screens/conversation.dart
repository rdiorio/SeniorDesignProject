import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_sense/conversation_services/conversation_controller.dart';
import 'package:social_sense/conversation_services/tts_services.dart';
import 'package:social_sense/services/database.dart';
import 'package:social_sense/screens/conversation_results.dart';
import 'dart:async';

class ConversationScreen extends StatefulWidget {
  final String conversationTopic;

  const ConversationScreen({super.key, required this.conversationTopic});

  @override
  ConversationScreenState createState() => ConversationScreenState();
}

class ConversationScreenState extends State<ConversationScreen> {
  late ConversationController _controller;
  late TextToSpeechService _ttsService;
  String? userUid;

  final TextEditingController _textController = TextEditingController();
  bool isLoading = true;
  bool isBuddyLoaded = false;
  bool isConversationEnded = false;
  bool isTTSActive = true;


  // Initialize conversation values
  List<Map<String, String>> conversationLog = [];
  Map<String, int> classificationCounts = {
    "positive": 0,
    "neutral": 0,
    "off-topic": 0,
    "inappropriate": 0,
    "non-responsive": 0,
  };
  int conversationScore = 0;

  // Voice & Buddy Preferences (Default)
  String voiceName = "Leda";
  String voiceGender = "FEMALE";
  String buddyName = "";
  String buddyType = "Bear";
  String? currentHat;
  String? currentGlasses;


  // Variable to store the most recent user input
  String _currentUserInput = "";

  //Animation Variables
  bool isTalking = false;
  bool showTalkingImage = false;
  Timer? _talkingTimer;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() async {
    userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid == null) {
      print("Error: No user signed in.");
      return;
    }

    _controller = ConversationController(uid: userUid!);
    _ttsService = TextToSpeechService(uid: userUid!);

    await _loadUserVoicePreferences();
    await _loadUserBuddyPreferences();
    await _startConversation();
  }

  Future<void> _loadUserBuddyPreferences() async {
    if (userUid == null) return;
    try {
      DatabaseService dbService = DatabaseService(uid: userUid!);
      Map<String, String> buddyData = await dbService.getBuddyInfo();
      Map<String, dynamic>? userData = await dbService.getUserData();

      setState(() {
        buddyName = buddyData["buddyName"] ?? "Buddy";
        buddyType = buddyData["buddy"] ?? "Bear";
        currentHat = userData?["currentHat"];
        currentGlasses = userData?["currentGlasses"];
        isBuddyLoaded = true;
        _checkLoadingState();
      });
      print("current hat $currentHat");
      print("current glasses $currentGlasses");
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _loadUserVoicePreferences() async {
    if (userUid == null) return;
    try {
      Map<String, String> voiceData =
          await DatabaseService(uid: userUid!).getUserVoice();
      setState(() {
        voiceName = voiceData["name"] ?? "Leda";
        voiceGender = voiceData["gender"] ?? "FEMALE";
      });
    } catch (e) {
      print("Error loading voice preferences: $e");
    }
  }

  Future<void> _startConversation() async {
    if (userUid == null) return;

    String initMessage =
        await _controller.startConversation(widget.conversationTopic);

    setState(() {
      conversationLog.add({"role": "assistant", "content": initMessage});
      _checkLoadingState();
      _startTalkingAnimation();
    });

    if (isTTSActive) {
      await _ttsService.speak(initMessage, voiceName, voiceGender);
      _stopTalkingAnimation();
    }
  }

  void _checkLoadingState() {
    if (conversationLog.isNotEmpty && isBuddyLoaded) {
      setState(() {
        isLoading = false;
        
      });
    }
  }

  Future<void> _sendUserMessage(String userInput) async {
    if (userInput.trim().isEmpty) return;

    setState(() {
      conversationLog.add({"role": "user", "content": userInput});
      _currentUserInput = userInput;
      _textController.clear();
    });

    String response = await _controller.handleUserInput(userInput, widget.conversationTopic);
    String responseContent = _controller.extractResponseContent(response);
    String classification = _controller.extractClassification(response);

    if (classificationCounts.containsKey(classification)) {
      classificationCounts[classification] = classificationCounts[classification]! + 1;
    }

    setState(() {
      conversationLog.add({"role": "assistant", "content": responseContent});
      _startTalkingAnimation();
    });

    if (isTTSActive) {
      await _ttsService.speak(responseContent, voiceName, voiceGender);
      _stopTalkingAnimation();
    }

    bool shouldEnd = await _controller.endConversation(response);
    if (shouldEnd) {
      String goodbyeResponse =
          await _controller.handleUserInput("end conversation", widget.conversationTopic);
      String goodbyeContent =
          _controller.extractResponseContent(goodbyeResponse);

      setState(() {
        conversationLog.add({"role": "assistant", "content": goodbyeContent});
        isConversationEnded = true;  // ✅ Conversation is over
        _startTalkingAnimation();
      });

      if (isTTSActive) {
        await _ttsService.speak(goodbyeContent, voiceName, voiceGender);
        _stopTalkingAnimation();
      }

      conversationScore = _controller.scoreConversation(classificationCounts);

      if (userUid != null) {
        DatabaseService dbService = DatabaseService(uid: userUid!);
        await dbService.storeConversation(
          userId: userUid!,
          topic: widget.conversationTopic,
          score: conversationScore,
          classificationCounts: classificationCounts,
          conversationLog: conversationLog,
        );
      } else {
        print("Error: No user signed in.");
      }
    }
  }

  void _toggleTTS() {
    setState(() {
      isTTSActive = !isTTSActive;
    });
  }

   // ✅ Starts talking animation (switches between open/closed mouth)
  void _startTalkingAnimation() {
    setState(() {
      isTalking = true;
    });

    _talkingTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        showTalkingImage = !showTalkingImage; // Toggle between images
      });
    });
  }

  // ✅ Stops talking animation
  void _stopTalkingAnimation() {
    _talkingTimer?.cancel();
    setState(() {
      isTalking = false;
      showTalkingImage = false;
    });
  }

  void _showTextInputDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempUserInput = _currentUserInput;
        return AlertDialog(
          title: Text("Type Your Message"),
          content: TextField(
            controller: _textController,
            decoration: InputDecoration(hintText: "Enter your message..."),
            onChanged: (value) {
              tempUserInput = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _sendUserMessage(tempUserInput);
                Navigator.pop(context);
              },
              child: Text("Send"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
      String buddyImage = showTalkingImage
        ? "assets/animal_${buddyType}_talking.png" // ✅ Open-mouth version
        : "assets/animal_$buddyType.png"; // ✅ Closed-mouth version

    return Scaffold(
      extendBodyBehindAppBar: true, // Allows content to go behind the app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // Removes shadow
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(isTTSActive ? Icons.volume_up : Icons.volume_off),
            onPressed: _toggleTTS,
            tooltip: "Toggle Speech Output",
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/bottomPurple_background.png", // Change to your actual background image path
              fit: BoxFit.cover, // Covers the entire screen
            ),
          ),

          // Foreground Content
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    SizedBox(height: kToolbarHeight + 100), // Push content below AppBar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          Text(
                            buddyName,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple[400]),
                          ),
                          SizedBox(height: 5),
                          if (conversationLog.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(color: Colors.purple[300], borderRadius: BorderRadius.circular(20)),
                              child: Text(conversationLog.lastWhere((message) => message["role"] == "assistant")["content"]!, style: TextStyle(color: Colors.white, fontSize: 18)),
                            ),
                          SizedBox(height: 10),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(buddyImage, width: 400, height: 400),
                              if (currentHat != null && currentHat!.isNotEmpty)
                                Positioned(
                                  top: 40,
                                  child: Image.asset(
                                    "assets/$currentHat.png",
                                    width: 150,
                                    height: 70,
                                  ),
                                ),
                              if (currentGlasses != null && currentGlasses!.isNotEmpty)
                                Positioned(
                                  top: 100,
                                  child: Image.asset(
                                    "assets/$currentGlasses.png",
                                    width: 160,
                                    height: 90,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Spacer(),

                    if (!isConversationEnded) ...[
                      Padding(
                        padding: EdgeInsets.only(bottom: 40), // Moves it up
                        child: GestureDetector(
                          onTap: _showTextInputDialog,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 246, 239, 250), 
                              borderRadius: BorderRadius.circular(20), // Rounded corners
                              border: Border.all(
                                color: const Color.fromARGB(255, 248, 129, 74), 
                                width: 4,
                              ),
                            ),
                            child: Text(
                              _currentUserInput.isEmpty ? "Touch to type..." : _currentUserInput,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold, 
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Move Mic Icon Up
                      Padding(
                        padding: EdgeInsets.only(bottom: 80), // Moves it up
                        child: FloatingActionButton(
                          backgroundColor: Colors.purple[400],
                          onPressed: () {
                            _controller.startListening((recognizedText) {
                              setState(() {
                                _sendUserMessage(recognizedText);
                              });
                            });
                          },
                          child: Icon(Icons.mic, color: Colors.white, size: 30),
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: EdgeInsets.only(bottom: 75), // Adjust as needed
                        child: buildButton(
                          context,
                          'View Results',
                          ConversationResults(
                            buddyType: buddyType,
                            conversationScore: conversationScore,
                          ),
                        ),
                      )
                    ],
                  ],
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
                  width: screenWidth * 0.015
              ),
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