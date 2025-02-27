import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_sense/conversation_services/conversation_controller.dart';
import 'package:social_sense/conversation_services/tts_services.dart';
import 'package:social_sense/services/database.dart';

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
  String? conversationId; // Stores Firestore conversation ID

  final TextEditingController _textController = TextEditingController();
  bool isLoading = true;
  bool isConversationEnded = false;
  bool isTTSActive = true;

  //initializing conversation values
  List<Map<String, String>> conversationLog = [];
  Map<String, int> classificationCounts = {
  "positive": 0,
  "neutral": 0,
  "off-topic": 0,
  "inappropriate": 0,
  "non-responsive": 0,
};
int conversationScore = 0;


  //Voice Preferences (Default)
  String voiceName = "Leda";
  String voiceGender = "FEMALE";

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  //Retrieves the Signed-in User's UID and Initializes Services
  void _initializeUser() async {
    userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid == null) {
      print("Error: No user signed in.");
      return;
    }

    _controller = ConversationController(uid: userUid!);
    _ttsService = TextToSpeechService(uid: userUid!);

    await _loadUserVoicePreferences();
    await _startConversation();
  }

  //Loads User's Selected Voice from Firestore
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


    //Start conversation from the controller
    String initMessage = await _controller.startConversation(widget.conversationTopic);



    setState(() {
      conversationLog.add({"role": "assistant", "content": initMessage});
      isLoading = false;
    });

    if (isTTSActive) {
      await _ttsService.speak(initMessage, voiceName, voiceGender);
    }
  }

  //Handles User Messages 
  Future<void> _sendUserMessage(String userInput) async {

    //Update UI immediately
    setState(() {
      conversationLog.add({"role": "user", "content": userInput});
      _textController.clear();
    });

    
    //Get assistant response
    String response = await _controller.handleUserInput(userInput);  
    String responseContent = _controller.extractResponseContent(response);
    String classification = _controller.extractClassification(response);

    //update conversation counts
    if (classificationCounts.containsKey(classification)) {
      classificationCounts[classification] = classificationCounts[classification]! + 1;
    }

 
    //Update UI with assistant's response
    setState(() {
      conversationLog.add({"role": "assistant", "content": responseContent});
    });

    if (isTTSActive) {
      await _ttsService.speak(responseContent, voiceName, voiceGender);
    }

    // Check if conversation should end
    bool shouldEnd = await _controller.endConversation(response);
    if (shouldEnd) {

      String goodbyeResponse = await _controller.handleUserInput("end conversation");
      String goodbyeContent = _controller.extractResponseContent(goodbyeResponse);


      setState(() {
        conversationLog.add({"role": "assistant", "content": goodbyeContent});
        isConversationEnded = true;
      });
      if (isTTSActive) {
        await _ttsService.speak(goodbyeContent, voiceName, voiceGender);
      }


      //Store everything
      conversationScore = _controller.scoreConversation(classificationCounts);

         if (userUid != null) {
      DatabaseService dbService = DatabaseService(uid: userUid!); // ✅ Create an instance
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversationTopic.toUpperCase() + " Conversation"),
        actions: [
          IconButton(
            icon: Icon(isTTSActive ? Icons.volume_up : Icons.volume_off),
            onPressed: _toggleTTS,
            tooltip: "Toggle Speech Output",
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Positive Count: ${_controller.positiveCount}/${_controller.positiveThreshold}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Negative Count: ${_controller.negativeCount}/${_controller.negativeThreshold}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: conversationLog.length,
                    itemBuilder: (context, index) {
                      final message = conversationLog[index];
                      final isUser = message["role"] == "user";

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            message["content"]!,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: isConversationEnded
                      ? ElevatedButton(
                          onPressed: () {},
                          child: const Text("View Results"),
                        )
                      : Row(
                          children: [
                            FloatingActionButton(
                              onPressed: () {
                                _controller.startListening((recognizedText) {
                                  setState(() {
                                    _sendUserMessage(recognizedText);
                                  });
                                });
                              },
                              child: Icon(Icons.mic),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _controller.stopListening(),
                              child: const Text("Stop"),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                decoration: InputDecoration(
                                  labelText: "Type your message...",
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (value) => _sendUserMessage(value),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _sendUserMessage(_textController.text),
                              child: const Text("Send"),
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _ttsService.stop();
    super.dispose();
  }
}