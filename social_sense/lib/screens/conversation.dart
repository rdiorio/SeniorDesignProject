import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_sense/conversation_services/conversation_controller.dart';
import 'package:social_sense/conversation_services/tts_services.dart';
import 'package:social_sense/services/database.dart';
import 'package:social_sense/screens/conversation_results.dart';
import 'dart:async';
import 'package:social_sense/screens/conversational_lessons.dart';

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

  List<Map<String, String>> conversationLog = [];
  Map<String, int> classificationCounts = {
    "positive": 0,
    "neutral": 0,
    "off-topic": 0,
    "inappropriate": 0,
    "non-responsive": 0,
  };
  int conversationScore = 0;

  String voiceName = "Leda";
  String voiceGender = "FEMALE";
  String buddyName = "";
  String buddyType = "Bear";
  String? currentHat;
  String? currentGlasses;

  String _currentUserInput = "";

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
    if (userUid == null) return;

    _controller = ConversationController(uid: userUid!);
    _ttsService = TextToSpeechService(uid: userUid!);

    await _loadUserVoicePreferences();
    await _loadUserBuddyPreferences();
    await _startConversation();
  }

  Future<void> _loadUserBuddyPreferences() async {
    if (userUid == null) return;
    try {
      final dbService = DatabaseService(uid: userUid!);
      final buddyData = await dbService.getBuddyInfo();
      final userData = await dbService.getUserData();

      setState(() {
        buddyName = buddyData["buddyName"] ?? "Buddy";
        buddyType = buddyData["buddy"] ?? "Bear";
        currentHat = userData?["currentHat"];
        currentGlasses = userData?["currentGlasses"];
        isBuddyLoaded = true;
        _checkLoadingState();
      });
    } catch (e) {
      print("Error loading buddy preferences: $e");
    }
  }

  Future<void> _loadUserVoicePreferences() async {
    if (userUid == null) return;
    try {
      final voiceData = await DatabaseService(uid: userUid!).getUserVoice();
      setState(() {
        voiceName = voiceData["name"] ?? "Leda";
        voiceGender = voiceData["gender"] ?? "FEMALE";
      });
    } catch (e) {
      print("Error loading voice preferences: $e");
    }
  }

  Future<void> _startConversation() async {
    final initMessage =
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
      setState(() => isLoading = false);
    }
  }

  Future<void> _sendUserMessage(String userInput) async {
    if (userInput.trim().isEmpty) return;

    setState(() {
      conversationLog.add({"role": "user", "content": userInput});
      _currentUserInput = userInput;
      _textController.clear();
    });

    final response =
        await _controller.handleUserInput(userInput, widget.conversationTopic);
    final responseContent = _controller.extractResponseContent(response);
    final classification = _controller.extractClassification(response);

    if (classificationCounts.containsKey(classification)) {
      classificationCounts[classification] =
          classificationCounts[classification]! + 1;
    }

    setState(() {
      conversationLog.add({"role": "assistant", "content": responseContent});
      _startTalkingAnimation();
    });

    if (isTTSActive) {
      await _ttsService.speak(responseContent, voiceName, voiceGender);
      _stopTalkingAnimation();
    }

    if (await _controller.endConversation(response)) {
      final goodbyeResponse = await _controller.handleUserInput(
          "end conversation", widget.conversationTopic);
      final goodbyeContent =
          _controller.extractResponseContent(goodbyeResponse);

      setState(() {
        conversationLog.add({"role": "assistant", "content": goodbyeContent});
        isConversationEnded = true;
        _startTalkingAnimation();
      });

      if (isTTSActive) {
        await _ttsService.speak(goodbyeContent, voiceName, voiceGender);
        _stopTalkingAnimation();
      }

      conversationScore = _controller.scoreConversation(classificationCounts);
      await DatabaseService(uid: userUid!).storeConversation(
        userId: userUid!,
        topic: widget.conversationTopic,
        score: conversationScore,
        classificationCounts: classificationCounts,
        conversationLog: conversationLog,
      );
    }
  }

  void _toggleTTS() => setState(() => isTTSActive = !isTTSActive);

  void _startTalkingAnimation() {
    setState(() => isTalking = true);
    _talkingTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() => showTalkingImage = !showTalkingImage);
    });
  }

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
            onChanged: (value) => tempUserInput = value,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String buddyImage = showTalkingImage
        ? "assets/animal_${buddyType}_talking.png"
        : "assets/animal_$buddyType.png";

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/bottomPurple_background.png",
              fit: BoxFit.cover,
            ),
          ),

          // "Back" (to Conversational Lessons Menu) Button
          isConversationEnded
              ? SizedBox()
              : Positioned(
                  top: screenHeight * 0.06,
                  left: screenWidth * 0.05,
                  child: SizedBox(
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.05,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 239, 133, 57),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        if (isTalking) {
                          null;
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ConversationalLessons(uid: userUid!)),
                          );
                        }
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
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    SizedBox(height: screenHeight * 0.12),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
                      child: Column(
                        children: [
                          Text(
                            buddyName,
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[400],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          if (conversationLog.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              decoration: BoxDecoration(
                                color: Colors.purple[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                conversationLog.lastWhere((msg) =>
                                    msg["role"] == "assistant")["content"]!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.045,
                                ),
                              ),
                            ),
                          SizedBox(height: screenHeight * 0.07),
                          BuddyAvatar(
                            buddy: buddyType,
                            hat: currentHat,
                            glasses: currentGlasses,
                            isTalking: showTalkingImage,
                            scale:
                                screenWidth / 300, // you can tweak this value
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 1000),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child:
                              ScaleTransition(scale: animation, child: child),
                        );
                      },
                      child: isConversationEnded
                          ? Container(
                              key: ValueKey("results"),
                              padding:
                                  EdgeInsets.only(bottom: screenHeight * 0.07),
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: screenWidth * .6,
                                height: screenHeight * .08,
                                child: buildButton(
                                  context,
                                  'View Results',
                                  ConversationResults(
                                    buddyType: buddyType,
                                    conversationScore: conversationScore,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              key: ValueKey("inputArea"),
                              padding:
                                  EdgeInsets.only(bottom: screenHeight * 0.07),
                              alignment: Alignment.center,
                              width: screenWidth * 0.9,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: _showTextInputDialog,
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(screenWidth * 0.035),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF6EFFA),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Color(0xFFF8814A),
                                          width: 3,
                                        ),
                                      ),
                                      child: Text(
                                        _currentUserInput.isEmpty
                                            ? "Touch to type..."
                                            : _currentUserInput,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.045,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  FloatingActionButton(
                                    backgroundColor: Colors.purple[400],
                                    onPressed: () {
                                      if (!isTalking) {
                                        _controller
                                            .startListening((recognizedText) {
                                          final userInput =
                                              recognizedText.trim().isEmpty
                                                  ? " "
                                                  : recognizedText;
                                          _sendUserMessage(userInput);
                                        });
                                      }
                                    },
                                    child: Icon(Icons.mic,
                                        size: screenWidth * 0.075),
                                  ),
                                ],
                              ),
                            ),
                    )
                  ],
                ),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, String text, Widget targetScreen) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
      child: SizedBox(
        width: screenWidth * 0.6,
        height: screenHeight * 0.08,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFF2E7F9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                  color: Color(0xFFF8814A), width: screenWidth * 0.015),
            ),
            elevation: 5,
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => targetScreen));
          },
          child: Text(
            text,
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

class BuddyAvatar extends StatelessWidget {
  final String buddy;
  final String? hat;
  final String? glasses;
  final double scale;
  final bool isTalking;

  const BuddyAvatar({
    super.key,
    required this.buddy,
    this.hat,
    this.glasses,
    this.scale = 1.0,
    this.isTalking = false,
  });

  @override
  Widget build(BuildContext context) {
    String buddyImage = isTalking
        ? 'assets/animal_${buddy}_talking.png'
        : 'assets/animal_$buddy.png';

    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: 250,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(buddyImage, width: 300, height: 300),
            if (hat != null && hat!.isNotEmpty)
              Positioned(
                top: 15,
                child: Image.asset('assets/$hat.png', width: 100, height: 40),
              ),
            if (glasses != null && glasses!.isNotEmpty)
              Positioned(
                top: 60,
                child:
                    Image.asset('assets/$glasses.png', width: 100, height: 55),
              ),
          ],
        ),
      ),
    );
  }
}
