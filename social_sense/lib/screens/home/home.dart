// import 'package:flutter/material.dart';
// import 'package:social_sense/services/auth.dart';
// import 'package:social_sense/services/database.dart';
// import 'package:social_sense/screens/information.dart';
// import 'package:social_sense/screens/lessons.dart';
// import 'package:social_sense/screens/profile.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:social_sense/screens/speechtotext.dart'; // Import SpeechToTextScreen
// import 'package:social_sense/screens/daily_checkin.dart';
// import 'package:social_sense/screens/wrapper.dart';
// import 'package:social_sense/screens/voice_selection.dart';
// import 'package:social_sense/screens/conversational_lessons.dart';

// class Home extends StatelessWidget {
//   final AuthService _auth = AuthService();
//   final String uid;

//   Home({required this.uid});

//   Future<Map<String, dynamic>?> _getUserData() async {
//     DocumentSnapshot userDoc =
//         await FirebaseFirestore.instance.collection('users').doc(uid).get();
//     return userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background image
//           Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage(
//                     'assets/topRed_background.png'), // Path to your background image
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           // Foreground content
//           Column(
//             children: [
//               // Transparent AppBar on top of the background image
//               AppBar(
//                 backgroundColor: Colors.transparent,
//                 elevation: 0.0,
//                 leading: IconButton(
//                   icon: Icon(Icons.settings, color: Colors.white),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => InformationScreen(uid: uid),
//                       ),
//                     );
//                   },
//                 ),
//                 actions: <Widget>[
//                   TextButton.icon(
//                     icon: Icon(Icons.person, color: Colors.white),
//                     label: Text(
//                       'Logout',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     // onPressed: () async {
//                     //   await _auth.signOut();
//                     // },
//                     onPressed: () async {
//                       await _auth.signOut();
//                       Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) =>
//                                 Wrapper()), // Ensures app resets to Wrapper
//                         (route) =>
//                             false, // Removes all previous screens from the stack
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               // Welcome text below the app bar
//               FutureBuilder(
//                 future: _getUserData(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return CircularProgressIndicator();
//                   } else if (snapshot.hasError) {
//                     return Text('Error: ${snapshot.error}');
//                   } else if (snapshot.hasData) {
//                     var userData = snapshot.data as Map<String, dynamic>?;
//                     print('User Data: $userData'); // Debug print
//                     if (userData != null &&
//                         userData.containsKey('First Name')) {
//                       return Text(
//                         'Welcome ${userData['First Name']}!',
//                         style: TextStyle(
//                           fontSize: 40.0,
//                           fontWeight: FontWeight.bold,
//                           color: const Color.fromARGB(255, 0, 0, 0),
//                         ),
//                       );
//                     } else {
//                       return Text(
//                         'Welcome!',
//                         style: TextStyle(
//                           fontSize: 200.0,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       );
//                     }
//                   } else {
//                     return Text(
//                       'Welcome!',
//                       style: TextStyle(
//                         fontSize: 24.0,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     );
//                   }
//                 },
//               ),
//               // Foreground content
//               Expanded(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(height: 10),
//                       Text(
//                         "Lessons",
//                         style: TextStyle(
//                           fontSize: 60.0,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       SizedBox(height: 40),
//                       // ElevatedButton(
//                       //   style: ElevatedButton.styleFrom(
//                       //     backgroundColor:
//                       //         Colors.yellow, // Change button color to yellow
//                       //     shape: RoundedRectangleBorder(
//                       //       borderRadius:
//                       //           BorderRadius.circular(0.0), // Rounded corners
//                       //     ),
//                       //     padding: EdgeInsets.symmetric(
//                       //         horizontal: 40.0,
//                       //         vertical: 20.0), // Increase button size
//                       //     minimumSize: Size(200.0, 60.0), // Set button size
//                       //   ),
//                       //   child: Text(
//                       //     'Emotion',
//                       //     style: TextStyle(
//                       //         fontSize: 30.0,
//                       //         fontWeight: FontWeight.bold,
//                       //         color: Colors.black),
//                       //   ), // New "Lessons" button
//                       //   onPressed: () {
//                       //     Navigator.push(
//                       //       context,
//                       //       MaterialPageRoute(
//                       //         builder: (context) =>
//                       //             LessonsPage(), // Navigate to LessonsPage
//                       //       ),
//                       //     );
//                       //   },
//                       // ),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.yellow,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(0.0),
//                           ),
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 40.0, vertical: 20.0),
//                           minimumSize: Size(200.0, 60.0),
//                         ),
//                         child: Text(
//                           'Emotion',
//                           style: TextStyle(
//                               fontSize: 30.0,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black),
//                         ),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   LessonsPage(uid: uid), // Pass actual uid
//                             ),
//                           );
//                         },
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         child: Text('Profile'),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ProfilePage(uid: uid),
//                             ),
//                           );
//                         },
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         child: Text('Conversational lessons'),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   ConversationalLessons(uid: uid),
//                             ),
//                           );
//                         },
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         child: Text('Speech'),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => SpeechToTextScreen(),
//                             ),
//                           );
//                         },
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         child: Text('Daily Check-In'),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   DailyCheckInScreen(uid: uid),
//                             ),
//                           );
//                         },
//                       ),
//                       ElevatedButton(
//                         child: Text('Pick your voice'),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => VoiceSelectionScreen(),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           // Image at the bottom left
//           Positioned(
//             bottom: 0,
//             left: 0,
//             child: Image.asset(
//               'assets/animal_Lion.png', // Path to your image
//               height: 200.0, // Adjust the height as needed
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:social_sense/screens/breathing_exercises.dart';
import 'package:social_sense/services/auth.dart';
import 'package:social_sense/screens/information.dart';
import 'package:social_sense/screens/lessons.dart';
import 'package:social_sense/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sense/screens/speechtotext.dart';
import 'package:social_sense/screens/daily_checkin.dart';
import 'package:social_sense/screens/wrapper.dart';
import 'package:social_sense/screens/voice_selection.dart';
import 'package:social_sense/screens/conversational_lessons.dart';
import 'package:social_sense/screens/custom_Button.dart';
import 'package:social_sense/screens/ArcTextPainter.dart' as arc;
import 'package:social_sense/screens/change_buddy.dart';

class Home extends StatelessWidget {
  final AuthService _auth = AuthService();
  final String uid;

  Home({required this.uid});

  Future<Map<String, dynamic>?> _getUserData() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
  }

  final double buttonWidth = 120;
  final double buttonHeight = 75;
  final double textRadius = 230;
  final double textVerticalOffset = 85;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/topRed_background.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 40, // Adjust this to move the image up/down
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/animal_Bear.png', // Ensure this path is correct
                width: 400,
                height: 500,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // FutureBuilder to load user's name dynamically
          FutureBuilder(
            future: _getUserData(),
            builder: (context, snapshot) {
              String userName = "User"; // Default value if no name is found

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                userName = "Error";
              } else if (snapshot.hasData) {
                var userData = snapshot.data as Map<String, dynamic>?;
                if (userData != null && userData.containsKey('First Name')) {
                  userName = userData['First Name'];
                }
              }

              return Positioned(
                top: 130, // Adjust to move the whole text block up/down
                left: 0,
                right: 0,
                child: SizedBox(
                  width: double.infinity,
                  height: 120, // Controls space for text arc
                  child: CustomPaint(
                    painter: arc.ArcTextPainter(
                      text: "Welcome $userName!", // ✅ Uses dynamic user name
                      radius: textRadius, // ✅ Adjust curvature
                      verticalOffset: textVerticalOffset, // ✅ Adjust position
                    ),
                  ),
                ),
              );
            },
          ),

          // Transparent AppBar on top of the background image
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
                        builder: (context) => InformationScreen(uid: uid),
                      ),
                    );
                  },
                ),
                actions: <Widget>[
                  TextButton.icon(
                    icon: Icon(Icons.person, color: Colors.white),
                    label: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w100,
                        fontFamily: "Modak", // ✅ Use the custom font
                      ),
                    ),
                    onPressed: () async {
                      await _auth.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Wrapper()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 40),

              // Grid Layout for Buttons (2x3)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 350, left: 20, right: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 buttons per row
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: buttonWidth / buttonHeight,
                    ),
                    itemCount: homeButtons(context).length,
                    itemBuilder: (context, index) {
                      return CustomButton(
                          text: homeButtons(context)[index]["title"]!,
                          onPressed: homeButtons(context)[index]["onPressed"]!,
                          width: buttonWidth,
                          height: buttonHeight,
                          backgroundColor: const Color.fromARGB(255, 255, 206,
                              206), // ✅ Different colors per button
                          borderColor: const Color.fromARGB(
                              255, 246, 165, 84), // ✅ Different border colors
                          borderWidth: 10.0);
                    },
                  ),
                ),
              ),
            ],
          ),

          // Next Star Bar with Star Image
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50, right: 80),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Next Star Container
                  Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 244, 232, 13),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        "Next Star",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w100,
                          fontFamily: "Modak",
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 15),

                  // Star Image Positioned to the Right
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Image.asset(
                      'assets/star.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// **Button Data for the Grid**
  List<Map<String, dynamic>> homeButtons(BuildContext context) => [
        {
          "title": "Emotion",
          "onPressed": () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LessonsPage(uid: uid)),
              ),
        },
        {
          "title": "Profile",
          "onPressed": () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(uid: uid)),
              ),
        },
        {
          "title": "Conversational Lessons",
          "onPressed": () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ConversationalLessons(uid: uid)),
              ),
        },
        {
          "title": "Pick your Buddy",
          "onPressed": () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangeBuddy(uid: uid)),
              ),
        },
        {
          "title": "Daily Check-In",
          "onPressed": () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DailyCheckInScreen(uid: uid)),
              ),
        },
        {
          "title": "Breathin Exercise",
          "onPressed": () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BreathingExercises()),
              ),
        },
      ];
}
