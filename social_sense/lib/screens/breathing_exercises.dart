import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:social_sense/screens/home/home.dart'; // Import Home screen

class BreathingExercises extends StatefulWidget {
  final String uid; // ✅ Takes in the uid

  BreathingExercises({required this.uid});

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
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: .7, end: 1.5), weight: 3),
      TweenSequenceItem(tween: ConstantTween(1.5), weight: 3),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: .7), weight: 3),
      TweenSequenceItem(tween: ConstantTween(.7), weight: 3),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  Future<void> _toggleAudioAndAnimation() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _controller.stop(); // ✅ Stop animation when paused
    } else {
      await _audioPlayer.play(AssetSource('square_breathing.wav'));
      _controller.repeat(); // ✅ Start animation when playing
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/bottomOrange_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Home Button (Passes UID)
          Positioned(
            top: screenHeight * 0.06,
            right: screenWidth * 0.05,
            child: SizedBox(
              width: 100,
              height: 35,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9720),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Home(uid: widget.uid)), // ✅ Pass UID
                  );
                },
                child: Text(
                  "Home",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // ✅ Breathing Exercise Text
          Positioned(
            top: screenHeight * 0.2,
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

          // ✅ Centered Breathing Animation (Only Moves When Started)
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

          // ✅ Start/Pause Button Positioned at Bottom
          Positioned(
            bottom: screenHeight * 0.08,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _toggleAudioAndAnimation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text(
                  _isPlaying ? 'Pause' : 'Start',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
