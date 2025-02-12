import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sense/screens/rewards.dart';

class ProfilePage extends StatelessWidget {
  final String uid;
  ProfilePage({required this.uid});

  Future<Map<String, dynamic>?> _getUserData() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: FutureBuilder(
        future: _getUserData(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No user data found.'));
          }
          var userData = snapshot.data!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('First Name: ${userData['First Name']}'),
              Text('Last Name: ${userData['Last Name']}'),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('View Rewards'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RewardsPage(uid: uid),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
