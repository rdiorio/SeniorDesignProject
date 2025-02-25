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
        'buddy': 'bear'
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

  // Update User's Selected Voice
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

  //Initialize conversation storage

Future<String?> initializeConversationStorage({
  required String userId,
  required String topic,
}) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Create a new conversation document with an auto-generated ID
    DocumentReference conversationRef = firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc();

    // Initialize the conversation with the correct structure
    await conversationRef.set({
      "convoInfo": {
        "topic": topic,
        "date": Timestamp.now(),
        "score": 0, // Default score
      },
      "classifications": {
        "positive": 0,
        "neutral": 0,
        "off-topic": 0,
        "inappropriate": 0,
        "non-responsive": 0,
      },
      "conversationLog": [], // Empty conversation log
    });

    print("Conversation initialized successfully!");
    return conversationRef.id; // Return the document ID for future updates
  } catch (e) {
    print("Error initializing conversation: $e");
    return null; // Return null if an error occurs
  }
}

//Store message to the convo log
Future<void> addMessageToConversationLog({
  required String userId,
  required String? conversationId,
  required String role, // "user" or "assistant"
  required String message,
}) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference the conversation document
    DocumentReference conversationRef = firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId);

    // Fetch current conversation data
    DocumentSnapshot docSnapshot = await conversationRef.get();
    if (!docSnapshot.exists) {
      print("Error: Conversation does not exist.");
      return;
    }

    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

    // Get existing conversation log
    List<dynamic> conversationLog = data["conversationLog"] ?? [];

    // Add the new message
    conversationLog.add({"role": role, "content": message});

    // Update Firestore
    await conversationRef.update({
      "conversationLog": conversationLog,
    });

    print("Message added to conversation log!");
  } catch (e) {
    print("Error adding message to conversation log: $e");
  }
}


  
}
