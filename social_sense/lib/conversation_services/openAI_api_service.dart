import 'dart:convert';
import 'package:social_sense/services/database.dart';
import 'package:http/http.dart' as http;

class AIAPIService {
  final DatabaseService _dbService;
  final String modelId = "ft:gpt-4o-mini-2024-07-18:personal:first-model:ArUqSGNx";
  String? apiKey;

  // Constructor to initialize DatabaseService and fetch the API key
  AIAPIService({required String uid}) : _dbService = DatabaseService(uid: uid) {
    _initializeAPIKey();
  }

  // Asynchronously fetch the API key
  Future<void> _initializeAPIKey() async {
    apiKey = await _dbService.getAPIKey();
    if (apiKey == null) {
      throw Exception("Failed to fetch API Key.");
    }
  }

  // Sends a message to the OpenAI API
  Future<String> sendMessage(List<Map<String, String>> conversation) async {
    // Ensure the API key is available
    if (apiKey == null) {
      throw Exception("API Key is not initialized.");
    }

    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": modelId,
        "messages": conversation,
      }),
    );

    if (response.statusCode == 200) {
      String responseBody;

      try {
        responseBody = utf8.decode(response.bodyBytes);
      } catch (e) {
        responseBody = response.body;
      }

      final data = jsonDecode(responseBody);
      return data["choices"][0]["message"]["content"];
    } else {
      throw Exception("Failed to fetch response: ${response.body}");
    }
  }
}