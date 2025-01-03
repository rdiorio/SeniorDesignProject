import 'package:flutter/material.dart';
import 'package:social_sense/screens/authenticate/sign_in.dart';


class Authenticate extends StatefulWidget {
  const Authenticate({super.key});


  @override
  State<Authenticate> createState() => AuthenticateState();
}

class AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child:SignIn(),
    );
  }
}