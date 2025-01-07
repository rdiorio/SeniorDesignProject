import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:social_sense/models/user.dart' as app;
import 'package:social_sense/services/database.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // create user object based on app.User
  app.User? _userFromFirebaseUser(firebase_auth.User? user) {
    return user != null ? app.User(uid: user.uid) : null;
  }

  //auth change user stream
Stream<app.User?> get user {
  return _auth.authStateChanges()
      //.map((firebase_auth.User? user) => _userFromFirebaseUser(user));
      .map(_userFromFirebaseUser);
}

  // sign in anonymously
  Future signInAnon() async {
    try {
      firebase_auth.UserCredential result = await _auth.signInAnonymously();
      firebase_auth.User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  // sign in with email and password
    Future signInWithEmailAndPassword(String email, String password) async {
    try {
      firebase_auth.UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      firebase_auth.User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }


  // register with email and password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      firebase_auth.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      firebase_auth.User? user = result.user;

      await DatabaseService(uid: user!.uid).updateUserData('firstName', 'lastName');

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }


  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch(e){
      print(e.toString());
      return null;
    }
  }
}




