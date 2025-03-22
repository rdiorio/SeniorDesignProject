import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardsScreen extends StatefulWidget {
  final String uid; // ✅ Require UID when instantiating

  const RewardsScreen({super.key, required this.uid});

  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  String buddyType = "Bear"; // Default buddy type
  String? selectedHat; // Currently worn hat
  String? selectedGlasses; // Currently worn glasses

  // ✅ List of available hats
  final List<String> hats = [
    "Frog",
    "Crown",
    "Flower",
    "Smile",
    "Cowboy",
    "Party"
  ];

  // ✅ List of available glasses
  final List<String> glasses = [
    "3D",
    "Colorful",
    "Heart",
    "Orange",
    "Pink",
    "Star"
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ✅ Load user's selected buddy, hat, and glasses from Firestore
  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      setState(() {
        buddyType = userDoc["buddy"] ?? "Bear"; // Load buddy type
      /*  List<dynamic>? selectedClothes = userDoc["selectedClothes"];
        
        if (selectedClothes != null) {
          // Check if the saved clothes contain a hat or glasses
          for (String item in selectedClothes) {
            if (hats.contains(item)) selectedHat = item;
            if (glasses.contains(item)) selectedGlasses = item;
          }
        }*/
      });
    }
  }

  // ✅ Toggle hat selection
  void _toggleHat(String hat) {
    setState(() {
      selectedHat = (selectedHat == hat) ? null : hat; // Remove if selected again
    });
  }

  // ✅ Toggle glasses selection
  void _toggleGlasses(String glassesType) {
    setState(() {
      selectedGlasses = (selectedGlasses == glassesType) ? null : glassesType; // Remove if selected again
    });
  }

  // ✅ Save selected accessories to Firestore
  Future<void> _saveSelection() async {
    List<String> selectedItems = [];
    if (selectedHat != null) selectedItems.add(selectedHat!);
    if (selectedGlasses != null) selectedItems.add(selectedGlasses!);

    await FirebaseFirestore.instance.collection("users").doc(widget.uid).update({
      "selectedClothes": selectedItems,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(selectedItems.isNotEmpty ? "Selection saved!" : "No accessories selected.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rewards Store")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Your Buddy", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                  child: Image.asset("assets/glasses$selectedGlasses.png", width: 90, height: 85),
                ),
            ],
          ),

          SizedBox(height: 20),

          // ✅ Hat Selection Row
          Text("Choose a Hat", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: hats.map((hat) {
                bool isSelected = selectedHat == hat; // Check if selected
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
                          child: Image.asset("assets/hat$hat.png", width: 80, height: 80),
                        ),
                        SizedBox(height: 5),
                        Text(
                          hat,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "5 ⭐", // ✅ Display Price
                          style: TextStyle(fontSize: 14, color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 20),

          // ✅ Glasses Selection Row
          Text("Choose Glasses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: glasses.map((glassesType) {
                bool isSelected = selectedGlasses == glassesType; // Check if selected
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
                          child: Image.asset("assets/glasses$glassesType.png", width: 80, height: 40),
                        ),
                        SizedBox(height: 5),
                        Text(
                          glassesType,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "5 ⭐", // ✅ Display Price
                          style: TextStyle(fontSize: 14, color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 20),

          // ✅ Save Selection Button
          ElevatedButton(
            onPressed: null, //ADD SAVE FUNCTIONALITY
            child: Text("Buy Selection"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }
}