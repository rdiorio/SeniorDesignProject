// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:social_sense/screens/authenticate/authenticate.dart';
// import 'package:social_sense/models/user.dart';
// import 'package:social_sense/screens/home/home.dart';
// import 'package:social_sense/screens/information.dart';

// class Wrapper extends StatelessWidget {
//   Future<bool> isFirstTimeUser(String uid) async {
//     try {
//       print("Checking if user is first-time for uid: $uid");
//       final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

//       if (!doc.exists) {
//         print("User document does not exist for uid: $uid");
//         return true;
//       }
//       final data = doc.data();
//       if (data?['First Name'] == '' || data?['Last Name'] == '') {
//         print("User data is incomplete for uid: $uid");
//         return true;
//       }
//       print("User is not a first-time user: $uid");
//       return false;
//     } catch (e) {
//       print("Error in isFirstTimeUser: $e");
//       return true; // Default to treating as first-time user on error
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = Provider.of<User?>(context);
//     print("Wrapper build triggered. Current user: $user");

//     if (user == null) {
//       print("User is null. Navigating to Authenticate screen.");
//       return Authenticate();
//     } else {
//       print("User is logged in. UID: ${user.uid}");
//       return FutureBuilder<bool>(
//         future: isFirstTimeUser(user.uid),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             print("FutureBuilder waiting for isFirstTimeUser result...");
//             return Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//           }
//           if (snapshot.hasError) {
//             print("Error in FutureBuilder: ${snapshot.error}");
//             return Scaffold(
//               body: Center(
//                 child: Text("An error occurred. Please try again later."),
//               ),
//             );
//           }
//           if (snapshot.hasData) {
//             print("FutureBuilder completed. isFirstTimeUser: ${snapshot.data}");
//             if (snapshot.data == true) {
//               print("Navigating to InformationScreen.");
//               return InformationScreen(uid: user.uid);
//             } else {
//               print("Navigating to Home screen.");
//               return Home(uid: user.uid);
//             }
//           }
//           // Handle unexpected state
//           print("Unexpected state in FutureBuilder. Returning empty Scaffold.");
//           return Scaffold(
//             body: Center(child: Text("Unexpected state. Please try again.")),
//           );
//         },
//       );
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_sense/screens/authenticate/authenticate.dart';
import 'package:social_sense/models/user.dart';
import 'package:social_sense/screens/home/home.dart';
import 'package:social_sense/screens/information.dart';
import 'package:social_sense/screens/daily_checkin.dart'; // Import Daily Check-In screen
import 'package:intl/intl.dart'; // For date formatting

class Wrapper extends StatelessWidget {
  Future<bool> isFirstTimeUser(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) return true;

      final data = doc.data();
      return data?['First Name'] == '' || data?['Last Name'] == '';
    } catch (e) {
      print("Error in isFirstTimeUser: $e");
      return true;
    }
  }

  Future<bool> needsDailyCheckIn(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) return true; // Default to needing check-in

      final data = doc.data();
      if (data?['lastCheckIn'] == null) return true;

      DateTime lastCheckIn = (data!['lastCheckIn'] as Timestamp).toDate();
      String lastCheckInDate = DateFormat('yyyy-MM-dd').format(lastCheckIn);
      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      return lastCheckInDate != todayDate; // If last check-in is not today, return true
    } catch (e) {
      print("Error in needsDailyCheckIn: $e");
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return Authenticate();
    } else {
      return FutureBuilder<bool>(
        future: isFirstTimeUser(user.uid),
        builder: (context, firstTimeSnapshot) {
          if (firstTimeSnapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (firstTimeSnapshot.hasData && firstTimeSnapshot.data == true) {
            return InformationScreen(uid: user.uid);
          }

          return FutureBuilder<bool>(
            future: needsDailyCheckIn(user.uid),
            builder: (context, checkInSnapshot) {
              if (checkInSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (checkInSnapshot.hasData && checkInSnapshot.data == true) {
                return DailyCheckInScreen(uid: user.uid);
              }

              return Home(uid: user.uid);
            },
          );
        },
      );
    }
  }
}
