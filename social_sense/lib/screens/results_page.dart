import 'package:flutter/material.dart';
import 'package:social_sense/screens/home/home.dart';
import 'package:social_sense/screens/lessons.dart';

class ResultsPage extends StatelessWidget {
  final List<int> attempts;
  final int points;

  const ResultsPage({Key? key, required this.attempts, required this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Ensure full width
        height: double.infinity, // Ensure full height
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/topPurple_background.png'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Lesson Completed!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Attempt Results
                Column(
                  children: List.generate(attempts.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      padding: const EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width * 0.9, // Responsive width
                      decoration: BoxDecoration(
                        color: Colors.purple[200],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: Text(
                        'Emotion ${index + 1}: Took ${attempts[index]} tries',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 20),
                
                // Points Display
                Container(
                  padding: const EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.yellow[300],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: Text(
                    'Total Points: $points',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                // Back Button
                ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LessonsPage()), // Replace HomePage() with your actual home widget
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.black, width: 3),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'Back to Lessons',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 30), // Extra space at bottom to prevent cutoff
              ],
            ),
          ),
        ),
      ),
    );
  }
}
