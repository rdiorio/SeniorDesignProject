// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
// import 'package:social_sense/models/user.dart' as app;
// import 'package:social_sense/services/database.dart';

// class AuthService {
//   final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

//   // Convert Firebase User to App User
//   app.User? _userFromFirebaseUser(firebase_auth.User? user) {
//     return user != null ? app.User(uid: user.uid) : null;
//   }

//   // Auth change user stream
//   Stream<app.User?> get user {
//     return _auth.authStateChanges().map(_userFromFirebaseUser);
//   }

//   // Sign in anonymously
//   Future<app.User?> signInAnon() async {
//     try {
//       firebase_auth.UserCredential result = await _auth.signInAnonymously();
//       return _userFromFirebaseUser(result.user);
//     } catch (e) {
//       print('Error signing in anonymously: $e');
//       return null;
//     }
//   }

//   // Sign in with email and password
//   Future<app.User?> signInWithEmailAndPassword(String email, String password) async {
//     try {
//       firebase_auth.UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
//       return _userFromFirebaseUser(result.user);
//     } catch (e) {
//       print('Error signing in: $e');
//       return null;
//     }
//   }

//   // Register with email and password
//   Future<app.User?> registerWithEmailAndPassword(String email, String password) async {
//     try {
//       firebase_auth.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
//       firebase_auth.User? user = result.user;

//       if (user != null) {
//         // Create a new Firestore document for the user with default values
//         await DatabaseService(uid: user.uid).createUserProfile();
//       }

//       return _userFromFirebaseUser(user);
//     } catch (e) {
//       print('Error registering user: $e');
//       return null;
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     try {
//       await _auth.signOut();
//     } catch (e) {
//       print('Error signing out: $e');
//     }
//   }
// }



import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:social_sense/models/user.dart' as app;
import 'package:social_sense/services/database.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // Convert Firebase User to App User
  app.User? _userFromFirebaseUser(firebase_auth.User? user) {
    return user != null ? app.User(uid: user.uid) : null;
  }

  // Auth change user stream
  Stream<app.User?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Sign in anonymously
  Future<app.User?> signInAnon() async {
    try {
      firebase_auth.UserCredential result = await _auth.signInAnonymously();
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<app.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      firebase_auth.UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Register with email and password
  Future<app.User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      firebase_auth.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      firebase_auth.User? user = result.user;

      if (user != null) {
        // Create a new Firestore document for the user with default values
        await DatabaseService(uid: user.uid).createUserProfile();
      }

      return _userFromFirebaseUser(user);
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent');
    } catch (e) {
      print('Error sending password reset email: $e');
      throw e; // Re-throw the error so it can be handled in the UI
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}

