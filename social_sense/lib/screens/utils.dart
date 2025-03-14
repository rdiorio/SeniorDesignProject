import 'package:flutter/material.dart';

// Base reference size (adjust this to match your default design)
const double baseWidth = 400.0; // Assume 400px is the "normal" width

double scaleWidth(BuildContext context, double size) {
  double screenWidth = MediaQuery.of(context).size.width;
  return (size / baseWidth) * screenWidth;
}