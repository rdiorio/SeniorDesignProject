import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_sense/conversation_services/tts_services.dart';
import 'package:social_sense/services/database.dart';

class ChangeBuddy extends StatefulWidget {
  final String uid;

  ChangeBuddy({required this.uid});

  @override
  _ChangeBuddyState createState() => _ChangeBuddyState();
}

class _ChangeBuddyState extends State<ChangeBuddy> {
  String? userUid;
  late TextToSpeechService _ttsService;
  late DatabaseService _dbService;
  String selectedVoice = "";

  final List<Map<String, String>> buddies = [
    {'name': 'Sloth', 'image': 'lib/screens/assets/badge1.png'},
    {'name': 'Lion', 'image': 'lib/screens/assets/badge2.png'},
    {'name': 'Pig', 'image': 'lib/screens/assets/badge3.png'},
    {'name': 'Bear', 'image': 'lib/screens/assets/badge4.png'},
  ];

  final List<Map<String, String>> voices = [
    {"name": "Fenrir", "gender": "MALE"},
    {"name": "Puck", "gender": "MALE"},
    {"name": "Orus", "gender": "MALE"},
    {"name": "Leda", "gender": "FEMALE"},
    {"name": "Zephyr", "gender": "FEMALE"},
    {"name": "Kore", "gender": "FEMALE"},
  ];

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
      appBar: AppBar(title: Text('Change Buddy')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Buddy Name Section with Edit Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Your buddy's name: Andy",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.orange),
                  onPressed: () {}, // TODO: Add edit functionality
                ),
              ],
            ),

            SizedBox(height: 20),

            // Buddy Selection Grid
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: buddies.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {}, // TODO: Add buddy selection logic
                    child: Column(
                      children: [
                        Image.asset(
                          buddies[index]['image']!,
                          width: 100,
                          height: 100,
                        ),
                        SizedBox(height: 5),
                        Text(
                          buddies[index]['name']!,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // Voice Selection Section
            Text(
              "Your buddy's voice:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            // Voice Buttons with Selection
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: voices.map((voice) {
                bool isSelected = voice["name"] == selectedVoice;

                return GestureDetector(
                  onTap: () => _selectVoice(voice["name"]!, voice["gender"]!),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blueAccent : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          voice['name']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.play_arrow,
                              color: isSelected ? Colors.white : Colors.black),
                          onPressed: () => _playPreview(voice["name"]!, voice["gender"]!),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
