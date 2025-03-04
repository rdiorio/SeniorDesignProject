import 'package:flutter/material.dart';
import 'package:social_sense/screens/authenticate/sign_in.dart';
import 'package:social_sense/screens/authenticate/register.dart';


class Authenticate extends StatefulWidget {
  const Authenticate({super.key});


  @override
  State<Authenticate> createState() => AuthenticateState();
}

class AuthenticateState extends State<Authenticate> {

  bool showSignIn = true;
  void toggleView(){
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn){
      return SignIn(toggleView: toggleView);
    } else {
      return Register(toggleView: toggleView);
    }
  }
}