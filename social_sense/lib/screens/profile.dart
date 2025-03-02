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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/topOrange_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                title: Text('Profile'),
                backgroundColor: const Color.fromARGB(160, 149, 70, 42),
              ),
              Expanded(
                child: FutureBuilder(
                  future: _getUserData(),
                  builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData) {
                      return Center(child: Text('No user data found.'));
                    }
                    var userData = snapshot.data!;
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 20), // Add some spacing from the top
                          Text(
                            'First Name: ${userData['First Name']}',
                            style: TextStyle(fontSize: 24), // Increase font size
                          ),
                          Text(
                            'Last Name: ${userData['Last Name']}',
                            style: TextStyle(fontSize: 24), // Increase font size
                          ),
                          SizedBox(height: 30),
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
