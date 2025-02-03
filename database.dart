import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  // Create a new user document with empty fields (only runs when registering a new user)
  Future<void> createUserProfile() async {
    try {
      await userCollection.doc(uid).set({
        'First Name': '',
        'Last Name': '',
      });
    } catch (e) {
      print('Error creating user profile: $e');
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

//Conversation APIS

//Get initial conversation data (inital prompt, positive & negative thresholds)
Future<Map<String, dynamic>> getConversationSettings(String conversationTopic) async {
  try {
    DocumentSnapshot thresholdsSnapshot = await _db
        .collection('modules')
        .doc(conversationTopic)
        .collection('Thresholds')
        .doc('threshold')
        .get();

    DocumentSnapshot initialPromptSnapshot = await _db
        .collection('modules')
        .doc(conversationTopic)
        .collection('initialPrompt')
        .doc('prompt')
        .get();

    return {
      "initialMessage": initialPromptSnapshot.exists ? initialPromptSnapshot.get('start') ?? "The data doesn't exist!" : "the data doesn't exist!",
      "positiveThreshold": thresholdsSnapshot.exists ? thresholdsSnapshot.get('positiveThreshold') ?? 0 : 0,
      "negativeThreshold": thresholdsSnapshot.exists ? thresholdsSnapshot.get('negativeThreshold') ?? 0 : 0,
    };
  } catch (e) {
    print("Error fetching conversation data: $e");
    return {
      "initialMessage": "Error loading message.",
      "positiveThreshold": 0,
      "negativeThreshold": 0,
    };
  }
}



}


