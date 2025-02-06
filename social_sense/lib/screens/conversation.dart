import 'package:flutter/material.dart';
import 'package:social_sense/conversation_services/conversation_controller.dart';

class ConversationScreen extends StatefulWidget {
  final String conversationTopic;

  const ConversationScreen({super.key, required this.conversationTopic});

  @override
  ConversationScreenState createState() => ConversationScreenState();
}

class ConversationScreenState extends State<ConversationScreen> {
  late ConversationController _controller;
  final TextEditingController _textController = TextEditingController();

  bool isLoading = true;
  bool isConversationEnded = false;  // New state to track conversation end
  List<Map<String, String>> conversationLog = []; // Store the conversation log

  @override
  void initState() {
    super.initState();
    _controller = ConversationController(uid: "user123"); // Replace with actual user ID
    _startConversation();
  }

  Future<void> _startConversation() async {
    String initMessage = await _controller.startConversation(widget.conversationTopic);
    setState(() {
      conversationLog.add({"role": "assistant", "content": initMessage});
      isLoading = false;
    });
  }

  Future<void> _sendUserMessage(String userInput) async {
    if (userInput.isEmpty) return;

    // Add user's message to the log
    setState(() {
      conversationLog.add({"role": "user", "content": userInput});
      _textController.clear(); // Clear the input field
    });

    // Get the assistant's full response from the controller
    String response = await _controller.handleUserInput(userInput);
    String responseContent =  _controller.extractResponseContent(response);
    // Add assistant's response to the log
    setState(() {
      conversationLog.add({"role": "assistant", "content": responseContent});
    });

    // Check if the conversation should end
    bool shouldEnd = await _controller.endConversation(response);
    if (shouldEnd) {
      // Send the final goodbye message
      String goodbyeResponse = await _controller.handleUserInput("end conversation");
      String goodbyeContent = _controller.extractResponseContent(goodbyeResponse);
      setState(() {
        conversationLog.add({"role": "assistant", "content": goodbyeContent});
        isConversationEnded = true; // Mark the conversation as ended
      });
    }
  }

  void _viewResults() {
    // Navigate to the results page or show results (customize as needed)
    print("View results button clicked!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversationTopic.toUpperCase() + " Conversation"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Display counts and thresholds at the top
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
                          onPressed: _viewResults,  // Handle results button press
                          child: const Text("View Results"),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                decoration: InputDecoration(
                                  labelText: "Type your message...",
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (value) => _sendUserMessage(value), // Handle enter key
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
    _textController.dispose(); // Clean up the controller
    super.dispose();
  }
}
