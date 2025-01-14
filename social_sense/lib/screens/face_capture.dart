import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class FaceCaptureScreen extends StatefulWidget {
  final CameraDescription camera;

  const FaceCaptureScreen({super.key, required this.camera});

  @override
  FaceCaptureScreenState createState() => FaceCaptureScreenState();
}

class FaceCaptureScreenState extends State<FaceCaptureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendImageToAWS(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('YOUR_LAMBDA_ENDPOINT'), // Replace with your AWS Lambda endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final emotions = responseData['Emotions'];
        print('Emotions: $emotions');

        // Display the emotion with the highest confidence
        if (emotions != null && emotions.isNotEmpty) {
          final highestEmotion = emotions.reduce((a, b) =>
              a['Confidence'] > b['Confidence'] ? a : b);
          _showEmotionDialog(highestEmotion['Type']);
        }
      } else {
        print('Failed to analyze the image. Response: ${response.body}');
      }
    } catch (e) {
      print('Error sending image to AWS: $e');
    }
  }

  void _showEmotionDialog(String emotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emotion Detected'),
        content: Text('The detected emotion is: $emotion'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Your Face')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final path = join(
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );
            final XFile picture = await _controller.takePicture();
            await picture.saveTo(path);

            // Send the image to AWS Lambda
            await _sendImageToAWS(path);
          } catch (e) {
            print('Error capturing or sending image: $e');
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
