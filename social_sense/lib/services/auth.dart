import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:social_sense/models/user.dart' as app;

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

  // register with email and password

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




