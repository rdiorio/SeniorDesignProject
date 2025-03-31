import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sense/screens/profile.dart';
import 'package:social_sense/services/database.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';

class RewardsScreen extends StatefulWidget {
  final String uid;

  const RewardsScreen({super.key, required this.uid});

  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  String buddyType = "Bear"; // Default buddy type
  String buddyName = "";
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
    "Round",
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
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();
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
    ownedHats =
        await DatabaseService(uid: widget.uid).getOwnedItems("ownedHats");
    ownedGlasses =
        await DatabaseService(uid: widget.uid).getOwnedItems("ownedGlasses");
    setState(() {}); // trigger rebuild with owned data
  }

  // Toggle hat selection
  void _toggleHat(String hat) {
    setState(() {
      selectedHat =
          (selectedHat == hat) ? null : hat; // Remove if selected again
    });
  }

  // Toggle glasses selection
  void _toggleGlasses(String glassesType) {
    setState(() {
      selectedGlasses = (selectedGlasses == glassesType)
          ? null
          : glassesType; // Remove if selected again
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar:
          true, // Allows the background to go behind the AppBar
      backgroundColor: const Color.fromARGB(0, 197, 41, 41),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/bottomPurple_background.png",
              fit: BoxFit
                  .cover, // Ensures the image covers the entire background
            ),
          ),
          SafeArea(
            child: SizedBox(
              height: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  width: screenWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(buddyName,
                          style: GoogleFonts.baloo2(
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: screenHeight * 0.09),
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          BuddyAvatar(
                            buddy: buddyType,
                            hat: selectedHat?.isNotEmpty == true
                                ? 'hat$selectedHat'
                                : wearingHat,
                            glasses: selectedGlasses?.isNotEmpty == true
                                ? 'glasses$selectedGlasses'
                                : wearingGlasses,
                            scale: screenWidth / 300,
                          ),
                          Positioned(
                            right: -screenWidth * 0.2,
                            top: screenHeight * 0.15,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/star.png',
                                  width: screenWidth * 0.3,
                                  height: screenHeight * 0.1,
                                ),
                                Text(
                                  '$stars',
                                  style: GoogleFonts.baloo2(
                                    fontSize: screenWidth * 0.06,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 100),

                      // Hat Selection
                      Text("Choose a Hat",
                          style: GoogleFonts.baloo2(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: showCloset
                              ? ownedHats.map((hatKey) {
                                  final String hat =
                                      hatKey.replaceFirst("hat", "");
                                  final bool isSelected = selectedHat == hat;
                                  return GestureDetector(
                                    onTap: () => _toggleHat(hat),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.purple
                                                    : Colors.transparent,
                                                width: 4,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Image.asset(
                                                "assets/$hatKey.png",
                                                width: 80,
                                                height: 80),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            (wearingHat == "hat$hat")
                                                ? "Wearing"
                                                : hat,
                                            style: GoogleFonts.baloo2(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: (wearingHat == "hat$hat")
                                                  ? Colors.green
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList()
                              : hats.map((hat) {
                                  final String hatKey = "hat$hat";
                                  final bool isOwned =
                                      ownedHats.contains(hatKey);
                                  final bool isSelected = selectedHat == hat;

                                  return GestureDetector(
                                    onTap:
                                        isOwned ? null : () => _toggleHat(hat),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: isOwned
                                                  ? Colors.grey[300]
                                                  : null,
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.purple
                                                    : Colors.transparent,
                                                width: 4,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Image.asset(
                                                "assets/$hatKey.png",
                                                width: 80,
                                                height: 80),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            hat,
                                            style: GoogleFonts.baloo2(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isOwned
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                          ),
                                          Text(
                                            isOwned ? "SOLD" : "5 ⭐",
                                            style: GoogleFonts.baloo2(
                                              fontSize: 14,
                                              color: isOwned
                                                  ? Colors.red
                                                  : Colors.orange,
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

                      SizedBox(height: 60),

                      // Glasses Selection
                      Text("Choose Glasses",
                          style: GoogleFonts.baloo2(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: showCloset
                              ? ownedGlasses.map((glassesKey) {
                                  final String glassesType =
                                      glassesKey.replaceFirst("glasses", "");
                                  final bool isSelected =
                                      selectedGlasses == glassesType;

                                  return GestureDetector(
                                    onTap: () => _toggleGlasses(glassesType),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.blue
                                                    : Colors.transparent,
                                                width: 4,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Image.asset(
                                                "assets/$glassesKey.png",
                                                width: 80,
                                                height: 40),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            (wearingGlasses ==
                                                    "glasses$glassesType")
                                                ? "Wearing"
                                                : glassesType,
                                            style: GoogleFonts.baloo2(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: (wearingGlasses ==
                                                      "glasses$glassesType")
                                                  ? Colors.green
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList()
                              : glasses.map((glassesType) {
                                  final String glassesKey =
                                      "glasses$glassesType";
                                  final bool isOwned =
                                      ownedGlasses.contains(glassesKey);
                                  final bool isSelected =
                                      selectedGlasses == glassesType;

                                  return GestureDetector(
                                    onTap: isOwned
                                        ? null
                                        : () => _toggleGlasses(glassesType),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: isOwned
                                                  ? Colors.grey[300]
                                                  : null,
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.blue
                                                    : Colors.transparent,
                                                width: 4,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Image.asset(
                                                "assets/$glassesKey.png",
                                                width: 80,
                                                height: 40),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            glassesType,
                                            style: GoogleFonts.baloo2(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isOwned
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                          ),
                                          Text(
                                            isOwned ? "SOLD" : "5 ⭐",
                                            style: GoogleFonts.baloo2(
                                              fontSize: 14,
                                              color: isOwned
                                                  ? Colors.red
                                                  : Colors.orange,
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
                              await DatabaseService(uid: widget.uid)
                                  .updateCurrentAccessories(
                                hat: "",
                                glasses: "",
                              );
                              await _audioPlayer
                                  .play(AssetSource('zipClothes.wav'));
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
                        onPressed:
                            (selectedHat != null || selectedGlasses != null)
                                ? () async {
                                    if (showCloset) {
                                      await DatabaseService(uid: widget.uid)
                                          .updateCurrentAccessories(
                                        hat: selectedHat != null
                                            ? 'hat$selectedHat'
                                            : "",
                                        glasses: selectedGlasses != null
                                            ? 'glasses$selectedGlasses'
                                            : "",
                                      );
                                      await _audioPlayer
                                          .play(AssetSource('zipClothes.wav'));
                                    } else {
                                      if (selectedHat != null &&
                                          selectedGlasses != null &&
                                          stars >= 10) {
                                        await DatabaseService(uid: widget.uid)
                                            .deductStars(10);
                                        await DatabaseService(uid: widget.uid)
                                            .addToOwnedAccessory(
                                                'ownedHats', 'hat$selectedHat');
                                        await DatabaseService(uid: widget.uid)
                                            .addToOwnedAccessory('ownedGlasses',
                                                'glasses$selectedGlasses');
                                        selectedGlasses = null;
                                        selectedHat = null;
                                        await _audioPlayer
                                            .play(AssetSource('buy.wav'));
                                      } else if (selectedGlasses != null &&
                                          stars >= 5) {
                                        await DatabaseService(uid: widget.uid)
                                            .deductStars(5);
                                        await DatabaseService(uid: widget.uid)
                                            .addToOwnedAccessory('ownedGlasses',
                                                'glasses$selectedGlasses');
                                        selectedGlasses = null;
                                        await _audioPlayer
                                            .play(AssetSource('buy.wav'));
                                      } else if (selectedHat != null &&
                                          stars >= 5) {
                                        await DatabaseService(uid: widget.uid)
                                            .deductStars(5);
                                        await DatabaseService(uid: widget.uid)
                                            .addToOwnedAccessory(
                                                'ownedHats', 'hat$selectedHat');
                                        selectedHat = null;
                                        await _audioPlayer
                                            .play(AssetSource('buy.wav'));
                                      }
                                      await DatabaseService(uid: widget.uid)
                                          .updateCurrentAccessories(
                                        hat: selectedHat != null
                                            ? 'hat$selectedHat'
                                            : null,
                                        glasses: selectedGlasses != null
                                            ? 'glasses$selectedGlasses'
                                            : null,
                                      );
                                    }
                                    _loadUserData();
                                  }
                                : null,
                        child: Text(
                            showCloset ? "Wear Selection" : "Buy Selection"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.07,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Custom Back Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(uid: widget.uid)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8814A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.baloo2(
                      color: Colors.white,
                      fontSize: screenWidth * .05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Toggle Button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      showCloset = !showCloset;
                      selectedHat = null;
                      selectedGlasses = null;
                    });
                  },
                  icon: Icon(
                    showCloset ? Icons.storefront : Icons.checkroom,
                    color: Colors.white,
                  ),
                  label: Text(
                    showCloset ? 'Store' : 'Closet',
                    style: GoogleFonts.baloo2(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * .04,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[400],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BuddyAvatar extends StatelessWidget {
  final String buddy;
  final String? hat;
  final String? glasses;
  final double scale;

  const BuddyAvatar({
    super.key,
    required this.buddy,
    this.hat,
    this.glasses,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: screenWidth * 0.4,
        height: screenHeight * 0.2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/animal_$buddy.png', width: 200, height: 200),
            if (hat != null && hat!.isNotEmpty)
              Positioned(
                top: 25,
                child: Image.asset('assets/$hat.png', width: 80, height: 40),
              ),
            if (glasses != null && glasses!.isNotEmpty)
              Positioned(
                top: 60,
                child:
                    Image.asset('assets/$glasses.png', width: 75, height: 40),
              ),
          ],
        ),
      ),
    );
  }
}
