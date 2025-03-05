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

  final FirebaseFirestore _db = FirebaseFirestore.instance;
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
        },
        'voice': {
          'name': 'Leda',
          'gender': 'FEMALE'
        },
        'buddy': 'Bear',
        'buddyName': 'No Name'
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

  Future<void> updateUserVoice(String voiceName, String gender) async {
    try {
      await userCollection.doc(uid).update({
        'voice': {
          'name': voiceName,
          'gender': gender,
        }
      });
      print("Voice updated successfully.");
    } catch (e) {
      print("Error updating voice: $e");
    }
  }

  ///Fetch User's Selected Voice
  Future<Map<String, String>> getUserVoice() async {
    try {
      DocumentSnapshot snapshot = await userCollection.doc(uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('voice')) {
          return {
            "name": data['voice']['name'],
            "gender": data['voice']['gender'],
          };
        }
      }
      return {
            "name": "Leda",
            "gender": "FEMALE",
          };
    } catch (e) {
      print("Error fetching voice data: $e");
      return {
            "name": "Leda",
            "gender": "FEMALE",
          };
    }
  }

  //Update buddy
Future<void> updateBuddyInfo(String buddy, String buddyName, String voiceName, String voiceGender) async {
    try {
      await userCollection.doc(uid).update({
        'buddy': buddy,
        'buddyName': buddyName,
        'voice': {
          'name': voiceName,
          'gender': voiceGender,
        }
      });
      print("Voice updated successfully.");
    } catch (e) {
      print("Error updating voice: $e");
    }
  }

  //Get buddy
  Future<Map<String, String>> getBuddyInfo() async {
    try {
      DocumentSnapshot snapshot = await userCollection.doc(uid).get();

      if (snapshot.exists) {
        String buddy = snapshot.get("buddy") ?? "Unknown Buddy";
        String buddyName = snapshot.get("buddyName") ?? "No Name";

        return {
          "buddy": buddy,
          "buddyName": buddyName,
        };
      } else {
        return {
          "buddy": "Unknown Buddy",
          "buddyName": "No Name",
        };
      }
    } catch (e) {
      print("Error retrieving buddy info: $e");
      return {
        "buddy": "Unknown Buddy",
        "buddyName": "No Name",
      };
    }
  }
  

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

  Future<void> storeConversation({
    required String userId,
    required String topic,
    required int score,
    required Map<String, int> classificationCounts,
    required List<Map<String, String>> conversationLog,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Format the date for easy sorting (ISO 8601 format)
      String timestamp = DateTime.now().toIso8601String();

      // Reference to the topic-based subcollection
      DocumentReference conversationRef = firestore
          .collection('users')
          .doc(userId)
          .collection('conversations') // Conversations collection inside user
          .doc(topic) // Topic document
          .collection('conversations') // Subcollection for conversations
          .doc(timestamp); // Date-based conversation ID

      // Conversation data
      Map<String, dynamic> conversationData = {
        "date": Timestamp.now(),
        "score": score,
        "classifications": {
          "positive": classificationCounts["positive"] ?? 0,
          "neutral": classificationCounts["neutral"] ?? 0,
          "off-topic": classificationCounts["off-topic"] ?? 0,
          "inappropriate": classificationCounts["inappropriate"] ?? 0,
          "non-responsive": classificationCounts["non-responsive"] ?? 0,
        },
        "conversationLog": conversationLog,
      };

      // Store in Firestore
      await conversationRef.set(conversationData);

      print("Conversation stored successfully!");
    } catch (e) {
      print("Error storing conversation: $e");
    }
  }

  Future<String?> getAPIKey(String API) async {
    try {
      // Access the 'secure_keys' collection and get the 'openai_key' document
      DocumentSnapshot snapshot = await _db.collection('secureKeys').doc('KiBCxiL66kL1aQACVMXi').get();

      if (snapshot.exists) {
        // Return the API key if it exists
        return snapshot.get(API);
      } else {
        print("API key not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching API key: $e");
      return null;
    }
  }

  
}
