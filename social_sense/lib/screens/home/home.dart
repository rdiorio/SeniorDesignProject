import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sense/services/auth.dart';
import 'package:social_sense/screens/daily_checkin.dart';
import 'package:social_sense/screens/information.dart';
import 'package:social_sense/screens/lessons.dart';
import 'package:social_sense/screens/profile.dart';
import 'package:social_sense/screens/speechtotext.dart';
import 'package:social_sense/screens/voice_selection.dart'; 


class Home extends StatefulWidget {
  final String uid;

  Home({required this.uid});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _checkDailyCheckIn();
  }

  Future<void> _checkDailyCheckIn() async {
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(widget.uid);
    
    DocumentSnapshot docSnapshot = await userDoc.get();
    if (docSnapshot.exists) {
      Map<String, dynamic> userData = docSnapshot.data() as Map<String, dynamic>;

      // Get last check-in date
      Timestamp? lastCheckIn = userData['lastCheckIn'] as Timestamp?;
      DateTime today = DateTime.now();

      // If lastCheckIn is null OR is not today, show the check-in screen
      if (lastCheckIn == null ||
          lastCheckIn.toDate().day != today.day ||
          lastCheckIn.toDate().month != today.month ||
          lastCheckIn.toDate().year != today.year) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DailyCheckInScreen(uid: widget.uid),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/topRed_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                leading: IconButton(
                  icon: Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InformationScreen(uid: widget.uid),
                      ),
                    );
                  },
                ),
                actions: <Widget>[
                  TextButton.icon(
                    icon: Icon(Icons.person, color: Colors.white),
                    label: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      await _auth.signOut();
                    },
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Lessons",
                        style: TextStyle(
                          fontSize: 60.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                          minimumSize: Size(200.0, 60.0),
                        ),
                        child: Text(
                          'Emotion',
                          style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LessonsPage(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        child: Text('Profile'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(uid: widget.uid),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        child: Text('Speech'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SpeechToTextScreen(),
                            ),
                          );
                        },
                      ),
                      ElevatedButton(
                        child: Text('Pick your voice'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VoiceSelectionScreen(),
                            ),
                          );
                        },
                      ),
                      ElevatedButton(
                        child: Text('Daily Check-In'),
                        onPressed: () {
                          print("Navigating to Daily Check-In with uid: ${widget.uid}"); // ✅ Corrected
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DailyCheckInScreen(uid: widget.uid), // ✅ Corrected
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              'assets/animal_Lion.png',
              height: 200.0,
            ),
          ),
        ],
      ),
    );
  }
}
