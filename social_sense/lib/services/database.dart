// import 'package:cloud_firestore/cloud_firestore.dart';

// class DatabaseService {

//   final String uid;
//   DatabaseService({required this.uid});

//   // collection reference
//   final CollectionReference userCollection =
//       FirebaseFirestore.instance.collection('users');

//   Future updateUserData(String firstName, String lastName) async {
//     return await userCollection.doc(uid).set({
//       'First Name' : firstName,
//       'Last Name' : lastName,
//     });
//   }

// }

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  // Create a new user document with empty fields (only runs when registering a new user)
  Future<void> createUserProfile() async {
    try {
      await userCollection.doc(uid).set({
        'First Name': '',
        'Last Name': '',
        'scores': {
          'easy': 0,
          'medium': 0,
          'hard': 0
        }
      });
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  Future<void> updateUserScore(String difficulty, int score) async {
    try {
      await userCollection.doc(uid).update({
        'scores.$difficulty': score,
      });
    } catch (e) {
      print('Error updating user score: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserScores() async {
    try {
      DocumentSnapshot snapshot = await userCollection.doc(uid).get();
      if (snapshot.exists) {
        return (snapshot.data() as Map<String, dynamic>)['scores'];
      }
      return null;
    } catch (e) {
      print('Error fetching user scores: $e');
      return null;
    }
  }


  // Update user profile (e.g., first name & last name)
  Future<void> updateUserData(String firstName, String lastName) async {
    try {
      await userCollection.doc(uid).update({
        'First Name': firstName,
        'Last Name': lastName,
      });
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      DocumentSnapshot snapshot = await userCollection.doc(uid).get();
      return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  
}
