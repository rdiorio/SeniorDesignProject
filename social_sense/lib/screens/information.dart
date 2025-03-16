import 'package:flutter/material.dart';
import 'package:social_sense/services/database.dart';
import 'package:social_sense/screens/home/home.dart';

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

  @override
  Widget build(BuildContext context) {
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
                          fontSize: 32, // Increase the font size
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
                            labelStyle: TextStyle(fontFamily: "Modak", fontSize: 25),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (val) => val!.isEmpty ? 'Enter your first name' : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            labelStyle: TextStyle(fontFamily: "Modak", fontSize: 25),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (val) => val!.isEmpty ? 'Enter your last name' : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        child: Text('Save', style: TextStyle(fontFamily: "Modak", color: Colors.black)),  
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {  
                            await DatabaseService(uid: widget.uid).updateUserData(
                              _firstNameController.text,
                              _lastNameController.text,
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Home(uid: widget.uid)),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(100, 50),
              ),
              child: Text('Back to Home', style: TextStyle(fontFamily: "Modak", fontSize: 20, color: Colors.black)),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home(uid: widget.uid)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}