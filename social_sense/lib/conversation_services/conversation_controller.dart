import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sense/conversation_services/openAI_api_service.dart';
import 'package:social_sense/services/database.dart';

class ConversationController {
  final AIAPIService _apiService = AIAPIService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DatabaseService _dbService;

  // Constructor to initialize the DatabaseService with a user ID
  ConversationController({required String uid}) : _dbService = DatabaseService(uid: uid);

  // Stores conversation settings
  String initialMessage = "Loading...";
  int positiveThreshold = 0;
  int negativeThreshold = 0;
  int positiveCount = 0;
  int negativeCount = 0;

  // Conversation history
  List<Map<String, String>> conversation = [
    {"role": "system", "content":"You are a friendly assistant that role-plays conversations with children, "
    "classifies their responses, and provides feedback on their responses."}
  ];

  /// Loads initial conversation settings
  Future<void> loadConversationSettings(String conversationTopic) async {
    try {
      Map<String, dynamic> data = await _dbService.getConversationSettings(conversationTopic);

      // Store fetched data
      initialMessage = data["initialMessage"];
      positiveThreshold = data["positiveThreshold"];
      negativeThreshold = data["negativeThreshold"];
      

    } catch (e) {
      print("Error loading conversation settings: $e");
      
      // Assign default values if fetching fails
      initialMessage = "Error loading message.";
      positiveThreshold = 0;
      negativeThreshold = 0;
    }
  }

  // Initializes the conversation
  Future<String> startConversation(String conversationTopic) async {
    await loadConversationSettings(conversationTopic);

    conversation = [
      {"role": "system", "content": "You are a friendly assistant that role-plays conversations with children, "
    "classifies their responses, and provides feedback on their responses."},
      {"role": "assistant", "content": initialMessage},
    ];

    return initialMessage;
  }

  // end conversation
Future<bool> endConversation(String response) async {
  // Extract classification
  String? classification = extractClassification(response);

  // Increment counters 
  if (classification == "positive" || classification == "neutral") {
    this.positiveCount++;
    this.negativeCount = 0; // Reset negative count on positive or neutral classification
  } else if (classification == "off-topic" || classification == "inappropriate" || classification == "non-responsive") {
    this.negativeCount++;
  }

  // End conversation if either threshold is reached
  if (positiveCount >= positiveThreshold || negativeCount >= negativeThreshold) {
    conversation.add({"role": "user", "content": "end conversation"});
    return true;
  }
  return false;
}


  // Handles user input and generates AI response
  Future<String> handleUserInput(String userInput) async {
    conversation.add({"role": "user", "content": userInput});

    final response = await _apiService.sendMessage(conversation);
    conversation.add({"role": "assistant", "content": response});

    return response;
  }

//Finds the response classification
  String extractClassification(String response) {

    String firstLine = response.split("\n")[0];

  // Remove "Classification: " from the first line
  String classification = firstLine.replaceFirst("Classification: ", "");

  return classification;
}




}
