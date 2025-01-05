import 'package:flutter/material.dart';
import 'package:social_sense/services/auth.dart';

class Register extends StatefulWidget {
  final Function toggleView;  // toggleView is a required parameter
  Register({required this.toggleView});  // Make sure this is marked as required

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();

  // text field state
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text('Sign up to Social Sense'),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person),
            label: Text('Sign In'),
            onPressed: () {
              widget.toggleView();
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                onChanged: (val) {
                  setState(() => password = val);
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[400], // Background color
                ),
                child: Text(
                  'Register',
                  style: TextStyle(color: Colors.white), // Text color
                ),
                onPressed: () async {
                  // Add your sign-in logic here
                  print(email);
                  print(password);
                },
              )
            ]
          ),
        )
      ),
    );
  }
}