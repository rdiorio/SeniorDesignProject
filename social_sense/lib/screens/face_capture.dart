// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:path/path.dart' show join;
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;

// class FaceCaptureScreen extends StatefulWidget {
//   const FaceCaptureScreen({super.key});

//   @override
//   FaceCaptureScreenState createState() => FaceCaptureScreenState();
// }

// class FaceCaptureScreenState extends State<FaceCaptureScreen> {
//   late CameraController _controller;
//   Future<void>? _initializeControllerFuture;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     try {
//       final cameras = await availableCameras();
//       final frontCamera = cameras.firstWhere(
//         (camera) => camera.lensDirection == CameraLensDirection.front,
//         orElse: () => cameras.first, // Fallback to the first available camera
//       );

//       _controller = CameraController(frontCamera, ResolutionPreset.high);
//       setState(() {
//         _initializeControllerFuture = _controller.initialize();
//       });
//     } catch (e) {
//       print('Error initializing camera: $e');
//       setState(() {
//         _initializeControllerFuture =
//             Future.error('Failed to initialize camera');
//       });
//     }
//   }

//   @override
//   void dispose() {
//     if (_controller.value.isInitialized) {
//       _controller.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> _sendImageToAWS(String imagePath) async {
//     try {
//       final File imageFile = File(imagePath);
//       final bytes = await imageFile.readAsBytes();
//       final base64Image = base64Encode(bytes);

//       final response = await http.post(
//         Uri.parse(
//             'https://u4ez9excm2.execute-api.us-east-2.amazonaws.com/default/DetectFacesFunction'), // Replace with your AWS Lambda endpoint
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'image': base64Image}),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         final emotions = responseData['Emotions'];
//         print('Emotions: $emotions');

//         if (emotions != null && emotions.isNotEmpty) {
//           final highestEmotion = emotions
//               .reduce((a, b) => a['Confidence'] > b['Confidence'] ? a : b);
//           _showEmotionDialog(highestEmotion['Type']);
//         }
//       } else {
//         print('Failed to analyze the image. Response: ${response.body}');
//       }
//     } catch (e) {
//       print('Error sending image to AWS: $e');
//     }
//   }

//   void _showEmotionDialog(String emotion) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Emotion Detected'),
//         content: Text('The detected emotion is: $emotion'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Capture Your Face')),
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return CameraPreview(_controller);
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text('Error initializing camera: ${snapshot.error}'),
//             );
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           if (_controller.value.isInitialized) {
//             try {
//               await _initializeControllerFuture;
//               final path = join(
//                 (await getTemporaryDirectory()).path,
//                 '${DateTime.now()}.png',
//               );
//               final XFile picture = await _controller.takePicture();
//               await picture.saveTo(path);

//               await _sendImageToAWS(path);
//             } catch (e) {
//               print('Error capturing or sending image: $e');
//             }
//           } else {
//             print('Camera not initialized.');
//           }
//         },
//         child: const Icon(Icons.camera_alt),
//       ),
//     );
//   }
// }

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
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium, // Use medium for a balanced aspect ratio
      );
      _initializeControllerFuture = _controller.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    if (_controller.value.isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _captureAndSendImage() async {
    try {
      if (_initializeControllerFuture != null) {
        await _initializeControllerFuture;

        final path = join(
          (await getTemporaryDirectory()).path,
          '${DateTime.now()}.png',
        );

        final XFile picture = await _controller.takePicture();
        await picture.saveTo(path);

        // Call AWS Lambda
        await _sendImageToAWS(path);

        // Close the camera screen
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error capturing or sending image: $e');
    }
  }

  Future<void> _sendImageToAWS(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(
            'https://u4ez9excm2.execute-api.us-east-2.amazonaws.com/default/DetectFacesFunction'), // Replace with your AWS Lambda endpoint
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

          // Return the highest-confidence emotion
          if (mounted) {
            Navigator.pop(context, highestEmotion['Type']);
          }
        } else {
          if (mounted) {
            Navigator.pop(context, null); // No emotions detected
          }
        }
      } else {
        print('Failed to analyze the image. Response: ${response.body}');
        if (mounted) {
          Navigator.pop(context, null); // Indicate failure
        }
      }
    } catch (e) {
      print('Error sending image to AWS: $e');
      if (mounted) {
        Navigator.pop(context, null); // Indicate failure
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initializeControllerFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio:
                              3 / 4, // Fixed aspect ratio for a normal view
                          child: CameraPreview(_controller),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: FloatingActionButton(
                            onPressed: _captureAndSendImage,
                            child: const Icon(Icons.camera_alt),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error initializing camera: ${snapshot.error}'),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}
