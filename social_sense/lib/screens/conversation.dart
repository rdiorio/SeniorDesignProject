import 'package:flutter/material.dart';
import 'package:social_sense/conversation_services/conversation_controller.dart';
import 'package:social_sense/conversation_services/tts_services.dart'; 

class ConversationScreen extends StatefulWidget {
  final String conversationTopic;

  const ConversationScreen({super.key, required this.conversationTopic});

  @override
  ConversationScreenState createState() => ConversationScreenState();
}

class ConversationScreenState extends State<ConversationScreen> {
  late ConversationController _controller;
  final TextEditingController _textController = TextEditingController();
  final TextToSpeechService _ttsService = TextToSpeechService(uid: "user123"); 

  bool isLoading = true;
  bool isConversationEnded = false;
  bool isTTSActive = true; // Toggle TTS feature
  List<Map<String, String>> conversationLog = [];

  @override
  void initState() {
    super.initState();
    _controller = ConversationController(uid: "user123");
    _startConversation();
  }

  Future<void> _startConversation() async {
    String initMessage = await _controller.startConversation(widget.conversationTopic);
    setState(() {
      conversationLog.add({"role": "assistant", "content": initMessage});
      isLoading = false;
    });

    if (isTTSActive) {
      _ttsService.speak(initMessage);
    }
  }

  Future<void> _sendUserMessage(String userInput) async {
    if (userInput.isEmpty) return;

    setState(() {
      conversationLog.add({"role": "user", "content": userInput});
      _textController.clear();
    });

    String response = await _controller.handleUserInput(userInput);
    String responseContent = _controller.extractResponseContent(response);

    setState(() {
      conversationLog.add({"role": "assistant", "content": responseContent});
    });

    if (isTTSActive) {
      _ttsService.speak(responseContent); // Play assistant's response
    }

    bool shouldEnd = await _controller.endConversation(response);
    if (shouldEnd) {

        if (isTTSActive) {
      await _ttsService.speak(responseContent); // Wait for response to finish playing
      }
      String goodbyeResponse = await _controller.handleUserInput("end conversation");
      String goodbyeContent = _controller.extractResponseContent(goodbyeResponse);

      setState(() {
        conversationLog.add({"role": "assistant", "content": goodbyeContent});
        isConversationEnded = true;
      });

      if (isTTSActive) {
        _ttsService.speak(goodbyeContent);
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
                // Display counts
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

                // Chat log
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

                // Input field and buttons
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
    _ttsService.stop(); // Stop TTS when screen is closed
    super.dispose();
  }
}
