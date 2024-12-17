// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';
import 'package:new_demo/main.dart';

void main() {
  testWidgets('MyApp widget test', (WidgetTester tester) async {
    // Mock a CameraDescription object
    final camera = CameraDescription(
      name: 'Test Camera',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 0,
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(camera: camera));

    // Verify that the app displays the correct title.
    expect(find.text('Camera Capture App'), findsOneWidget);
  });
}
