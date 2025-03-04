// import 'package:flutter/material.dart';

// class BreathingExercises extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Support Page'),
//         backgroundColor: Colors.brown[400],
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Back'),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:social_sense/screens/home/home.dart'; // Import Home screen

class BreathingExercises extends StatefulWidget {
  @override
  _BreathingExercisesState createState() => _BreathingExercisesState();
}

class _BreathingExercisesState extends State<BreathingExercises>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 12),
    )..repeat();

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: .7, end: 1.5), weight: 3),
      TweenSequenceItem(tween: ConstantTween(1.5), weight: 3),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: .7), weight: 3),
      TweenSequenceItem(tween: ConstantTween(.7), weight: 3),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(AssetSource('square_breathing.wav'));
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bottomOrange_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Back to Home Button
          Positioned(
            top: 30,
            left: 30,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Back'),
            ),
          ),

          // Text Positioned Independently
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Text(
              'Breathe in... Hold... Breathe out...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Centered Breathing Animation
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Ring
                    Container(
                      width: _animation.value * 180,
                      height: _animation.value * 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.4),
                          width: 10,
                        ),
                      ),
                    ),
                    // Second Ring
                    Container(
                      width: _animation.value * 140,
                      height: _animation.value * 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.4),
                          width: 10,
                        ),
                      ),
                    ),
                    // Inner Circle
                    Container(
                      width: _animation.value * 100,
                      height: _animation.value * 100,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Start/Pause Button Positioned at Bottom
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _toggleAudio,
                child: Text(_isPlaying ? 'Pause' : 'Start'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
