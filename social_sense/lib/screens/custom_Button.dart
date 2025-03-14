import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double borderRadius;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final TextStyle textStyle;

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.borderRadius = 20.0,
    this.height = 70.0,
    this.backgroundColor = const Color.fromARGB(255, 242, 231, 249),
    this.borderColor = Colors.black,
    this.borderWidth = 5.0,
    this.textStyle = const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w100,
      color: Colors.black,
      fontFamily: "Modak",
    ),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          boxShadow: [
            // ✅ Adds depth with shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // Shadow color
              offset: const Offset(4, 4), // Shift shadow to bottom right
              blurRadius: 7, // Spread of shadow
            ),
            BoxShadow(
              color: const Color.fromARGB(179, 255, 255, 255)
                  .withOpacity(0.3), // Inner highlight
              offset: const Offset(-2, -2), // Shift highlight to top left
              blurRadius: 1,
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent, // Remove default button shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: EdgeInsets.zero,
            elevation: 0, // ✅ Disable default elevation
          ),
          onPressed: onPressed,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}