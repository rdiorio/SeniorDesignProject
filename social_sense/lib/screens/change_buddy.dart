import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_sense/conversation_services/tts_services.dart';
import 'package:social_sense/screens/profile.dart';
import 'package:social_sense/services/database.dart';
import 'package:social_sense/screens/home/home.dart';
import 'dart:math';

class ChangeBuddy extends StatefulWidget {
  final String uid;

  ChangeBuddy({required this.uid});

  @override
  _ChangeBuddyState createState() => _ChangeBuddyState();
}

class _ChangeBuddyState extends State<ChangeBuddy> {
  late TextToSpeechService _ttsService;
  late DatabaseService _dbService;
   late TextEditingController _nameController;
  String selectedVoice = "";
  String selectedGender = "";
  String selectedBuddy = "";
  String buddyName = "";



  final List<Map<String, String>> buddies = [
    {'name': 'Sloth', 'image': 'assets/animal_Sloth.png'},
    {'name': 'Lion', 'image': 'assets/animal_Lion.png'},
    {'name': 'Pig', 'image': 'assets/animal_Pig.png'},
    {'name': 'Bear', 'image': 'assets/animal_Bear.png'},
  ];

 final List<Map<String, String>> voices = [
    {"name": "Fenrir", "gender": "MALE"},
    {"name": "Puck", "gender": "MALE"},
    {"name": "Orus", "gender": "MALE"},
    {"name": "Leda", "gender": "FEMALE"},
    {"name": "Zephyr", "gender": "FEMALE"},
    {"name": "Kore", "gender": "FEMALE"},
  ];

 void _loadBuddyInfo() async {
  DatabaseService dbService = DatabaseService(uid: widget.uid);
  Map<String, String> buddyData = await dbService.getBuddyInfo();
  Map<String, String> voiceData = await dbService.getUserVoice();

  setState(() {
    buddyName = buddyData["buddyName"]!;
    selectedBuddy = buddyData["buddy"]!;
    selectedVoice = voiceData["name"]!;
    selectedGender = voiceData["gender"]!;

    // If there's no name, assign a random one
    if (buddyName == "No Name") {
      buddyName = selectRandomName();
    }
  });
}
  
  @override
  void initState() {
    super.initState();
    _initializeUser();
    _loadBuddyInfo();
    _nameController = TextEditingController();
  }

  //Retrieves the Signed-in User's UID
  void _initializeUser() async {
    String? userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid == null) {
      print("Error: No user signed in.");
      return;
    }

    _ttsService = TextToSpeechService(uid: userUid);
    _dbService = DatabaseService(uid: userUid);

    setState(() {}); // Update UI after fetching user ID
  }

    //Function to randomize name
    String selectRandomName(){
     final List<String> randomName = [
      "Finn", "Fiona", "Meyli", "Kawaii", "Olive", 
      "Pippin", "Maru", "Draeger", "Clover", "Honey", 
      "Maple", "Peanut", "Squish", "Tiki", "Coco"];
      
   Random random = Random();
   int index = random.nextInt(randomName.length);
   return randomName[index];
  }

//Function to type in custom name
void _showEditNameDialog() {
    _nameController.text = buddyName; // Pre-fill with the current name

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Buddy's Name"),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(hintText: "Enter a name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  buddyName = _nameController.text.trim(); // Update buddy name
                });
                Navigator.pop(context); // Close dialog
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
   @override
  void dispose() {
    _nameController.dispose(); // Clean up the controller when widget is disposed
    super.dispose();
  }


  //Plays a Sample Preview
  void _playPreview(String voiceName, String gender) async {
    String sampleText = "Hello! I can't wait to have a fun conversation with you!";
    await _ttsService.speak(sampleText, voiceName, gender);
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
            // Buddy Name Section with Edit & Random Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Your buddy's name: $buddyName",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.orange),
                  onPressed: _showEditNameDialog, // Open name editor
                ),
                SizedBox(width: 5), // Adjust spacing

                // Wrap button in Flexible to prevent overflow
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        buddyName = selectRandomName(); // Randomize name on button press
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[300],
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    child: Text(
                      'Random',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Buddy Selection Grid
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: buddies.length,
              itemBuilder: (context, index) {
                bool isSelected = buddies[index]['name'] == selectedBuddy;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedBuddy = buddies[index]['name']!;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  ),
                );
              },
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

                return ElevatedButton(
                  onPressed: () {
                    _playPreview(voice["name"]!, voice["gender"]!);
                    setState(() {
                      selectedVoice = voice["name"]!;
                      selectedGender = voice["gender"]!;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.blueAccent : Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    voice["name"]!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: () {
              _dbService.updateBuddyInfo(selectedBuddy, buddyName, selectedVoice, selectedGender);
              Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Home(uid: widget.uid)), // Use Home instead of HomeScreen
                    );
              }, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: Text(
                "Save",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}