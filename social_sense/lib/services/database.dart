import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  // Create a new user document with empty fields (only runs when registering a new user)
  Future<void> createUserProfile() async {
    try {
      await userCollection.doc(uid).set({
        'First Name': '',
        'Last Name': '',
        'scores': {
          'easy': 0,
          'medium': 0,
          'hard': 0,
          'stars': 0,
          'totalPoints': 0
        },
        'voice': {'name': 'Leda', 'gender': 'FEMALE'},
        'buddy': 'Bear',
        'buddyName': 'No Name',
        'currentHat': "",
        'currentGlasses': ""
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
    if (firstName.isNotEmpty) {
      firstName =
          firstName[0].toUpperCase() + firstName.substring(1).toLowerCase();
    }
    if (lastName.isNotEmpty) {
      lastName =
          lastName[0].toUpperCase() + lastName.substring(1).toLowerCase();
    }
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
  Future<void> updateBuddyInfo(String buddy, String buddyName, String voiceName,
      String voiceGender) async {
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

  Future<Map<String, dynamic>> getConversationSettings(
      String conversationTopic) async {
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
        "initialMessage": initialPromptSnapshot.exists
            ? initialPromptSnapshot.get('start') ?? "The data doesn't exist!"
            : "the data doesn't exist!",
        "positiveThreshold": thresholdsSnapshot.exists
            ? thresholdsSnapshot.get('positiveThreshold') ?? 0
            : 0,
        "negativeThreshold": thresholdsSnapshot.exists
            ? thresholdsSnapshot.get('negativeThreshold') ?? 0
            : 0,
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

  /* Future<void> storeConversation({
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
  }*/

  Future<void> storeConversation({
    required String userId,
    required String topic,
    required int score,
    required Map<String, int> classificationCounts,
    required List<Map<String, String>> conversationLog,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Reference to the topic-based subcollection
      CollectionReference conversationRef = firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(topic)
          .collection(
              'conversations'); // Subcollection for actual conversations

      // Store conversation with auto-generated ID
      await conversationRef.add({
        "timestamp": Timestamp.now(), // Firestore will handle sorting
        "score": score,
        "positive": classificationCounts["positive"] ?? 0,
        "neutral": classificationCounts["neutral"] ?? 0,
        "off-topic": classificationCounts["off-topic"] ?? 0,
        "inappropriate": classificationCounts["inappropriate"] ?? 0,
        "non-responsive": classificationCounts["non-responsive"] ?? 0,
        "conversationLog": conversationLog, // Keep as a List
      });

      print("Conversation stored successfully!");
    } catch (e) {
      print("Error storing conversation: $e");
    }
  }

  Future<String?> getAPIKey(String API) async {
    try {
      // Access the 'secure_keys' collection and get the 'openai_key' document
      DocumentSnapshot snapshot =
          await _db.collection('secureKeys').doc('KiBCxiL66kL1aQACVMXi').get();

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

  // Fetch conversations for a specific topic, ordered by date/time
/*Future<List<Map<String, dynamic>>> getConversations(String topic) async {
  try {
    // First, check if the topic document exists
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(topic) 
        .get();

    if (!snapshot.exists) {
      print("ERROR: Topic '$topic' does not exist for user $uid.");
      return [];
    }

    // Fetch the actual conversations subcollection inside the topic
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(topic)
        .collection('conversations') 
        .orderBy('timestamp', descending: true)
        .get();

    // Convert Firestore docs into a list
    List<Map<String, dynamic>> conversations = querySnapshot.docs.map((doc) {
      return {
        "id": doc.id, // Document ID (timestamp-based)
        ...doc.data() as Map<String, dynamic>, // Conversation data
      };
    }).toList();

    return conversations;
  } catch (e) {
    print("Error fetching conversations: $e");
    return [];
  }
}*/
  Future<List<Map<String, dynamic>>> getConversations(String topic) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('conversations')
          .doc(topic)
          .collection('conversations')
          .orderBy('timestamp', descending: true) // 🔥 Efficient sorting!
          .get();

      List<Map<String, dynamic>> conversations = querySnapshot.docs.map((doc) {
        return {
          "id": doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      return conversations;
    } catch (e) {
      print("Error fetching conversations: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getConversationData({
    required String userId,
    required String topic,
    required String conversationId,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Reference to the specific conversation document
      DocumentSnapshot docSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(topic)
          .collection('conversations') // Subcollection for conversations
          .doc(conversationId) // The specific conversation document
          .get();

      // Check if document exists
      if (!docSnapshot.exists) {
        print("ERROR: Conversation '$conversationId' not found.");
        return null;
      }

      // Return the document data
      return docSnapshot.data() as Map<String, dynamic>;
    } catch (e) {
      print("Error fetching conversation log: $e");
      return null;
    }
  }

  Future<void> debugConversations() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('conversations')
          .get();

      print("DEBUG: Existing Topics in Firestore → ");
      for (var doc in querySnapshot.docs) {
        print(doc.id); // Print topic names
      }
    } catch (e) {
      print("Error listing topics: $e");
    }
  }

  Future<void> debugFirestoreTopics() async {
    try {
      print("DEBUG: Fetching from path → users/$uid/conversations");

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('conversations')
          .get();

      print("DEBUG: Existing Topics in Firestore:");
      for (var doc in querySnapshot.docs) {
        print(" - ${doc.id}"); // Print topic names
      }

      if (querySnapshot.docs.isEmpty) {
        print("ERROR: No topics found in Firestore!");
      }
    } catch (e) {
      print("ERROR: Failed to fetch topics → $e");
    }
  }

  Future<Map<String, dynamic>?> getScoresandStars(String userId) async {
    try {
      // Reference to Firestore user document
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Extracting scores field
        Map<String, dynamic>? scores = userDoc.get('scores');
        if (scores != null) {
          return {
            "totalPoints": scores["totalPoints"] ?? 0,
            "stars": scores["stars"] ?? 0,
          };
        }
      }
    } catch (e) {
      print("Error fetching user scores: $e");
    }
    return null;
  }

  Future<void> updateUserScores(String userId, int pointsToAdd) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Run transaction to update safely
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          print("User document does not exist.");
          return;
        }

        Map<String, dynamic>? scores = userDoc.get('scores');

        if (scores == null) {
          print("Scores field does not exist.");
          return;
        }

        int currentPoints = scores["totalPoints"] ?? 0;
        int currentStars = scores["stars"] ?? 0;

        // Add new points
        int newTotalPoints = currentPoints + pointsToAdd;
        int newStars = currentStars;

        // Check if totalPoints exceeded threshold (10 points)
        if (newTotalPoints >= 100) {
          newStars += newTotalPoints ~/
              100; // Increase stars by the number of times threshold is met
          newTotalPoints =
              newTotalPoints % 100; // Keep the remainder as new totalPoints
        }

        // Update Firestore
        transaction.update(userRef, {
          "scores.totalPoints": newTotalPoints,
          "scores.stars": newStars,
        });

        print(
            "Updated Scores -> Total Points: $newTotalPoints, Stars: $newStars");
      });
    } catch (e) {
      print("Error updating user scores: $e");
    }
  }

  Future<void> addToOwnedAccessory(String category, String item) async {
    try {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      await userDocRef.update({
        category: FieldValue.arrayUnion([item])
      });
    } catch (e) {
      print('Error adding item to $category: $e');
    }
  }

  Future<List<String>> getOwnedItems(String field) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data[field] ?? []);
      }
    } catch (e) {
      print("Error fetching $field: $e");
    }
    return [];
  }

//Update currently equipped accessories
  Future<void> updateCurrentAccessories({String? hat, String? glasses}) async {
    Map<String, dynamic> updates = {};
    if (hat != null) updates['currentHat'] = hat;
    if (glasses != null) updates['currentGlasses'] = glasses;

    if (updates.isNotEmpty) {
      await userCollection.doc(uid).update(updates);
    }
  }

  //Deduct stars
  Future<bool> deductStars(int amount) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userRef);
        Map<String, dynamic> scores = snapshot.get('scores');
        int currentStars = scores['stars'] ?? 0;

        if (currentStars < amount) {
          return false;
        }

        int updatedStars = currentStars - amount;

        transaction.update(userRef, {
          'scores.stars': updatedStars,
        });

        return true;
      });
    } catch (e) {
      print("Failed to deduct stars: $e");
      return false;
    }
  }
}
