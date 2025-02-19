import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({super.key});

  @override
  FaceCaptureScreenState createState() => FaceCaptureScreenState();
}

class FaceCaptureScreenState extends State<FaceCaptureScreen> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try { 
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first, // Fallback to the first available camera
      );

      _controller = CameraController(frontCamera, ResolutionPreset.high);
      setState(() {
        _initializeControllerFuture = _controller.initialize();
      });
    } catch (e) {
      print('Error initializing camera: $e');
      setState(() {
        _initializeControllerFuture =
            Future.error('Failed to initialize camera');
      });
    }
  }

  @override
  void dispose() {
    if (_controller.value.isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _sendImageToAWS(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(
            'https://u4ez9excm2.execute-api.us-east-2.amazonaws.com/default/DetectFacesFunction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final emotions = responseData['Emotions'];
        print('Emotions: $emotions');

        if (emotions != null && emotions.isNotEmpty) {
          final highestEmotion = emotions
              .reduce((a, b) => a['Confidence'] > b['Confidence'] ? a : b);
          Navigator.pop(context, highestEmotion['Type']); // Pass emotion back
        }
      } else {
        print('Failed to analyze the image. Response: ${response.body}');
        Navigator.pop(context, null); // Return null if analysis failed
      }
    } catch (e) {
      print('Error sending image to AWS: $e');
      Navigator.pop(context, null); // Return null on error
    }
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
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error initializing camera: ${snapshot.error}'),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_controller.value.isInitialized) {
            try {
              await _initializeControllerFuture;
              final path = join(
                (await getTemporaryDirectory()).path,
                '${DateTime.now()}.png',
              );
              final XFile picture = await _controller.takePicture();
              await picture.saveTo(path);

              await _sendImageToAWS(path);
            } catch (e) {
              print('Error capturing or sending image: $e');
            }
          } else {
            print('Camera not initialized.');
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}