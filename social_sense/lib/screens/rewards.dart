import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sense/services/database.dart';
import 'package:audioplayers/audioplayers.dart';

class RewardsScreen extends StatefulWidget {
  final String uid; 

  const RewardsScreen({super.key, required this.uid});

  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  String buddyType = "Bear"; // Default buddy type
  String buddyName ="";
  String? selectedHat; // Currently worn hat
  String? selectedGlasses; // Currently worn glasses
  List<String> ownedHats = [];
  List<String> ownedGlasses = [];
  bool showCloset = false; // Toggle between store and closet
  String? wearingGlasses = "";
  String? wearingHat = "";
  int stars = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();



  // List of available hats
  final List<String> hats = [
    "Frog",
    "Crown",
    "Flower",
    "Smile",
    "Cowboy",
    "Party",
    "Sombrero"
  ];

  // List of available glasses
  final List<String> glasses = [
    "3D",
    "Colorful",
    "Heart",
    "Orange",
    "Pink",
    "Star",
    "Disguise"
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }



  //  Load user's selected buddy, hat, and glasses from Firestore
  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      setState(() {
        buddyType = userDoc["buddy"] ?? "Bear"; // Load buddy type
        buddyName = userDoc["buddyName"] ?? "no name"; 
        wearingHat = userDoc['currentHat'];
        wearingGlasses = userDoc['currentGlasses'];
        stars = userDoc['scores']['stars'];
      });
    }

     // Fetch owned items
  ownedHats = await DatabaseService(uid: widget.uid).getOwnedItems("ownedHats");
  ownedGlasses = await DatabaseService(uid: widget.uid).getOwnedItems("ownedGlasses");
  setState(() {}); // trigger rebuild with owned data

  }

  // Toggle hat selection
  void _toggleHat(String hat) {
    setState(() {
      selectedHat = (selectedHat == hat) ? null : hat; // Remove if selected again
    });
  }

  // Toggle glasses selection
  void _toggleGlasses(String glassesType) {
    setState(() {
      selectedGlasses = (selectedGlasses == glassesType) ? null : glassesType; // Remove if selected again
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      extendBodyBehindAppBar: true, // Allows the background to go behind the AppBar
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, 
        title: Text(showCloset ? "My Closet" : "Rewards Store"),
        actions: [
          IconButton(
            icon: Icon(showCloset ? Icons.storefront : Icons.checkroom),
            onPressed: () {
              setState(() {
                showCloset = !showCloset;
                selectedHat = null;
                selectedGlasses = null;
              });
            },
            tooltip: showCloset ? "Go to Store" : "Go to Closet",
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/bottomPurple_background.png",
              fit: BoxFit.cover, // Ensures the image covers the entire background
            ),
          ),
          SafeArea(
            child: SizedBox(
              height: double.infinity,  // Ensures content takes full screen height
              child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    width: double.infinity,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(buddyName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 20),

                        // ✅ Buddy with optional hat & glasses
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset("assets/animal_$buddyType.png", width: 200, height: 200),
                            
                            if (selectedHat != null)
                              Positioned(
                                top: 10, // Adjust hat position
                                child: Image.asset("assets/hat$selectedHat.png", width: 100, height: 40),
                              ),

                            if (selectedGlasses != null)
                              Positioned(
                                top: 22, // Adjust glasses position
                                child: Image.asset("assets/glasses$selectedGlasses.png", width: 80, height: 95),
                              ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Hat Selection
                        Text("Choose a Hat", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: showCloset
                                ? ownedHats.map((hatKey) {
                                    final String hat = hatKey.replaceFirst("hat", "");
                                    final bool isSelected = selectedHat == hat;
                                    return GestureDetector(
                                      onTap: () => _toggleHat(hat),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: isSelected ? Colors.purple : Colors.transparent,
                                                  width: 4,
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Image.asset("assets/$hatKey.png", width: 80, height: 80),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              (wearingHat == "hat$hat") ? "Wearing" : hat,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: (wearingHat == "hat$hat") ? Colors.green : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList()
                                : hats.map((hat) {
                                    final String hatKey = "hat$hat";
                                    final bool isOwned = ownedHats.contains(hatKey);
                                    final bool isSelected = selectedHat == hat;

                                    return GestureDetector(
                                      onTap: isOwned ? null : () => _toggleHat(hat),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: isOwned ? Colors.grey[300] : null,
                                                border: Border.all(
                                                  color: isSelected ? Colors.purple : Colors.transparent,
                                                  width: 4,
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Image.asset("assets/$hatKey.png", width: 80, height: 80),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              hat,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isOwned ? Colors.grey : Colors.black,
                                              ),
                                            ),
                                            Text(
                                              isOwned ? "SOLD" : "5 ⭐",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isOwned ? Colors.red : Colors.orange,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                          ),
                        ),



                        SizedBox(height: 20),

                        // Glasses Selection
                        Text("Choose Glasses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: showCloset
                                ? ownedGlasses.map((glassesKey) {
                                    final String glassesType = glassesKey.replaceFirst("glasses", "");
                                    final bool isSelected = selectedGlasses == glassesType;

                                    return GestureDetector(
                                      onTap: () => _toggleGlasses(glassesType),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: isSelected ? Colors.blue : Colors.transparent,
                                                  width: 4,
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Image.asset("assets/$glassesKey.png", width: 80, height: 40),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              (wearingGlasses == "glasses$glassesType") ? "Wearing" : glassesType,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: (wearingGlasses == "glasses$glassesType") ? Colors.green : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList()
                                : glasses.map((glassesType) {
                                    final String glassesKey = "glasses$glassesType";
                                    final bool isOwned = ownedGlasses.contains(glassesKey);
                                    final bool isSelected = selectedGlasses == glassesType;

                                    return GestureDetector(
                                      onTap: isOwned ? null : () => _toggleGlasses(glassesType),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: isOwned ? Colors.grey[300] : null,
                                                border: Border.all(
                                                  color: isSelected ? Colors.blue : Colors.transparent,
                                                  width: 4,
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Image.asset("assets/$glassesKey.png", width: 80, height: 40),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              glassesType,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isOwned ? Colors.grey : Colors.black,
                                              ),
                                            ),
                                            Text(
                                              isOwned ? "SOLD" : "5 ⭐",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isOwned ? Colors.red : Colors.orange,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                          ),
                        ),

                          

                        SizedBox(height: 20),
                        if (showCloset)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await DatabaseService(uid: widget.uid).updateCurrentAccessories(
                                  hat: "",
                                  glasses: "",
                                );
                                await _audioPlayer.play(AssetSource('zipClothes.wav'));
                                setState(() {
                                  selectedHat = null;
                                  selectedGlasses = null;
                                  wearingHat = null;
                                  wearingGlasses = null;
                                });
                              },
                              icon: Icon(Icons.remove_circle_outline),
                              label: Text("Remove All Items"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[300],
                              ),
                            ),
                          ),


                        // Save Selection Button
                        ElevatedButton(
                          onPressed: (selectedHat != null || selectedGlasses != null)
                              ? () async {
                                  if (showCloset) {
                                  await DatabaseService(uid: widget.uid).updateCurrentAccessories(
                                    hat: selectedHat != null ? 'hat$selectedHat' : "",
                                    glasses: selectedGlasses != null ? 'glasses$selectedGlasses' : "",
                                    
                                  );
                                  await _audioPlayer.play(AssetSource('zipClothes.wav'));

                                  } else {
                                    if (selectedHat != null && selectedGlasses != null && stars >= 10) {
                                      await DatabaseService(uid: widget.uid).deductStars(10);
                                      await DatabaseService(uid: widget.uid)
                                          .addToOwnedAccessory('ownedHats', 'hat$selectedHat');
                                      await DatabaseService(uid: widget.uid)
                                          .addToOwnedAccessory('ownedGlasses', 'glasses$selectedGlasses');
                                      selectedGlasses = null;
                                      selectedHat = null;
                                      await _audioPlayer.play(AssetSource('buy.wav'));
                                    }
                                    else if (selectedGlasses != null && stars >= 5) {
                                      await DatabaseService(uid: widget.uid).deductStars(5);
                                      await DatabaseService(uid: widget.uid)
                                          .addToOwnedAccessory('ownedGlasses', 'glasses$selectedGlasses');
                                      selectedGlasses = null;
                                      await _audioPlayer.play(AssetSource('buy.wav'));
                                    }
                                    else if (selectedHat != null && stars >= 5){
                                      await DatabaseService(uid: widget.uid).deductStars(5);
                                                await DatabaseService(uid: widget.uid)
                                          .addToOwnedAccessory('ownedHats', 'hat$selectedHat');
                                        selectedHat = null;
                                        await _audioPlayer.play(AssetSource('buy.wav'));
                                    }
                                    await DatabaseService(uid: widget.uid).updateCurrentAccessories(
                                    hat: selectedHat != null ? 'hat$selectedHat' : null,
                                    glasses: selectedGlasses != null ? 'glasses$selectedGlasses' : null,
                                  );

                                  }
                                  _loadUserData();

                                }
                              : null,
                          child: Text(showCloset ? "Wear Selection" : "Buy Selection"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        )
                    ],
                  ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }