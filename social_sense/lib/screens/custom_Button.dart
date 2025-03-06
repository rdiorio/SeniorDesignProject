import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double borderRadius;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final TextStyle textStyle;

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.borderRadius = 12.0,
    this.width = 120.0,
    this.height = 60.0,
    this.backgroundColor =
        const Color.fromARGB(255, 242, 231, 249), // ✅ Default button color
    this.borderColor = Colors.black, // ✅ Default border color
    this.borderWidth = 7.0, // ✅ Default border thickness
    this.textStyle = const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w100,
      color: Color.fromARGB(255, 0, 0, 0),
      fontFamily: "Modak",
    ),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor, // ✅ Fully customizable per page
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor, // ✅ Fully customizable per page
          width: borderWidth,
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // ✅ Uses Container's color
          shadowColor: Colors.transparent, // ✅ Avoids double shadow effect
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.zero,
          elevation: 5,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: textStyle,
        ),
      ),
    );
  }
}
