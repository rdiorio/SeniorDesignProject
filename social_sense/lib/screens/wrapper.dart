import 'package:flutter/material.dart';
import 'package:social_sense/screens/authenticate/authenticate.dart';


class Wrapper extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    //return either home or authenticate
    return Authenticate();
  }
}