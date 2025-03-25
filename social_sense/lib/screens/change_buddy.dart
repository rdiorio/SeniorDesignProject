import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_sense/conversation_services/tts_services.dart';
import 'package:social_sense/screens/profile.dart';
import 'package:social_sense/services/database.dart';
import 'package:social_sense/screens/home/home.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

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
  String selectRandomName() {
    final List<String> randomName = [
      "Finn",
      "Fiona",
      "Meyli",
      "Kawaii",
      "Olive",
      "Pippin",
      "Maru",
      "Draeger",
      "Clover",
      "Honey",
      "Maple",
      "Peanut",
      "Squish",
      "Tiki",
      "Coco"
    ];

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
    _nameController
        .dispose(); // Clean up the controller when widget is disposed
    super.dispose();
  }

  //Plays a Sample Preview
  void _playPreview(String voiceName, String gender) async {
    String sampleText =
        "Hello! I can't wait to have a fun conversation with you!";
    await _ttsService.speak(sampleText, voiceName, gender);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/bottomPurple_background.png'), // replace with your actual image asset
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenHeight * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      "Your buddy's name: $buddyName",
                      style: GoogleFonts.sniglet(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w100,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit,
                        color: Colors.orange, size: screenWidth * 0.06),
                    onPressed: _showEditNameDialog,
                  ),
                  IconButton(
                    icon: Icon(Icons.casino,
                        color: Colors.red[300], size: screenWidth * 0.06),
                    onPressed: () {
                      setState(() {
                        buddyName = selectRandomName();
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.001),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 600 ? 4 : 2,
                  crossAxisSpacing: screenWidth * 0.05,
                  mainAxisSpacing: screenHeight * 0.03,
                  childAspectRatio: 0.8,
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
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color.fromARGB(75, 241, 175, 247),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            buddies[index]['image']!,
                            width: screenWidth * 0.35,
                            height: screenWidth * 0.35,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            buddies[index]['name']!,
                            style: GoogleFonts.sniglet(
                                fontSize: screenWidth * 0.04),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                "Your buddy's voice:",
                style: GoogleFonts.sniglet(
                    fontSize: screenWidth * 0.045, fontWeight: FontWeight.w100),
              ),
              SizedBox(height: screenHeight * 0.02),
              Wrap(
                spacing: screenWidth * 0.02,
                runSpacing: screenHeight * 0.015,
                alignment: WrapAlignment.center,
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
                      backgroundColor: isSelected
                          ? const Color.fromARGB(255, 171, 121, 236)
                          : const Color(0xFFFF9720),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                    child: Text(
                      voice["name"]!,
                      style: GoogleFonts.sniglet(
                        color: isSelected
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : Colors.black,
                        fontSize: screenWidth * 0.038,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: screenHeight * 0.025),
              ElevatedButton(
                onPressed: () {
                  _dbService.updateBuddyInfo(
                      selectedBuddy, buddyName, selectedVoice, selectedGender);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Home(uid: widget.uid)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 242, 231, 249),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), 
                    side: BorderSide(
                      color: const Color.fromARGB(255, 248, 129, 74), 
                      width: screenWidth * 0.01,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1, // Changes width of button
                      vertical: screenHeight * 0.01),
                ),
                child: Text("Save",
                    style: GoogleFonts.sniglet(
                        fontSize: screenWidth * 0.047,
                        fontWeight: FontWeight.w900,
                        color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}