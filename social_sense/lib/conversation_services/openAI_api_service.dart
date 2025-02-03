import 'dart:convert';
import 'package:http/http.dart' as http;

class AIAPIService {
  //final String apiKey = 
  final String modelId = "ft:gpt-4o-mini-2024-07-18:personal:first-model:ArUqSGNx";

  Future<String> sendMessage(List<Map<String, String>> conversation) async {
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
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      throw Exception("Failed to fetch response: ${response.body}");
    }
  }
}
