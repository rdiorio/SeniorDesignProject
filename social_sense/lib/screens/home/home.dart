import 'package:flutter/material.dart';
import 'package:social_sense/services/auth.dart';

class Home extends StatelessWidget {

  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text('Social Sense'),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person, color: Colors.white), // Set icon color
            label: Text(
              'logout',
              style: TextStyle(color: Colors.white), // Set label color
            ),
            onPressed: () async {
              // Add your logout logic here
              await _auth.signOut();
            },
          ),
        ],
      ),
    );
  }
}
