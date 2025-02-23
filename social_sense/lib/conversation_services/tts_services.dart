import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:social_sense/services/database.dart';

class TextToSpeechService {
  final DatabaseService _dbService;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? apiKey;

  // Constructor to initialize DatabaseService and fetch the API key
  TextToSpeechService({required String uid}) : _dbService = DatabaseService(uid: uid) {
    _initializeAPIKey();
  }

  // Asynchronously fetch the API key
  Future<void> _initializeAPIKey() async {
    apiKey = await _dbService.getAPIKey("GoogleKey");
    if (apiKey == null) {
      throw Exception("Failed to fetch API Key.");
    }
  }

  Future<void> speak(String text) async {
    final url = Uri.parse("https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey");

    final Map<String, dynamic> requestPayload = {
      "input": {"text": text},
      "voice": {
        "languageCode": "en-US",
        "name": "Leda",
        "ssmlGender": "FEMALE"
      },
      "audioConfig": {
        "audioEncoding": "MP3",
        "speakingRate": 1.0
      }
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestPayload),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      String audioContent = responseBody["audioContent"];
      Uint8List audioBytes = base64Decode(audioContent);

      // Play the generated audio and wait for it to finish
      await _audioPlayer.play(BytesSource(audioBytes));
      await _audioPlayer.onPlayerComplete.first; // Wait until playback completes
    } else {
      print("Error: ${response.body}");
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }
}
