import 'package:flutter/material.dart';
import 'package:social_sense/services/database.dart';
import 'package:social_sense/screens/home/home.dart';
import 'package:social_sense/screens/change_buddy.dart';

class InformationScreen extends StatefulWidget {
  final String uid;
  InformationScreen({required this.uid});

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  Future<Map<String, dynamic>?> _getUserData() async {
    return await DatabaseService(uid: widget.uid).getUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _checkAndRedirect() async {
    var userData = await _getUserData();

    if (userData?['buddyName'] == "No Name") {
      //no buddy, go to change buddy
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChangeBuddy(uid: widget.uid)),
      );
    } else {
      //existing user, go home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home(uid: widget.uid)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bottomYellow_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground content
          Center(
            child: FutureBuilder(
              future: _getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading user data'));
                } else if (snapshot.hasData) {
                  var userData = snapshot.data as Map<String, dynamic>?;
                  if (userData != null) {
                    _firstNameController.text = userData['First Name'] ?? '';
                    _lastNameController.text = userData['Last Name'] ?? '';
                  }
                }

                return Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 150),
                      Text(
                        'Change Information',
                        style: TextStyle(
                          fontFamily: "Modak",
                          fontSize: screenWidth * 0.08,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            labelStyle:
                                TextStyle(fontFamily: "Modak", fontSize: screenWidth * 0.06),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (val) =>
                              val!.isEmpty ? 'Enter your first name' : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            labelStyle:
                                TextStyle(fontFamily: "Modak", fontSize: screenWidth * 0.06),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (val) =>
                              val!.isEmpty ? 'Enter your last name' : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: buildSaveButton(context),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: screenHeight * 0.06,
            right: screenWidth * 0.05,
            child: SizedBox(
              width: screenWidth * 0.25,
              height: screenHeight * 0.05,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9720),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Home(uid: widget.uid)),
                  );
                },
                child: Text(
                  "Home",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSaveButton(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005), 
      child: SizedBox(
        width: screenWidth * 0.25,
        height: screenHeight * 0.05, 
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 242, 231, 249), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), 
              side: BorderSide(
                color: const Color.fromARGB(255, 248, 129, 74), 
                width: screenWidth * 0.01,
              ),
            ),
            elevation: 5,
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await DatabaseService(uid: widget.uid).updateUserData(
                _firstNameController.text,
                _lastNameController.text,
              );
              _checkAndRedirect();
            }
          },
          child: Text(
            "Save",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.047,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

}