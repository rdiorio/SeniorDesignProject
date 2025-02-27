import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_sense/conversation_services/tts_services.dart';
import 'package:social_sense/services/database.dart';

class VoiceSelectionScreen extends StatefulWidget {
  @override
  _VoiceSelectionScreenState createState() => _VoiceSelectionScreenState();
}

class _VoiceSelectionScreenState extends State<VoiceSelectionScreen> {
  String? userUid;
  late TextToSpeechService _ttsService;
  late DatabaseService _dbService;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  /// **Retrieves the Signed-in User's UID**
  void _initializeUser() async {
    userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid == null) {
      print("Error: No user signed in.");
      return;
    }

    _ttsService = TextToSpeechService(uid: userUid!);
    _dbService = DatabaseService(uid: userUid!);

    setState(() {}); // Update UI after fetching user ID
  }

  // **List of Available Voices**
  final List<Map<String, String>> voices = [
    {"name": "Fenrir", "gender": "MALE"},
    {"name": "Puck", "gender": "MALE"},
    {"name": "Orus", "gender": "MALE"},
    {"name": "Leda", "gender": "FEMALE"},
    {"name": "Zephyr", "gender": "FEMALE"},
    {"name": "Kore", "gender": "FEMALE"},
  ];

  String selectedVoice = "";

  /// **Plays a Sample Preview**
  void _playPreview(String voiceName, String gender) async {
    String sampleText = "Hello! I can't wait to have a fun conversation with you!";
    await _ttsService.speak(sampleText, voiceName, gender);
  }

  /// **Saves the Selected Voice to Firestore**
  void _selectVoice(String voiceName, String gender) async {
    if (userUid == null) {
      print("Error: No user ID found.");
      return;
    }

    setState(() {
      selectedVoice = voiceName;
    });

    await _dbService.updateUserVoice(voiceName, gender);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Selected voice: $voiceName")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select a Voice")),
      body: userUid == null
          ? Center(child: CircularProgressIndicator()) // Show loading until UID is fetched
          : ListView.builder(
              itemCount: voices.length,
              itemBuilder: (context, index) {
                String voiceName = voices[index]["name"]!;
                String gender = voices[index]["gender"]!;
                return Card(
                  child: ListTile(
                    title: Text(voiceName),
                    subtitle: Text("Gender: $gender"),
                    trailing: IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () => _playPreview(voiceName, gender),
                    ),
                    onTap: () => _selectVoice(voiceName, gender),
                  ),
                );
              },
            ),
    );
  }
}