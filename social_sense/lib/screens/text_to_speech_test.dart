/*import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:social_sense/conversation_services/tts_services.dart';

class TextToSpeechTestScreen extends StatefulWidget {
  @override
  _TextToSpeechTestScreenState createState() => _TextToSpeechTestScreenState();
}

class _TextToSpeechTestScreenState extends State<TextToSpeechTestScreen> {
  final TextToSpeechService _ttsService = TextToSpeechService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _textController = TextEditingController();
  String _status = "Enter text and press 'Speak'";

  Future<void> _speak() async {
    String text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() => _status = "Please enter text!");
      return;
    }

    setState(() => _status = "Generating speech...");
    Uint8List? audioData = await _ttsService.convertTextToSpeech(text);

    if (audioData != null) {
      await _audioPlayer.play(BytesSource(audioData));
      setState(() => _status = "Playing audio...");
    } else {
      setState(() => _status = "Error: Could not generate speech");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TTS Test Screen")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _status,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: "Enter text to speak",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _speak,
              child: Text("🔊 Speak"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _textController.dispose();
    super.dispose();
  }
}
*/