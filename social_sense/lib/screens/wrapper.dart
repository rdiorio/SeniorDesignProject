import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_sense/screens/authenticate/authenticate.dart';
import 'package:social_sense/models/user.dart';
import 'package:social_sense/screens/home/home.dart';


class Wrapper extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User?>(context);

    //return either home or authenticate
    if (user == null){
      return Authenticate();
    } else{
      return Home();
    }
  }
}