import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sense/conversation_services/openAI_api_service.dart';
import 'package:social_sense/services/database.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; // Speech-to-Text
import 'dart:convert';

class ConversationController {
  final AIAPIService _apiService;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DatabaseService _dbService;
  final stt.SpeechToText _speech = stt.SpeechToText(); // STT instance

  bool _isListening = false; // Track if listening
  Function(String)? onSpeechResult; // Callback function to send results

  ConversationController({required String uid})
      : _dbService = DatabaseService(uid: uid),
        _apiService = AIAPIService(uid: uid);

  // Stores conversation settings
  String initialMessage = "Loading...";
  int positiveThreshold = 0;
  int negativeThreshold = 0;
  int positiveCount = 0;
  int negativeCount = 0;

  // Conversation history
  List<Map<String, String>> conversation = [
    {
      "role": "system",
      "content":
          "You are a friendly assistant that role-plays conversations with children, classifies their responses, and provides feedback on their responses."
    }
  ];

  /// **Loads initial conversation settings**
  Future<void> loadConversationSettings(String conversationTopic) async {
    try {
      Map<String, dynamic> data =
          await _dbService.getConversationSettings(conversationTopic);

      initialMessage = data["initialMessage"];
      positiveThreshold = data["positiveThreshold"];
      negativeThreshold = data["negativeThreshold"];
    } catch (e) {
      print("Error loading conversation settings: $e");
      initialMessage = "Error loading message.";
      positiveThreshold = 0;
      negativeThreshold = 0;
    }
  }

  /// **Initializes the conversation**
  Future<String> startConversation(String conversationTopic) async {
    await loadConversationSettings(conversationTopic);

    conversation = [
      {
        "role": "system",
        "content":
            "You are a friendly assistant that role-plays conversations with children, classifies their responses, and provides feedback on their responses."
      },
      {"role": "assistant", "content": initialMessage},
    ];
    initialMessage = extractResponseContent(initialMessage);
    return initialMessage;
  }

  /// **Handles User Input (Text or Speech)**
  Future<String> handleUserInput(String userInput) async {
    conversation.add({"role": "user", "content": userInput});

    final response = await _apiService.sendMessage(conversation);
    conversation.add({"role": "assistant", "content": response});

    return response;
  }

  /// **Starts Listening for Speech**
  Future<void> startListening(Function(String) onResult) async {
  if (!_isListening) {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Status: $status"),
      onError: (error) => print("Error: $error"),
    );

    if (available) {
      _isListening = true;
      _speech.listen(
        onResult: (result) async {
          if (result.finalResult) { // Ensures only the final recognized words are sent
            _isListening = false; // Mark as stopped
            _speech.stop(); // Stop listening
            onResult(result.recognizedWords); // Send final recognized text
          }
        },
      );
    }
  }
}


  /// **Stops Listening**
  Future<void> stopListening() async {
    if (_isListening) {
      _isListening = false;
      _speech.stop();
    }
  }

  /// **Ends the Conversation Based on Thresholds**
  Future<bool> endConversation(String response) async {
    String? classification = extractClassification(response);

    if (classification == "positive" || classification == "neutral") {
      this.positiveCount++;
      this.negativeCount = 0;
    } else if (classification == "off-topic" ||
        classification == "inappropriate" ||
        classification == "non-responsive") {
      this.negativeCount++;
    }

    if (positiveCount >= positiveThreshold ||
        negativeCount >= negativeThreshold) {
      conversation.add({"role": "user", "content": "end conversation"});
      return true;
    }
    return false;
  }

  /// **Extracts Classification from AI Response**
  String extractClassification(String response) {
    response = response.replaceAll(r'\n', '\n');
    var splitResponse = response.split("\n");
    String classification = splitResponse[0].replaceFirst("Classification: ", "");
    return classification;
  }

  /// **Extracts Message Content (Without Classification)**
  String extractResponseContent(String response) {
    response = response.replaceAll(r'\n', '\n');
    var splitResponse = response.split("\n");
    return splitResponse.length > 1 ? splitResponse[1] : response;
  }
}
