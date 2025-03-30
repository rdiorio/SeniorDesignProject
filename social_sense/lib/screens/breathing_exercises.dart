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
      duration: Duration(seconds: 96),
    );

 _animation = TweenSequence<double>([
  TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.5), weight: 5), //inhale GOOD
  TweenSequenceItem(tween: ConstantTween(1.5), weight: 6), //hold GOOD
  TweenSequenceItem(tween: Tween(begin: 1.5, end: 0.7), weight: 5), //exhale GOOD
  TweenSequenceItem(tween: ConstantTween(0.7), weight: 6), //hold GOOD
  TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.5), weight: 5), //inhale GOOD
  TweenSequenceItem(tween: ConstantTween(1.5), weight: 5), //hold GOOD
  TweenSequenceItem(tween: Tween(begin: 1.5, end: 0.7), weight: 5), //exhale GOOD
  TweenSequenceItem(tween: ConstantTween(0.7), weight: 5), //hold GOOD
  TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.5), weight: 6), //inhale GOOD
  TweenSequenceItem(tween: ConstantTween(1.5), weight: 5), //hold GOOD
  TweenSequenceItem(tween: Tween(begin: 1.5, end: 0.7), weight: 6), // exhale GOOD
  TweenSequenceItem(tween: ConstantTween(0.7), weight: 6), //hold GOOD
  TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.5), weight: 5), //inhale GOOD 
  TweenSequenceItem(tween: ConstantTween(1.5), weight: 5), //hold GOOD
  TweenSequenceItem(tween: Tween(begin: 1.5, end: 0.7), weight: 5), //exhale GOOD
  TweenSequenceItem(tween: ConstantTween(0.7), weight: 7), //hold
  TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.5), weight: 5), //inhale 
  TweenSequenceItem(tween: Tween(begin: 1.5, end: 0.7), weight: 4), //exhale 
]).animate(
  CurvedAnimation(parent: _controller, curve: Curves.linear), 
);

  }
 Future<void> _toggleAudioAndAnimation() async {
  if (_isPlaying) {
    await _audioPlayer.pause();
    _controller.stop();
  } else {
    await _audioPlayer.play(AssetSource('square_breathing.wav'));
    Future.delayed(Duration(seconds: 34), () {
      if (_isPlaying) {
        _controller.repeat();
      }
    });
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
              width: screenWidth * 0.25,
              height: screenHeight * 0.05,
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
                    fontSize: screenWidth * 0.04,
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
            bottom: screenHeight * 0.13,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _toggleAudioAndAnimation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 242, 231, 249),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: const Color.fromARGB(255, 248, 129, 74), width: screenWidth * 0.01),
                  ),
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
