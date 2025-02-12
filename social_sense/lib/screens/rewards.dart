import 'package:flutter/material.dart';

class RewardsPage extends StatelessWidget {
  final String uid;
  RewardsPage({required this.uid});

  final List<Map<String, String>> badges = [
    {'name': 'Beginner', 'image': 'lib/screens/assets/badge1.png'},
    {'name': 'Intermediate', 'image': 'lib/screens/assets/badge2.png'},
    {'name': 'Advanced', 'image': 'lib/screens/assets/badge3.png'},
    {'name': 'Consistency', 'image': 'lib/screens/assets/badge4.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rewards')),
      body: GridView.builder(
        padding: EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Image.asset(badges[index]['image']!, width: 100, height: 100),
              Text(badges[index]['name']!),
            ],
          );
        },
      ),
    );
  }
}
